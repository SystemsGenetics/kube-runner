#!/bin/bash
# List all of the pods for a user.

# parse command-line arguments
if [[ $# != 1 ]]; then
	echo "usage: $0 <user>"
	exit -1
fi

USER="$1"

# get all pods in the namespace
PODS_ALL=$(kubectl get pods --no-headers -o custom-columns=NAME:.metadata.name)

for POD in ${PODS_ALL}; do
	POD_USER=$(kubectl get pod -o yaml ${POD} \
		| grep '/workspace/.*/work' \
		| sed 's/.*\/workspace\///' \
		| sed 's/\/work.*//')

	if [[ ${POD_USER} == ${USER} ]]; then
		PODS_USER="${PODS_USER} ${POD}"
	fi
done

if [[ -z ${PODS_USER} ]]; then
	echo "${USER} doesn't have any pods"
else
	kubectl get pods ${PODS_USER}
fi
