% This script is to get rid of the NaN elements from the activation
% patterns in the searchspace -- this only needs to be run if there are NaN
% elements in the matrices
close all;clear all;clc

%% Loading in the subject fc_matrices filenames
Hypothesis = {'hypo'};
Contrast = {'TxtR-vs-TxtU'};
DataDir = '/ConnectomeFingerprinting/';

subs = importdata(char(strcat(DataDir, 'subjects.txt')));
nan_lh = importdata(char(strcat(DataDir, 'Outputs/Matrices/', Hypothesis, '/', 'nan_lh.mat')));
nan_rh = importdata(char(strcat(DataDir, 'Outputs/Matrices/', Hypothesis,'/', 'nan_rh.mat')));
filenames1 = [];
filenames2 = [];


for i = 1:23
    subj = subs{i};
    filenames1{i} = strcat(DataDir, 'Outputs/Scan_Activations/', Hypothesis,'/',Contrast,'/rh.',subj,'.csv');
    filenames2{i} = strcat(DataDir, 'Outputs/Scan_Activations/', Hypothesis,'/',Contrast,'/lh.',subj,'.csv')
end 


%% Remove the NaN rows (vertices having 0s in their timeseries) and save them to a csv
%rh
for i = 1:numel(filenames1)
    filename1 = char(filenames1{i});  % Get filename from the cell array
    fileData1 = readmatrix(filename1);
    fileData1(nan_rh) = [];
    csvwrite(char(strcat(DataDir, 'Outputs/Scan_Activations/', Hypothesis, '/',Contrast,'/rh.',subj,'.csv')),fileData1)
end

%lh
for i = 1:numel(filenames2)
    filename2 = char(filenames2{i});  % Get filename from the cell array
    fileData2 = readmatrix(filename2);
    fileData2(nan_lh) = [];
    csvwrite(char(strcat(DataDir, 'Outputs/Scan_Activations/', Hypothesis, '/',Contrast,'/lh.',subj,'.csv')),fileData2)
end









