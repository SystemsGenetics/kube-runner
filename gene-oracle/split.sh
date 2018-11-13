#!/bin/bash

# parse command-line arguments
if [[ $# != 2 ]]; then
	echo "usage: $0 <infile> <num-chunks>"
	exit -1
fi

INFILE="$1"
NUM_FILES=$2
PREFIX="$(dirname $INFILE)/$(basename $INFILE txt)"
SUFFIX=".txt"

# split text file into chunks
split --additional-suffix $SUFFIX -d -n r/$NUM_FILES $INFILE $PREFIX
