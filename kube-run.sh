#!/bin/bash
# Run a nextflow pipeline on a Kubernetes cluster.

# parse command-line arguments
if [[ $# != 3 ]]; then
	echo "usage: $0 <pipeline> <pvc-name> <pod-name>"
	exit -1
fi

PIPELINE="$1"
PVC_NAME="$2"
POD_NAME="$3"
SPEC_FILE="pod.yaml"

# write pod spec to file
cat > $SPEC_FILE <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: $POD_NAME
data:
  init.sh: "mkdir -p ''/workspace/$USER''; if [ -d ''/workspace/$USER'' ]; then cd ''/workspace/$USER''; else echo ''Cannot create directory: /workspace/$USER''; exit 1; fi; [ -f /etc/nextflow/scm ] && ln -s /etc/nextflow/scm $NXF_HOME/scm; [ -f /etc/nextflow/nextflow.config ] && cp /etc/nextflow/nextflow.config $PWD/nextflow.config; "
---
apiVersion: v1
kind: Pod
metadata:
  name: $POD_NAME
spec:
  containers:
  - name: $POD_NAME
    image: nextflow/nextflow:19.04.0
    imagePullPolicy: IfNotPresent
    env:
    - name: NXF_WORK
      value: /workspace/$USER/work
    - name: NXF_ASSETS
      value: /workspace/projects
    - name: NXF_EXECUTOR
      value: k8s
    command:
    - /bin/bash
    - -c
    - source /etc/nextflow/init.sh; nextflow run $PIPELINE
    resources:
      limits:
        memory: 4Gi
      requests:
        memory: 256Mi
    volumeMounts:
    - name: vol-1
      mountPath: /workspace
    - name: vol-2
      mountPath: /etc/nextflow
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
