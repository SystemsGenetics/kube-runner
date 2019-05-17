#!/bin/bash
# Remove all pods that are not running.

PODS=$(kubectl get pods --no-headers | grep 'Error\|Completed' | awk '{ print $1 }')

if [[ ! -z $PODS ]]; then
	kubectl delete pods $PODS
fi
