#!/bin/bash
# Example command script for GEMmaker

# define input/output directories
INPUT_DIR="$HOME/input"
OUTPUT_DIR="$HOME/output"

# define arguments
IRODS_HOST="FULLY.QUALIFIED.DOMAIN.NAME"
IRODS_PORT=1247
IRODS_USER_NAME="USERNAME"
IRODS_ZONE_NAME="scidasZone"
EXPERIMENT_PATH="/scidasZone/sysbio/experiments/sra2gev/test"
CONFIG="$INPUT_DIR/nextflow.config"

# change to GEMmaker directory
cd $HOME/GEMmaker

# create iRODS configuration
mkdir ~/.irods
cat > ~/.irods/irods_environment.json <<EOF
{
  "irods_host": "$IRODS_HOST",
  "irods_port": $IRODS_PORT,
  "irods_user_name": "$IRODS_USER_NAME",
  "irods_zone_name": "$IRODS_ZONE_NAME"
}
EOF

# initialize iRODS
iinit

# download experiment files from iRODS
echo "Downloading experiment files..."

iget -rv $EXPERIMENT_PATH experiment

# run GEMmaker
nextflow -config $CONFIG run main.nf \
   -profile standard \
   -with-report \
   -with-timeline \
   -with-trace

# move outputs to output directory
mv report.html timeline.html trace.txt $OUTPUT_DIR
mv SRX* Sample_* $OUTPUT_DIR
