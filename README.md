# KINC-docker

This repository provides resources for running KINC with Kubernetes. In particular, this repository provides two Dockerfiles for building a Docker image of KINC based on Ubuntu or CentOS, as well as a script to deploy a pod of KINC containers on a Kubernetes cluster.

## Dependencies

You need Docker to build and push Docker images, and `nvidia-docker` to test Docker images on a local machine (with a GPU). To deploy a KINC pod to a Kubernetes cluster, you need `kubectl`.

## Usage

### Creating Docker images

Build a Docker image:
```
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

### Deploying to a Kubernetes cluster

Once you install `kubectl`, you must save a configuration to `~/.kube/config`. For example, if you are using Nautilus you can download the config file from the Nautilus dashboard.

Test your Kubernetes configuration:
```
kubectl config view
```

Before you deploy a KINC pod, create a directory with the following:
1. A script named `command.sh` that you want to run on each container
2. Any data files that are to be copied to each container

Deploy a KINC pod:
```
./deploy.sh [num-containers] [data-dir]
```

Check the status of your pods:
```
kubectl get pods
```

Delete a pod:
```
kubectl delete pod [pod-name]
```
