subslist = open('/projectnb/sternlab/kisenburg/ConnectomeFingerprinting/Code/Ridge/subjects.txt','r').read().splitlines()


from sklearn.linear_model import Ridge
from sklearn import preprocessing
from sklearn.metrics import mean_squared_error
import numpy as np
import scipy as sp
import os
import csv


# Choose Left-out Test Subject 
subid = int(os.getenv('SGE_TASK_ID'))-1
subname = subslist[subid]
print('Outer ',subname)


#LOAD in Data for Test Subject:
Hypothesis = 'hypo5'
Contrast = 'TxtR-vs-TxtU'
Contrast2 = 'Txt'
Network = 'multi'
X_test = np.genfromtxt('/projectnb/sternlab/kisenburg/ConnectomeFingerprinting/Outputs/Matrices/' + Hypothesis + '/' + Network + '/lh.'+subname+'_norm.csv', delimiter=',')
y_test = np.genfromtxt('/projectnb/sternlab/kisenburg/ConnectomeFingerprinting/Outputs/Scan_Activations/' + Hypothesis + '/' + Contrast + '/lh.' +subname+'.csv', delimiter=',')

SaveDir = ('/projectnb/sternlab/kisenburg/ConnectomeFingerprinting/Outputs/Ridge_Results/' + Hypothesis + '/' + Contrast + '/' + Network)

# remove the test subject from the subject list 
del subslist[subid]

best_a = []

# loop through the remaining subjects as a validation set 
for n in range(22):

	# get list of training subjects for this validation set 
    sublist = subslist[0:n] + subslist[n+1:]
    print('Leftout-ID Inner ', subslist[n])

	# load in training data 
    X_train_matrix = []
    y_train = np.empty(len(y_test))
    for sub in sublist:
        data = np.genfromtxt('/projectnb/sternlab/kisenburg/ConnectomeFingerprinting/Outputs/Matrices/' + Hypothesis + '/' + Network + '/lh.'+sub+'_norm.csv', delimiter=',')
        activation = np.genfromtxt('/projectnb/sternlab/kisenburg/ConnectomeFingerprinting/Outputs/Scan_Activations/'+ Hypothesis + '/' + Contrast +'/lh.'+sub+'.csv', delimiter = ',')
        X_train_matrix.append(data) 
        y_train = np.hstack((y_train,activation))   

    y_train = np.delete(y_train,slice(0,len(y_test)),0)
    x_scaler = preprocessing.StandardScaler()
    x_scaler = x_scaler.fit(X_train_matrix)
    X_train = x_scaler.transform(X_train_matrix)
    
    # Get Validation data and labels 
    val_sub = subslist[n]
    #sub_test= subs_list[n]
    print('Validation-ID Inner', val_sub)
    
    y_val = np.genfromtxt('/projectnb/sternlab/kisenburg/ConnectomeFingerprinting/Outputs/Scan_Activations/'+ Hypothesis + '/' + Contrast + '/lh.'+val_sub+'.csv', delimiter=',')
    X_val = np.genfromtxt('/projectnb/sternlab/kisenburg/ConnectomeFingerprinting/Outputs/Matrices/' + Hypothesis + '/' + Network + '/lh.'+val_sub+'_norm.csv', delimiter=',')
    #test_data1 = preprocessing.scale(test_data1)

    # Scale the training and validation data based on training data only 
    x_val_scaled = x_scaler.transform(X_val)

    n_alphas = 100
    alphas = np.logspace(0,7,num = n_alphas,base = 10)
    #is it the maximum of the alpha value
    
    detcoefs = []
    for a in alphas: 
        clf = Ridge(alpha=a)
        clf.fit(X_train,y_train)
        y_pred1 = clf.predict(x_val_scaled)
        score = mean_squared_error(y_val,y_pred1)
        detcoefs.append((a,score))
        
    detcoefs = np.asarray(detcoefs)
    min_idx = np.argmin(detcoefs[:,1])
    best_a.append(detcoefs[min_idx,0])

# Compute average of best lambda values across validation sets 
a = np.mean(best_a)
#a_values.append(a)
#print(a)


# Get the full training data and labels 
X = np.empty(len(X_test[1]))
for sub in subslist:
    data2 = np.genfromtxt('/projectnb/sternlab/kisenburg/ConnectomeFingerprinting/Outputs/Matrices/' + Hypothesis + '/' + Network + '/lh.'+subname+'_norm.csv', delimiter=',')
    X = np.vstack((X,data2))
X = np.delete(X,0,0)
X = x_scaler.fit_transform(X)

y = np.empty(len(y_test))
for sub in subslist:
    activation2 = np.genfromtxt('/projectnb/sternlab/kisenburg/ConnectomeFingerprinting/Outputs/Scan_Activations/'+ Hypothesis + '/' + Contrast + '/lh.'+sub+'.csv', delimiter = ',')
    y = np.hstack((y,activation2))
y = np.delete(y,slice(0,len(y_test)),0)

# Scale the training and test data using only the training data
x_test_scaled = x_scaler.transform(X_test)


clf = Ridge(alpha=a)
clf.fit(X,y)
coefficient = clf.coef_
y_pred = clf.predict(x_test_scaled)
(r,p) = sp.stats.pearsonr(y_pred,y_test)
prediction = os.path.join(SaveDir, 'lh_' + Contrast2 + '_pred_' + subname + '.csv')
np.savetxt(prediction, y_pred, delimiter= ',')

data = zip([a], [subname], [r], [p])
filename = os.path.join(SaveDir, 'lh_' + Contrast2 + '_' + subname + '.csv')
filename2 = os.path.join(SaveDir, 'lh_' + Contrast2 + '_Coef' + subname + '.csv')
np.savetxt(filename2, coefficient, delimiter = ',')


with open(filename, 'w', newline='') as file:
    writer = csv.writer(file)
    writer.writerow(['a', 'subname', 'r', 'p'])  # Write header row
    writer.writerows(data)
    

print(f'CSV file "{filename}" on "{subid}" successfully.')