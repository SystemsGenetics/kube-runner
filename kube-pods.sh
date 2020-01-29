#!/bin/bash
# List all pods by run name and working directory.

kubectl get pods --no-headers --output custom-columns=RUN:.metadata.labels.runName,NAME:.metadata.name,DIR:.spec.containers[0].workingDir \
	| sed 's/\/workspace\///' \
	| sed 's/\/work.*//' \
	| sort -V
