## This is the script to run through simulated data for Ridge regression-based connectome fingerprinting.
## Substitute the simulated with the actual data.

from fileinput import filename
from sklearn.linear_model import Ridge
from sklearn import preprocessing
from sklearn.metrics import mean_squared_error
import numpy as np
import scipy as sp
import os
import csv

# Set subject number
N_SUBJECTS = 23

# Set FC matrix dimensions for input
# X_sub: (n_vertices, m_parcels)
# y_sub: (m_parcels,)
N_VERTICES = 100
M_PARCELS = 100

SIM_NOISE_STD = 100
SIM_SEED = 123


Contrast = 'TxtR-vs-TxtU'
Contrast2 = 'Txt'


ABS_OUT_BASE = "../outputs"
REL_OUT_BASE = os.path.join(os.getcwd(), "outputs")

os.makedirs(ABS_OUT_BASE, exist_ok=True)
OUT_BASE = ABS_OUT_BASE

SaveDir = os.path.join(OUT_BASE, "Ridge_Results", Contrast)
os.makedirs(SaveDir, exist_ok=True)


subslist_all = [f"sub{idx:02d}" for idx in range(1,N_SUBJECTS+1)]

# Create simulated data
rng_global = np.random.default_rng(43)
beta_true = rng_global.normal(size=(N_VERTICES,))

sim_X = {}
sim_Y = {}

# Generate simulated subject data
for s in subslist_all:
    subid = int(s.replace("sub", ""))  
    s_seed = SIM_SEED + subid
    rng = np.random.default_rng(s_seed)
    X = rng.normal(size=(N_VERTICES, M_PARCELS))
    noise = SIM_NOISE_STD * rng.normal(size=(M_PARCELS,))
    Y = X.T @ beta_true + noise

    sim_X[s] = X
    sim_Y[s] = Y

print(f"Simulated {N_SUBJECTS} subjects.")
print(f"Each X: ({N_VERTICES}, {M_PARCELS}) ; each y: ({M_PARCELS},)")


outer_ids = range(len(subslist_all))

for subid in outer_ids:
    subslist = subslist_all.copy()

    # left-out test subject
    subname = subslist[subid]
    print('Outer ', subname)

    # test subject
    X_test = sim_X[subname]  # (n_vertices, m_parcels)
    y_test = sim_Y[subname]  # (m_parcels,)

    # remove the test subject
    del subslist[subid]

    best_a = []

    # remaining subjects in the inner-loop
    for n in range(len(subslist)):

        # get list of training subjects for this validation set
        sublist = subslist[0:n] + subslist[n+1:]
        print('Leftout-ID Inner ', subslist[n])

        # load in training data
        X_train_matrix = []
        y_train = []
        for sub in sublist:
            data = sim_X[sub].T        
            activation = sim_Y[sub]     
            X_train_matrix.append(data)
            y_train.append(activation)

        # Stack across subjects along rows (parcels)
        X_train_matrix = np.vstack(X_train_matrix)  
        y_train = np.hstack(y_train)             
        x_scaler = preprocessing.StandardScaler()
        x_scaler = x_scaler.fit(X_train_matrix)
        X_train = x_scaler.transform(X_train_matrix)

        # Get Validation data and labels
        val_sub = subslist[n]
        print('Validation-ID Inner', val_sub)

        y_val = sim_Y[val_sub]    
        X_val = sim_X[val_sub].T      

        x_val_scaled = x_scaler.transform(X_val)

        n_alphas = 100
        alphas = np.logspace(0, 7, num=n_alphas, base=5)

        detcoefs = []
        for a in alphas:
            clf = Ridge(alpha=a)
            clf.fit(X_train, y_train)
            y_pred1 = clf.predict(x_val_scaled)   # (m_parcels,)
            score = mean_squared_error(y_val, y_pred1)
            detcoefs.append((a, score))

        detcoefs = np.asarray(detcoefs)
        min_idx = np.argmin(detcoefs[:, 1])
        best_a.append(detcoefs[min_idx, 0])

    # Compute average of best lambda values across validation sets
    a = float(np.mean(best_a))

    # Get the full training data and labels
    X_all = []
    y_all = []
    for sub in subslist:
        X_all.append(sim_X[sub].T)
        y_all.append(sim_Y[sub])

    X = np.vstack(X_all)
    y = np.hstack(y_all)

    # Scale
    x_scaler = preprocessing.StandardScaler()
    X = x_scaler.fit_transform(X)
    x_test_scaled = x_scaler.transform(X_test.T)

    clf = Ridge(alpha=a)
    clf.fit(X, y)
    coefficient = clf.coef_
    y_pred = clf.predict(x_test_scaled)

    # Pearson's r for simularity
    (r, p) = sp.stats.pearsonr(y_pred, y_test)

    prediction = os.path.join(SaveDir, 'lh_' + Contrast2 + '_pred_' + subname + '.csv')
    np.savetxt(prediction, y_pred, delimiter=',')

    result_stats = os.path.join(SaveDir, 'lh_' + Contrast2 + '_stats_' + subname + '.csv')
    with open(result_stats, 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(['a', 'subname', 'r', 'p'])
        writer.writerow([a, subname, r, p])
    print(f'CSV file "{result_stats}" on "{subid}" successfully.')

    
    coef_list = os.path.join(SaveDir, 'lh_' + Contrast2 + '_Coef_' + subname + '.csv')
    np.savetxt(coef_list, coefficient, delimiter=',')



print("Done.")
