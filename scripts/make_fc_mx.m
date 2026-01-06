clear all;close all;clc

%% This is a script to make the resting-state functional connectivity matrices between the 
%% search space vertices and the whole-brain parcels. This search space is based on group-activation 
%% results.
%hypo 1 is CCN lPFC predicted by whole-brain for the symbolic & perceptual
%hypo 2 is CCN lPFC predicted by whole-brain minus one network (leave-one-network out)
%hypo 3 & 4 are CCN lPFC predicted by different configurations of sensory
%and cognitive network matrices
%hypo 5 is visual IT predicted by the whole-brain
Hypothesis = {'hypo5'}; 
pDir = '/projectnb/sternlab/kisenburg/ConnectomeFingerprinting/';
DataDir = strcat(pDir, 'Scan_Data/timeseries/');
SaveDir = char(strcat(pDir,'Outputs/Matrices/',Hypothesis));
NodePath = '/projectnb/sternlab/kisenburg/mk_annot_TM/7Nets/';
LeftNodes = importdata(strcat(NodePath, 'lh.nodes.txt')); LeftNodes = LeftNodes(2:end);
RightNodes = importdata(strcat(NodePath, 'rh.nodes.txt')); RightNodes = RightNodes(2:end);

%% MODIFY SEARCH SPACE HERE 
% LPFC CCN
%lpfc_lh_names_loc = contains(LeftNodes, 'Cont_PFCl');
%lpfc_rh_names_loc = contains(RightNodes, 'Cont_PFCl');

lpfc_lh_names_loc = strcmp(LeftNodes, '7Networks_LH_Vis_1') | strcmp(LeftNodes, '7Networks_LH_Vis_2') | strcmp(LeftNodes, '7Networks_LH_Vis_3') | strcmp(LeftNodes, '7Networks_LH_Vis_4') | strcmp(LeftNodes, '7Networks_LH_Vis_5');
lpfc_rh_names_loc = strcmp(RightNodes, '7Networks_RH_Vis_1') | strcmp(RightNodes, '7Networks_RH_Vis_2') | strcmp(RightNodes, '7Networks_RH_Vis_3') | strcmp(RightNodes, '7Networks_RH_Vis_4') | strcmp(RightNodes, '7Networks_RH_Vis_5');
lh_parcel = find(lpfc_lh_names_loc == 1);
rh_parcel = find(lpfc_rh_names_loc == 1);

subs = importdata(char(strcat(pDir,'Code/Ridge/subjects.txt')));
hemis = {'lh','rh'};
removeparcels={lh_parcel, rh_parcel};
mkdir(SaveDir);
s = str2num(getenv('SGE_TASK_ID'));

subj = subs{s}; 
runs = importdata(char(strcat(pDir,'Scan_Data/',subj,'/rest/runs')));
for i = 1:2
    v_ts1 = load(char(strcat(DataDir,'vertex/',Hypothesis,'/',hemis{i},'.',subj,'.Schaeferc_r0',num2str(runs(1)),'.mat')));
    v_ts2 = load(char(strcat(DataDir,'vertex/',Hypothesis,'/',hemis{i},'.',subj,'.Schaeferc_r0',num2str(runs(2)),'.mat')));
    v_ts3 = load(char(strcat(DataDir,'vertex/',Hypothesis,'/',hemis{i},'.',subj,'.Schaeferc_r0',num2str(runs(3)),'.mat')));
    v_ts = horzcat(v_ts1.vert_ts,v_ts2.vert_ts,v_ts3.vert_ts);
    p_ts1 = importdata(strcat(DataDir,'parcels/',hemis{i},'.',subj,'.Schaefer_r0',num2str(runs(1)),'.dat'));
    p_ts2 = importdata(strcat(DataDir,'parcels/',hemis{i},'.',subj,'.Schaefer_r0',num2str(runs(2)),'.dat'));
    p_ts3 = importdata(strcat(DataDir,'parcels/',hemis{i},'.',subj,'.Schaefer_r0',num2str(runs(3)),'.dat'));
    p_ts = vertcat(p_ts1,p_ts2,p_ts3);
    removethese = removeparcels{1,i};
    p_ts(:, removethese)=[];
    v_ts = v_ts';
    corrmx = zeros(size(v_ts,2),size(p_ts,2));
    for x = 1:size(p_ts,2)
        for y = 1:size(v_ts,2)
            corrmx(y,x)= corr(v_ts(:,y),p_ts(:,x));
        end
    end
    corrmx_norm = atanh(corrmx);
    csvwrite(strcat(SaveDir,hemis{i},'.',subj,'_norm.csv'),corrmx_norm);
end

