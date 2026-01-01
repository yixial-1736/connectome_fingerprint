# connectome_fingerprint
This is the official repo of the connectome fingerprint project -  "Connectome Fingerprinting Predicts Prefrontal Cortical Activation During Abstract Reasoning."

This folder holds all the code for the subject-specific ridge-regression connectome fingerprinting analysis. 

The following codes only need to be run once, when starting all analyses:
1. `extract_schaefer_1.sh` - Extract the time-series from all of the schaefer parcellations.
2. `copy_timeseries_2.sh` - Move those parcellations into a separate folder for analysis purposes.

The next codes need to be updated based on the hypotheses:
3. `vertices_time_series_3.m` - 																														
    -Function: `make_search_space.m` - This uses the annotation file to extract these values.
4. `make_fc_mx_4.qsub` & `make_fc_mx.m` - The qsub wrapper runs the functional connectivity matrices for all of the subjects. 
5. `zero_v_ts_5.m` - Finds any nan values in the resting-state connectivity matrix and then removes them from that matrix. This will need to be done later on to the activation files and the group average data. 
6. `vert_act_in_searchspace_6.m` -Extract task-based activity values from the parcels in the searchspace. 
7. `remove_v_act_7.m` - Removes the vertices that had nan values in the search-space activation variable. 
8.`ridge_wrapper_lh_8.qsub` & `ridge_lh.py` - Runs the ridge regression analysis in parallel for the left hemisphere. 
9.`ridge_wrapper_rh_9.qsub` & `ridge_rh.py` - Runs the ridge regression analysis in parallel for the right hemisphere. 

Next steps take place in the 'Group' folder.

Outputs of each script:
1. `extract_schaefer_1.sh` - $hemi.$SUB.Schaefer.sum & $hemi.$SUB.Schaefer.dat 
2. `copy_timeseries_2.qsub` - $hemi.$SUB.Schaefer.dat moved to new space (this variable holds the time-series from each parcel in the Schaefer atlas).
3. `vertices_time_series_3.m` - vert_ts.m file saved as $hemi.$SUB.Schaeferc.0$run.mat (this variables holds the time-series from all vertices in the search-space, which is based off of the hypothesis).
4. `fc_mx_wrapper_mx.m` - corrmx_norm.m saved as $hemi.$SUB._norm.csv (this variable holds the functional connectivity matrices between search-space vertices and Schaefer parcels (with the exception of the parcels of the search space) to be used in the ridge regression).
5. `zero_v_ts_5.m` - fileData1.m & fileData2.m files saved in the same way as the previous step ($hemi.$SUB._norm.csv).
6. `vert_act_in_searchspace_6.m` - v_act.m file saved as $hemi.$SUB.csv (This holds activation values from the searchspace). 
7. `remove_v_act_7.m` - fileData1.m & fileData2.m files saved in the same way as the previous step ($hemi.$SUB.csv).

RIDGE OUTPUT VARIABLES:
-${hemi}_${Contrast}_Coef${SUB}.csv: This represents the coefficients of the ridge regression, which is the size of 1 x p (parcels) and represents the magnitude of the prediction of the input variable to the search-space. Whether it's positive or negative suggests the direction of the magnitude. 
-${hemi}_${Contrast}_pred_${SUB}.csv: This contains the ridge's predicted activation values for all vertices within the searchspace.
-${hemi}_${Contrast}_${SUB}: This file contains three variables, a: the selected alpha values for the ridge, pearson correlation values between the prediction and the actual data, and p-values. 

Hypotheses thus far:
1. Ridge prediction of SymR-vs-SymU & TxtR-vs-TxtU in CCN lPFC using whole-brain connectomes. 
2. Ridge prediction of SymR-vs-SymU & TxtR-vs-TxtU in CCN lPFC using whole-brain connectomes minus one network for all 7 network iterations. 
3. Ridge prediction of SymR-vs-SymU & TxtR-vs-TxtU in CCN lPFC using two different functional connectomes: SM, Vis, Limbic, VAN & DMN, CCN, DAN .
4. Ridge prediction of SymR-vs-SymU & TxtR-vs-TxtU in CCN lPFC using two different functional connectomes: SM, Vis, Limbic & DMN, CCN, DAN, VAN. 
