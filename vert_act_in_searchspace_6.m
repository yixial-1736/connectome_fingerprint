%% This script extracts activation values from all of the vertices within the searchspace.
close all;clear all;clc
Hypothesis = {'hypo5'};
DataDir = '/projectnb/sternlab/kisenburg/ConnectomeFingerprinting/';
RavensDir = '/projectnb/sternlab/kisenburg/RPMS/freesurfer/';
subs = importdata(char(strcat(DataDir, '/Code/Ridge/subjects.txt')));
NodePath = '/projectnb/sternlab/kisenburg/mk_annot_TM/7Nets/';
LeftNodes = importdata(strcat(NodePath, 'lh.nodes.txt')); LeftNodes = LeftNodes(2:end);
RightNodes = importdata(strcat(NodePath, 'rh.nodes.txt')); RightNodes = RightNodes(2:end);

%% MODIFY SEARCH SPACE HERE 
% LPFC
lpfc_lh_names_loc = contains(LeftNodes, 'Cont_PFCl');
lpfc_rh_names_loc = contains(RightNodes, 'Cont_PFCl');

%lpfc_lh_names_loc = strcmp(LeftNodes, '7Networks_LH_Vis_1') | strcmp(LeftNodes, '7Networks_LH_Vis_2') | strcmp(LeftNodes, '7Networks_LH_Vis_3') | strcmp(LeftNodes, '7Networks_LH_Vis_4') | strcmp(LeftNodes, '7Networks_LH_Vis_5');
%lpfc_rh_names_loc = strcmp(RightNodes, '7Networks_RH_Vis_1') | strcmp(RightNodes, '7Networks_RH_Vis_2') | strcmp(RightNodes, '7Networks_RH_Vis_3') | strcmp(RightNodes, '7Networks_RH_Vis_4') | strcmp(RightNodes, '7Networks_RH_Vis_5');
lpfc_lh = LeftNodes(lpfc_lh_names_loc);
lpfc_rh = RightNodes(lpfc_rh_names_loc);

searchlabelnames={lpfc_lh, lpfc_rh};
hemis = {'lh','rh'};
%% MODIFY CONTRAST HERE
Contrast = {'SymR-vs-SymU'};

for n = 1:length(subs)
    sub_orig = subs{n};
    subj = erase(subs{n}, '_'); %fix filenames
    for i = 1:2
        searchlabels = searchlabelnames{i};
        MRIfilename = char(strcat(RavensDir, 'sub-',subj,'/ravens/Ravens.sm3.fsaverage.',hemis{i},'/', Contrast,'/z.nii.gz'));
        a=MRIread(MRIfilename); % Read in MRI File
        v_act = a.vol; % activation of each vertex
        annotfilename = strcat(DataDir, 'Scan_Data/fsaverage/label/',hemis{i},'.Schaefer2018_400Parcels_7Networks_order.annot');
        [v, L, ct] = read_annotation(annotfilename); % Read in annotation info
        inds = [];
        for j = 1:length(searchlabels) % Loop over labels
            idx=find(ismember(ct.struct_names,searchlabels(j))); % Find index corresponding to label name
            label_id=ct.table(idx,5); % Find ID corresponding to label
            y=find(L==label_id); % Find indices of vertices belonging to label
            inds = [inds y.'];
        end
        v_act=v_act(inds);
        csvwrite(char(strcat(DataDir, 'Outputs/Scan_Activations/', Hypothesis, '/',Contrast,'/',hemis{i},'.',sub_orig,'.csv')),v_act);
    end
end