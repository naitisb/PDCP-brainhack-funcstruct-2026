#!/bin/bash
# Extract subject IDs that have both fMRI and DTI from participants.tsv

# Create output directory if it doesn't exist
mkdir -p "/Volumes/My Passport/BrainHack2026/Data/subject_lists"

# Extract subjects with both DTI and fMRI (source_modality contains both)
awk -F'\t' 'NR>1 && $2 ~ /DTI/ && $2 ~ /fMRI/ {print $1}' \
    "/Volumes/My Passport/BrainHack2026/Data/participants.tsv" \
    > "/Volumes/My Passport/BrainHack2026/Data/subject_lists/fmri_dti_subjects.txt"

echo "Created subject list at Data/subject_lists/fmri_dti_subjects.txt"
