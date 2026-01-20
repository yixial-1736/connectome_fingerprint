function vert_ts = make_search_space(MRIfilename,annotfilename,searchlabelnames)
% searchlabelnames must be a cell array of strings
a=MRIread(MRIfilename); % Read in MRI File
vert_ts=squeeze(a.vol); % Squeeze down 4D vol to 2D mx of timeseries
[v, L, ct] = read_annotation(annotfilename); % Read in annotation info
% for i = 1:length(searchlabelnames) % Loop over labels
%     idx=find(ismember(ct.struct_names,searchlabelnames(i))); % Find index corresponding to label name
%     label_id=ct.table(idx,5); % Find ID corresponding to label
%     y=find(L==label_id); % Find indices of vertices belonging to label
%     for j=1:length(y);
%         ind = y(j);
%         vert_ts(ind,:)=zeros(1,360); % Set row of vert_ts to zeros if vertex is in search space
%     end 
% end

inds = [];

for i = 1:length(searchlabelnames) % Loop over labels
    idx=find(ismember(ct.struct_names,searchlabelnames(i))); % Find index corresponding to label name
    label_id=ct.table(idx,5); % Find ID corresponding to label
    y=find(L==label_id); % Find indices of vertices belonging to label
    inds = [inds y.'];
end
vert_ts=vert_ts(inds,:);
% example:
% label_names = {'7Networks_LH_Cont_PFCl_4','7Networks_LH_Cont_PFCl_3','7Networks_LH_Cont_PFCl_5','7Networks_LH_Cont_PFCl_6','7Networks_LH_Cont_PFCl_8','7Networks_LH_Cont_PFCl_2'}
% make_search_space('/f.mcpr.sm3.sc.int.bpf.resid.fsaverage.lh.nii.gz','/scan_data/fsaverage/label/lh.Schaefer2018_400Parcels_7Networks_order.annot',label_names)