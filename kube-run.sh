#!/bin/bash
# Run a job on a Kubernetes cluster.

# parse command-line arguments
if [[ $# != 5 ]]; then
	echo "usage: $0 <job-name> <image-name> <job-size> <input-dir> <output-dir>"
	exit -1
fi

JOB_CONFIG="job.yaml"
JOB_NAME="$1"
IMAGE_NAME="$2"
JOB_SIZE=$3
LOCAL_INPUT="$4"
LOCAL_OUTPUT="$5"
REMOTE_INPUT="/root/input"
REMOTE_OUTPUT="/root/output"

# write job config to file
cat > $JOB_CONFIG <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: $JOB_NAME
spec:
  completions: $JOB_SIZE
  parallelism: $JOB_SIZE
  template:
    spec:
      containers:
      - name: $JOB_NAME
        image: $IMAGE_NAME
        imagePullPolicy: Always
        args: ["sleep", "infinity"]
        resources:
          limits:
            cpu: 4
            memory: "8Gi"
            nvidia.com/gpu: 1
      nodeSelector: {}
      restartPolicy: Never
  backoffLimit: 4
EOF

# print the generated job config
echo "Job configuration:"
echo
cat $JOB_CONFIG
echo

# create job
echo "Creating job..."
echo
kubectl create -f $JOB_CONFIG
echo

# wait for all pods to initialize
JOB_STATUS=""

while [[ $JOB_STATUS != "Running" ]]; do
	echo "Waiting for job to initialize...$JOB_STATUS"
	sleep 5
	JOB_STATUS="$(kubectl get pods --no-headers --selector=job-name=$JOB_NAME | awk '{ print $3 }' | uniq)"
	JOB_STATUS="$(echo $JOB_STATUS)"
done

# get list of pod names
PODS=$(kubectl get pods --selector=job-name=$JOB_NAME --output=jsonpath={.items..metadata.name})

# display pod-node assignments
kubectl get pods -o wide --sort-by="{.spec.nodeName}"

# copy input data to each pod
i=0

for POD_NAME in $PODS; do
	echo "Copying input data to $POD_NAME..."
	kubectl cp "$LOCAL_INPUT" "$POD_NAME:$REMOTE_INPUT" &

	i=$((i + 1))
done
time wait

# execute command script on each pod
i=0

for POD_NAME in $PODS; do
	echo "Executing command script on $POD_NAME..."
	kubectl exec "$POD_NAME" -- bash -c "export INPUT_DIR=$REMOTE_INPUT OUTPUT_DIR=$REMOTE_OUTPUT JOB_RANK=$i JOB_SIZE=$JOB_SIZE; mkdir -p $REMOTE_OUTPUT; bash $REMOTE_INPUT/command.sh" &

	i=$((i + 1))
done
time wait

# copy output data from each pod
mkdir -p $LOCAL_OUTPUT

for POD_NAME in $PODS; do
	echo "Copying output data from $POD_NAME..."
	kubectl cp "$POD_NAME:$REMOTE_OUTPUT" "$LOCAL_OUTPUT/$POD_NAME"
done

# delete job
kubectl delete job $JOB_NAME
