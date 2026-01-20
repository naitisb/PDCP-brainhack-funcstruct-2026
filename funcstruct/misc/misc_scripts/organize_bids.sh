#!/bin/bash
# BIDS Organization Script for BrainHack2026
# This script reorganizes DTI and fMRI data into BIDS derivatives format

set -e  # Exit on error

DATA_DIR="/Volumes/My Passport/BrainHack2026/Data"
DTI_SOURCE="$DATA_DIR/Preprocessed_DTI_MartinaMin"
FMRI_SOURCE="$DATA_DIR/Preprocessed_fMRI_AlizaJaffer"
DTI_DEST="$DATA_DIR/derivatives/DTI"
FMRI_DEST="$DATA_DIR/derivatives/fMRI"
ROI_DEST="$DATA_DIR/derivatives/ROIs"

echo "=========================================="
echo "BIDS Organization Script"
echo "=========================================="

# ====================
# Process DTI files
# ====================
echo ""
echo "Processing DTI files..."
echo "------------------------"

cd "$DTI_SOURCE"
for subdir in sub-*/; do
    # Extract subject ID without 'a' suffix (e.g., sub-10069a -> 10069)
    subid=$(echo "$subdir" | sed 's/sub-\(.*\)a\//\1/')

    # Create BIDS directory structure
    bids_dir="$DTI_DEST/sub-${subid}/ses-02y/dwi"
    mkdir -p "$bids_dir"

    # Move and rename FA file
    if [ -f "${subdir}"*_fa.nii.gz ]; then
        mv "${subdir}"*_fa.nii.gz "${bids_dir}/sub-${subid}_ses-02y_desc-FA_mdp.nii.gz"
    fi

    # Move and rename MD file
    if [ -f "${subdir}"*_md.nii.gz ]; then
        mv "${subdir}"*_md.nii.gz "${bids_dir}/sub-${subid}_ses-02y_desc-MD_mdp.nii.gz"
    fi

    # Move and rename preprocessed DWI file
    if [ -f "${subdir}"*_preprocessed_1mm.mif ]; then
        mv "${subdir}"*_preprocessed_1mm.mif "${bids_dir}/sub-${subid}_ses-02y_desc-preproc_dwi.mif"
    fi

    echo "  Processed DTI: sub-${subid}"
done

# ====================
# Process fMRI files
# ====================
echo ""
echo "Processing fMRI files..."
echo "------------------------"

cd "$FMRI_SOURCE"
for file in *_denoised_data_clean_transformed.nii; do
    [ -f "$file" ] || continue

    # Extract subject ID from filename
    # Handle patterns: 1048_denoised..., V_10914_denoised..., M_7632_2Y_denoised..., C_20395_2Y_TR2_denoised...

    # Remove the _denoised_data_clean_transformed.nii suffix
    basename="${file%_denoised_data_clean_transformed.nii}"

    # Extract numeric ID (remove prefixes like V_, M_, C_ and suffixes like _2Y, _2Y_TR2)
    subid=$(echo "$basename" | sed -E 's/^[A-Z]_//; s/_2Y.*$//')

    # Create BIDS directory structure
    bids_dir="$FMRI_DEST/sub-${subid}/ses-02y/func"
    mkdir -p "$bids_dir"

    # Move and rename file
    mv "$file" "${bids_dir}/sub-${subid}_ses-02y_task-rest_desc-denoised_bold.nii"

    echo "  Processed fMRI: sub-${subid}"
done

# ====================
# Move ROI masks
# ====================
echo ""
echo "Moving ROI masks..."
echo "-------------------"

cd "$FMRI_SOURCE"
for roi_file in *.nii.gz; do
    [ -f "$roi_file" ] || continue
    mv "$roi_file" "$ROI_DEST/"
    echo "  Moved ROI: $roi_file"
done

# ====================
# Clean up empty directories
# ====================
echo ""
echo "Cleaning up empty directories..."
echo "---------------------------------"

# Remove empty subject directories in DTI source
cd "$DTI_SOURCE"
for subdir in sub-*/; do
    if [ -d "$subdir" ] && [ -z "$(ls -A "$subdir")" ]; then
        rmdir "$subdir"
        echo "  Removed empty: $subdir"
    fi
done

# ====================
# Generate participants.tsv
# ====================
echo ""
echo "Generating participants.tsv..."
echo "-------------------------------"

# Collect all unique subject IDs from both DTI and fMRI
participants_file="$DATA_DIR/participants.tsv"
echo -e "participant_id\tsource_modality" > "$participants_file"

# Get subjects from DTI
for subdir in "$DTI_DEST"/sub-*/; do
    [ -d "$subdir" ] || continue
    subid=$(basename "$subdir")
    echo -e "${subid}\tDTI" >> "$participants_file"
done

# Get subjects from fMRI that aren't already listed
for subdir in "$FMRI_DEST"/sub-*/; do
    [ -d "$subdir" ] || continue
    subid=$(basename "$subdir")
    if ! grep -q "^${subid}\t" "$participants_file"; then
        echo -e "${subid}\tfMRI" >> "$participants_file"
    else
        # Update to show both modalities
        sed -i '' "s/^${subid}\tDTI$/${subid}\tDTI,fMRI/" "$participants_file"
    fi
done

# Sort the file (keeping header)
head -1 "$participants_file" > "${participants_file}.tmp"
tail -n +2 "$participants_file" | sort -t'-' -k2 -n >> "${participants_file}.tmp"
mv "${participants_file}.tmp" "$participants_file"

echo "  Created participants.tsv"

echo ""
echo "=========================================="
echo "BIDS organization complete!"
echo "=========================================="
echo ""
echo "Output structure:"
echo "  $DATA_DIR/"
echo "  ├── dataset_description.json"
echo "  ├── participants.tsv"
echo "  └── derivatives/"
echo "      ├── DTI/"
echo "      ├── fMRI/"
echo "      └── ROIs/"
