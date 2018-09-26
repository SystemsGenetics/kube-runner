#!/bin/bash
# Fetch output data from each container in a pod.

# command-line arguments
if [[ $# != 3 ]]; then
    echo "usage: $0 <pod-name> <num-containers> <output-dir>"
    exit -1
fi

NAMESPACE="deepgtex-prp"
POD_NAME="$1"
NUM_CONTAINERS=$2
OUTPUT_DIR="$3"

mkdir -p $OUTPUT_DIR

# Copy output data from each container to local machine
for i in $(seq 1 $NUM_CONTAINERS); do
    CONTAINER_NAME="$POD_NAME-$(printf "%03d" $i)"

    echo "Copying output data from $CONTAINER_NAME..."
    kubectl cp "$NAMESPACE/$POD_NAME:/root/output" -c $CONTAINER_NAME "$OUTPUT_DIR/$CONTAINER_NAME" &
done
