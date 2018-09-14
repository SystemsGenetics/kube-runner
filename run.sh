#!/bin/sh
# Entrypoint script for Docker image

DATA_DIR="data"

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

cd $DATA_DIR
sh ./command.sh
