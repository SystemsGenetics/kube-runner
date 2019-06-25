#!/bin/bash
# Run a nextflow pipeline on a Kubernetes cluster.

# parse command-line arguments
if [[ $# != 3 ]]; then
	echo "usage: $0 <pvc-name> <pipeline> <options>"
	exit -1
fi

PVC_NAME="$1"
PIPELINE="$2"
OPTIONS="$3"
POD_NAME="$USER-run-$(echo $PIPELINE | tr /. - | tr [:upper:] [:lower:])-$(printf %04x $RANDOM)"
SPEC_FILE="pod.yaml"

PVC_PATH="/workspace"
CFG_PATH="/etc/nextflow"

# write pod spec to file
cat > $SPEC_FILE <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: $POD_NAME
data:
  init.sh: "mkdir -p ''$PVC_PATH/$USER''; if [ -d ''$PVC_PATH/$USER'' ]; then cd ''$PVC_PATH/$USER''; else echo ''Cannot create directory: $PVC_PATH/$USER''; exit 1; fi; [ -f $CFG_PATH/scm ] && ln -s $CFG_PATH/scm $NXF_HOME/scm; [ -f $CFG_PATH/nextflow.config ] && cp $CFG_PATH/nextflow.config $PWD/nextflow.config; "
---
apiVersion: batch/v1
kind: Job
metadata:
  name: $POD_NAME
spec:
  completions: 1
  ttlSecondsAfterFinished: 100
  template:
    spec:
      containers:
      - name: $POD_NAME
        image: nextflow/nextflow:19.04.0
        imagePullPolicy: IfNotPresent
        env:
        - name: NXF_WORK
          value: $PVC_PATH/$USER/work
        - name: NXF_ASSETS
          value: $PVC_PATH/projects
        - name: NXF_EXECUTOR
          value: k8s
        command:
        - /bin/bash
        - -c
        - source $CFG_PATH/init.sh; nextflow run $PIPELINE $OPTIONS
        resources:
          limits:
            cpu: 1
            memory: 4Gi
          requests:
            cpu: 1
            memory: 256Mi
        volumeMounts:
        - name: vol-1
          mountPath: $PVC_PATH
        - name: vol-2
          mountPath: $CFG_PATH
      restartPolicy: Never
      volumes:
      - name: vol-1
        persistentVolumeClaim:
          claimName: $PVC_NAME
      - name: vol-2
        configMap:
          name: $POD_NAME
EOF

# create pod
kubectl create -f $SPEC_FILE

# cleanup
rm -f $SPEC_FILE
