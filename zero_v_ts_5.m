clear all;close all;clc
%% This script identifies nan values in the vertices so that we can remove those parcels.
Hypothesis = {'hypo5'};
DataDir = '/projectnb/sternlab/kisenburg/ConnectomeFingerprinting/';

subs = importdata(char(strcat(DataDir, '/Code/Ridge/subjects.txt')));
filenames1 = [];
filenames2 = [];

for i = 1:length(subs)
    subj = subs{i};
    filenames1{i} = char(strcat(DataDir, 'Outputs/Matrices/', Hypothesis, '/rh.',subj,'_norm.csv'));
    filenames2{i} = char(strcat(DataDir, 'Outputs/Matrices/', Hypothesis, '/lh.',subj,'_norm.csv'));
end 
nan_rh = [];
nan_lh = [];
size_rh = []; %checking the size of each fc_mx
size_lh = []; %checking the size of each fc_mx

%rh
for i = 1:numel(filenames1)
    filename1 = filenames1{i};  % Get filename from the cell array
    fileData1 = readmatrix(filename1);
    nan1 = find(isnan(fileData1(:,1)));
    nan_rh = union(nan1, nan_rh);
    size1 = size(fileData1,2);
    size_rh = [size_rh; size1];
end
% if NaN values exist, print yes, and save the new matrix 
if isempty(nan_rh)
    disp('There are no Nan values')
else 
    disp('NaNs present')
    save(char(strcat(DataDir, 'Outputs/Matrices/', Hypothesis,'/','nan_rh.mat')),'nan_rh');
end 
%lh
for i = 1:numel(filenames2)
    filename2 = filenames2{i};  % Get filename from the cell array
    fileData2 = readmatrix(filename2);
    nan2 = find(isnan(fileData2(:,1)));
    nan_lh = union(nan2, nan_lh);
    size2 = size(fileData2,2);
    size_lh = [size_lh; size2];
end
if isempty(nan_lh)
    disp('There are no Nan values')
else 
    disp('NaNs present')
    save(char(strcat(DataDir, 'Outputs/Matrices/', Hypothesis, '/','nan_lh.mat')),'nan_lh');
end

if isempty(nan_rh)
    disp('skipped')
else 
    %% Remove the nans from the connectivity matrix
    %rh
    for f = 1:numel(filenames1)
        filename1 = filenames1{f};  % Get filename from the cell array
        fileData1 = readmatrix(filename1);
        fileData1(nan_rh,:) = [];
        csvwrite(char(strcat(DataDir, 'Outputs/Matrices/', Hypothesis, '/', 'rh.',subs{i},'_norm.csv')),fileData1)
    end
end 

if isempty(nan_lh)
    disp('skipped')
else 
%lh
    for f = 1:numel(filenames2)
        filename2 = filenames2{f};  % Get filename from the cell array
        fileData2 = readmatrix(filename2);
        fileData2(nan_lh,:) = [];
        csvwrite(char(strcat(DataDir, 'Outputs/Matrices/', Hypothesis, '/', 'lh.',subs{i},'_norm.csv')),fileData2)
    end
end
