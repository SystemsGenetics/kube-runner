#!/bin/bash
# Example command script for KINC

# define input/output directories
INPUT_DIR="$HOME/input"
OUTPUT_DIR="$HOME/output"

# define arguments
EMX_FILE="$INPUT_DIR/Yeast.emx"
CCM_FILE="$OUTPUT_DIR/Yeast.ccm"
CMX_FILE="$OUTPUT_DIR/Yeast.cmx"
CLUSMETHOD="none"
CORRMETHOD="pearson"

# set kinc settings
kinc settings set opencl 0:0
kinc settings set threads 4
kinc settings set logging off

# run similarity
kinc run similarity \
	--input $EMX_FILE \
	--ccm $CCM_FILE \
	--cmx $CMX_FILE \
	--clusmethod $CLUSMETHOD \
	--corrmethod $CORRMETHOD
