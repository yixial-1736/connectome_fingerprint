clear all;close all;clc
%% This extracts the resting-state time-series from all vertices within our search space. 
%% The final vert_ts should be saved in a hypothesis-specific folder, so that we know the ROIs of the vertices 

%CHANGE HYPOTHESIS BELOW%
Hypothesis = {'hypo5'};
pDir = '/projectnb/sternlab/kisenburg/ConnectomeFingerprinting/';
DataDir = (strcat(pDir, 'Scan_Data/'));
SaveDir = char((strcat(DataDir, 'timeseries/vertex/',Hypothesis, '/')));
subs = importdata(strcat(pDir, 'Code/Ridge/subjects.txt'));

% Labels for left and right hemisphere searchspace
%import node names
NodePath = '/projectnb/sternlab/kisenburg/mk_annot_TM/7Nets/';
LeftNodes = importdata(strcat(NodePath, 'lh.nodes.txt')); LeftNodes = LeftNodes(2:end);
RightNodes = importdata(strcat(NodePath, 'rh.nodes.txt')); RightNodes = RightNodes(2:end);

%% MODIFY SEARCH SPACE HERE 
% LPFC CCN
%lpfc_lh_names_loc = contains(LeftNodes, 'Cont_PFCl');
%lpfc_rh_names_loc = contains(RightNodes, 'Cont_PFCl');

% IT LIMBIC & VISUAL 
lpfc_lh_names_loc = strcmp(LeftNodes, '7Networks_LH_Vis_1') | strcmp(LeftNodes, '7Networks_LH_Vis_2') | strcmp(LeftNodes, '7Networks_LH_Vis_3') | strcmp(LeftNodes, '7Networks_LH_Vis_4') | strcmp(LeftNodes, '7Networks_LH_Vis_5');
lpfc_rh_names_loc = strcmp(RightNodes, '7Networks_RH_Vis_1') | strcmp(RightNodes, '7Networks_RH_Vis_2') | strcmp(RightNodes, '7Networks_RH_Vis_3') | strcmp(RightNodes, '7Networks_RH_Vis_4') | strcmp(RightNodes, '7Networks_RH_Vis_5');
lpfc_lh = LeftNodes(lpfc_lh_names_loc);
lpfc_rh = RightNodes(lpfc_rh_names_loc);

searchlabelnames={lpfc_lh, lpfc_rh};
hemis = {'lh','rh'};
mkdir(SaveDir);

for n = 1:length(subs)
    subj = subs{n};
    runs = importdata(strcat(DataDir,subj,'/rest/runs'));
    for i = 1:length(runs)
        for j = 1:length(hemis)
            mripath = strcat(DataDir,subj,'/rest/0',num2str(runs(i)),'/f.mcpr.sm3.sc.int.bpf.resid.fsaverage.',hemis{j},'.nii.gz');
            annotpath = strcat(DataDir, 'fsaverage/label/',hemis{j},'.Schaefer2018_400Parcels_7Networks_order.annot');
            vert_ts = make_search_space(mripath,annotpath,searchlabelnames{j});
            save(strcat(SaveDir,hemis{j},'.',subj,'.Schaeferc_r0',num2str(runs(i)),'.mat'),'vert_ts');
        end
    end
end
