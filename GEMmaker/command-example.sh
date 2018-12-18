#!/bin/bash
# Example command script for GEMmaker

# define arguments
IRODS_HOST="FULLY.QUALIFIED.DOMAIN.NAME"
IRODS_PORT=1247
IRODS_USER_NAME="USERNAME"
IRODS_ZONE_NAME="scidasZone"
IRODS_INPUT_PATH="/scidasZone/sysbio/experiments/sra2gev/test"
IRODS_OUTPUT_PATH="/scidasZone/sysbio/experiments/test"
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

# download experiment files from iRODS
echo "Downloading experiment files..."

./scripts/irods-load.sh $IRODS_INPUT_PATH input

# run GEMmaker
nextflow -config $CONFIG run main.nf \
	-profile standard \
	-with-report \
	-with-timeline \
	-with-trace

# save output data to iRODS
./scripts/irods-save.sh output $IRODS_OUTPUT_PATH
