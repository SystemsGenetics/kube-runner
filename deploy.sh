#!/bin/bash
# Deploy a pod to a Kubernetes cluster.

# command-line arguments
if [[ $# != 4 ]]; then
	echo "usage: $0 <pod-name> <image-name> <num-containers> <input-dir>"
	exit -1
fi

NAMESPACE="deepgtex-prp"
POD_FILE="pod.yaml"
POD_NAME="$1"
IMAGE_NAME="$2"
NUM_CONTAINERS=$3
INPUT_DIR="$4"

# TODO: refactor pod into a job
# TODO: Add "nodeSelector" attribute to deploy on specific nodes
#       https://kubernetes.io/docs/concepts/configuration/assign-pod-node/

# Generate beginning of pod config
cat > $POD_FILE <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: $POD_NAME
spec:
  containers:
EOF

# Add framework of n containers to end of file
for i in $(seq 1 $NUM_CONTAINERS); do
	CONTAINER_NAME="$POD_NAME-$(printf "%03d" $i)"

	cat >> $POD_FILE <<EOF
  - name: $CONTAINER_NAME
    image: $IMAGE_NAME
    imagePullPolicy: Always
    resources:
      limits:
        nvidia.com/gpu: 1
EOF
done

# Confirm that the pod framework is correct
echo "Pod framework:"
echo
cat $POD_FILE
echo

# Create pod
echo "Creating pod..."
echo
kubectl create -f $POD_FILE
echo

# TODO: pod gets stuck in CrashLoopBackoff

# Wait for pod to start
POD_STATUS=""

while [ "$POD_STATUS" != "Running" ]; do
	echo "Waiting for pod to start...$POD_STATUS"
	sleep 1
	POD_STATUS="$(kubectl get pod $POD_NAME | awk '{ print $3 }' | tail -n +2)"
done

# Confirm that the pod is running correctly
echo
kubectl get pod $POD_NAME
echo

# Copy input data and start each container
for i in $(seq 1 $1); do
	CONTAINER_NAME="$POD_NAME-$(printf "%03d" $i)"

	echo "Copying input data to $CONTAINER_NAME..."
	kubectl cp "$INPUT_DIR" "$NAMESPACE/$POD_NAME:/root/input" -c $CONTAINER_NAME &

	echo "Starting $CONTAINER_NAME..."
	kubectl exec "$POD_NAME" -c $CONTAINER_NAME -- /bin/bash -c "cd /root; ./run.sh" &
done

wait
