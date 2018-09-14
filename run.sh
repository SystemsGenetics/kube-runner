#!/bin/sh
# Entrypoint script for Docker image

UNUSED=$1
DATA_DIR="$2"

echo $@

# Wait for input data to finish downloading
PREV=0
CURR=1

while [ $PREV != $CURR ]; do
   echo "Downloading data..."
   sleep 5

   PREV=$CURR
   CURR=$(find $DATA_DIR -exec stat -c "%Y" \{\} \; | sort -n | tail -1)
done

echo "Download finished."

# run script
echo "Running command.sh..."

sh $DATA_DIR/command.sh
