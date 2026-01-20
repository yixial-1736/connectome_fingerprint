#!/usr/bin/env bash


# Set this with your actual project dir
PROJECT_DIR="/ConnectomeFingerprinting"
MFILE="${PROJECT_DIR}/Code/Ridge/make_fc_mx.m"

# Loop through all subjects
START=1
END=23

matlab -nodisplay -nosplash -nodesktop -r "for k=${START}:${END}; setenv('Sub_ID', num2str(k)); run('${MFILE}'); end; exit;"
