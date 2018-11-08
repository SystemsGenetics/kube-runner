#!/bin/bash
# Example command script for KINC

# define arguments
EMX_FILE="$INPUT_DIR/Yeast.emx"
CCM_FILE="$OUTPUT_DIR/Yeast.ccm"
CMX_FILE="$OUTPUT_DIR/Yeast.cmx"
CLUSMETHOD="none"
CORRMETHOD="pearson"

# set kinc settings
kinc settings set opencl 0:0
kinc settings set threads 4
kinc settings set chunkdir $OUTPUT_DIR
kinc settings set logging on

# run similarity
kinc chunkrun $JOB_RANK $JOB_SIZE similarity \
	--input $EMX_FILE \
	--ccm $CCM_FILE \
	--cmx $CMX_FILE \
	--clusmethod $CLUSMETHOD \
	--corrmethod $CORRMETHOD &

sleep 1
acelog localhost:40000
