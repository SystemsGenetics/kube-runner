#!/bin/sh
# Deploy a pod to a Kubernetes cluster.

# command-line arguments
NUM_CONTAINERS=$1
INPUT_DIR="$2"

IMAGE_NAME="docker.io/bentsherman/kinc:ubuntu"
NAMESPACE="deepgtex-prp"
POD_FILE="pod.yml"
POD_NAME="kinc"

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
    cat >> $POD_FILE <<EOF
  - name: $POD_NAME-$(printf "%03d" $i)
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

# Copy data and start each container
for i in $(seq 1 $1); do
    echo "Copying data to $POD_NAME-$i..."
    kubectl cp "$INPUT_DIR" "$NAMESPACE/$POD_NAME:/root/input" -c "$POD_NAME-$i" &

    echo "Starting $POD_NAME-$i..."
    kubectl exec "$POD_NAME" -c "$POD_NAME-$i" -- /bin/bash -c "cd /root; ./run.sh" &
done

wait
