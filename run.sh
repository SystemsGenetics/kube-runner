#!/bin/bash
# Entrypoint script for Docker image

INPUT_DIR="$HOME/input"

# wait for input data to finish downloading
PREV=0
CURR=1

while [ $PREV != $CURR ]; do
   echo "Downloading input data..."
   sleep 5

   PREV=$CURR
   CURR=$(find $INPUT_DIR -exec stat -c "%Y" \{\} \; | sort -n | tail -1)
done

echo "Download finished."
echo

# run script
echo "Running command.sh..."
echo

sh "$INPUT_DIR/command.sh"
