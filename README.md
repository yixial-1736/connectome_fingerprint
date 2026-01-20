# connectome_fingerprint
This is the official repo of the connectome fingerprint project -  "Connectome Fingerprinting Predicts Prefrontal Cortical Activation During Abstract Reasoning."

This folder holds all the code for the subject-specific ridge-regression connectome fingerprinting analysis. 


- Scripts:
All the scripts are saved in the following directory:
'/connectome_fingerpint/Scripts/'

The next codes need to be updated based on the hypotheses:
1. `vertices_time_series.m` - 																														
    -Function: `make_search_space.m` - This uses the annotation file to extract these values.
2. `make_fc_mx.qsub` & `make_fc_mx.m` - The qsub wrapper runs the functional connectivity matrices for all of the subjects. 
3. `zero_v_ts.m` - Finds any nan values in the resting-state connectivity matrix and then removes them from that matrix. This will need to be done later on to the activation files and the group average data. 
4. `vert_act_in_searchspace.m` -Extract task-based activity values from the parcels in the searchspace. 
5. `remove_v_act.m` - Removes the vertices that had nan values in the search-space activation variable. 
6.`ridge_wrapper_lh.qsub` & `ridge_function_network_lh.py` - Runs the ridge regression analysis in parallel for the left hemisphere. (Note in this Github Project, we used simulated FC matrices)
7.`ridge_wrapper_rh.qsub` & `ridge_function_network_rh.py` - Runs the ridge regression analysis in parallel for the right hemisphere. 
8. 'permutation_test.ipynb' - permuted the ridge model’s predicted activation pattern; and the similiarity to the actual activations is compared between ridge predictions and permutations.

Outputs of each script:
1. `vertices_time_series_3.m` - vert_ts.m file saved as $hemi.$SUB.Schaeferc.0$run.mat (this variables holds the time-series from all vertices in the search-space, which is based off of the hypothesis).
2. `fc_mx_wrapper_mx.m` - corrmx_norm.m saved as $hemi.$SUB._norm.csv (this variable holds the functional connectivity matrices between search-space vertices and Schaefer parcels (with the exception of the parcels of the search space) to be used in the ridge regression).
3. `zero_v_ts_5.m` - fileData1.m & fileData2.m files saved in the same way as the previous step ($hemi.$SUB._norm.csv).
4. `vert_act_in_searchspace_6.m` - v_act.m file saved as $hemi.$SUB.csv (This holds activation values from the searchspace). 
5. `remove_v_act_7.m` - fileData1.m & fileData2.m files saved in the same way as the previous step ($hemi.$SUB.csv).

RIDGE OUTPUT VARIABLES:
-${hemi}_${Contrast}_Coef${SUB}.csv: This represents the coefficients of the ridge regression, which is the size of 1 x p (parcels) and represents the magnitude of the prediction of the input variable to the search-space. Whether it's positive or negative suggests the direction of the magnitude. 
-${hemi}_${Contrast}_pred_${SUB}.csv: This contains the ridge's predicted activation values for all vertices within the searchspace.
-${hemi}_${Contrast}_${SUB}: This file contains three variables, a: the selected alpha values for the ridge, pearson correlation values between the prediction and the actual data, and p-values. 

- Labels and atlas file:
1. Pacels id list: '/connectome_fingerprint/networks/'
Left hemisphere: 'lh.nodes.txt'
Right hemisphere: 'rh.nodes.txt'

2. Schafer atlas: '/connectome_fingerprint/label/'
Left hemisphere: 'lh.Schaefer2018_400Parcels_7Networks_order.annot'
Right hemisphere: 'rh.Schaefer2018_400Parcels_7Networks_order.annot'

-Ouptuts:
'outputs/Ridge_Results/TxtR-vs-TxtU/'
These saved the simulated results from the subjects generated from the 'connectome_fingerprint/Scripts/ridge_simulated_data.py'

Hypotheses thus far:
1. Ridge prediction of SymR-vs-SymU & TxtR-vs-TxtU in CCN lPFC using whole-brain connectomes. 
2. Ridge prediction of SymR-vs-SymU & TxtR-vs-TxtU in CCN lPFC using whole-brain connectomes minus one network for all 7 network iterations. 
3. Ridge prediction of SymR-vs-SymU & TxtR-vs-TxtU in CCN lPFC using two different functional connectomes: SM, Vis, Limbic, VAN & DMN, CCN, DAN .
4. Ridge prediction of SymR-vs-SymU & TxtR-vs-TxtU in CCN lPFC using two different functional connectomes: SM, Vis, Limbic & DMN, CCN, DAN, VAN. 
