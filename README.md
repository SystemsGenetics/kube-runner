# docker-tools

This repository provides resources for running various systems biology tools with Kubernetes. This repository contains Docker resources for the following applications:

- [GEMmaker](https://github.com/SystemsGenetics/GEMmaker)
- [gene-oracle](https://github.com/ctargon/gene-oracle)
- [KINC](https://github.com/SystemsGenetics/KINC)

Additionally, each application can be deployed as a pod of _N_ Docker containers to a Kubernetes cluster using `kubectl`.

## Dependencies

You need Docker to build and push Docker images, and [nvidia-docker](https://github.com/NVIDIA/nvidia-docker) to test GPU-enabled Docker images on a local machine. To deploy a pod to a Kubernetes cluster, you need [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

## Usage

### Creating a Docker image

Build a Docker image:
```
cd [app-directory]
sudo docker build -t [tag] -f [Dockerfile] .
```

Run a Docker container (locally):
```
sudo docker run [--runtime=nvidia] --rm -it [tag]
```

List the Docker images on your machine:
```
sudo docker images
```

Push a Docker image to DockerHub:
```
sudo docker push [tag]
```

NOTE: In order to push an image to DockerHub, the image must be tagged with both a username and a repo name. For example:
```
sudo docker tag a88adcfb02de systemsgenetics/gemmaker:latest
sudo docker push systemsgenetics/gemmaker:latest
```

### Deploying to a Kubernetes cluster

Once you install `kubectl`, you must save a configuration to `~/.kube/config`. For example, if you are using [Nautilus](https://nautilus.optiputer.net/) you can download the config file from the Nautilus dashboard by selecting "Get config".

Test your Kubernetes configuration:
```
kubectl config view
```

Before you deploy a pod, create a directory with the following:
- A script named `command.sh` that you want to run on each container
- Any data files that are to be copied to each container

The script `deploy.sh` can automatically deploy a Docker image by (1) creating a pod configuration, (2) creating the pod, (3) copying input files to each container in the pod, and (4) executing each container in the pod. You must provide the following:
- the name of an image on DockerHub
- the number of containers to run
- the path to your input directory

Deploy a pod:
```
./deploy.sh [image-name] [num-containers] [input-dir]
```

Check the status of your pods:
```
kubectl get pods
```

Copy data from a container:
```
kubectl cp [namespace]/[pod-name]:[remote-path] -c [container-name] [local-path]
```

Delete a pod:
```
kubectl delete pod [pod-name]
```

__Always delete pods that are finished to return their resources to the cluster.__
