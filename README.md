# docker-tools

This repository provides resources for running various systems biology tools with Kubernetes. This repository contains Docker resources for the following applications:

- [GEMmaker](https://github.com/SystemsGenetics/GEMmaker)
- [gene-oracle](https://github.com/ctargon/gene-oracle)
- [KINC](https://github.com/SystemsGenetics/KINC)

Additionally, each application can be run as a job of _N_ Docker containers to a Kubernetes cluster using `kubectl`.

## Dependencies

You need Docker to build and push Docker images, and [nvidia-docker](https://github.com/NVIDIA/nvidia-docker) to test GPU-enabled Docker images on a local machine. To interact with a Kubernetes cluster, you need [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/).

## Usage

### Creating a Docker image

Build a Docker image:
```bash
cd <app-directory>
sudo docker build -t <tag> -f <Dockerfile> .
```

Run a Docker container (locally):
```bash
sudo docker run [--runtime=nvidia] --rm -it <tag>
```

List the Docker images on your machine:
```bash
sudo docker images
```

Push a Docker image to DockerHub:
```bash
sudo docker push <tag>
```

NOTE: In order to push an image to DockerHub, the image must be tagged with both a username and a repo name. For example:
```bash
sudo docker tag a88adcfb02de systemsgenetics/gemmaker:latest
sudo docker push systemsgenetics/gemmaker:latest
```

### Running on a Kubernetes cluster

Once you install `kubectl`, you must save a configuration to `~/.kube/config`. For example, if you are using [Nautilus](https://nautilus.optiputer.net/) you can download the config file from the Nautilus dashboard by selecting "Get config".

Test your Kubernetes configuration:
```bash
kubectl config view
```

Before you run a job, create a directory with the following:
- A script named `command.sh` that you want to run on each container
- Any input data files that are to be copied to each container

The script `kube-run.sh` can automatically run a Docker image by (1) creating a job configuration, (2) creating the job, (3) copying input files to each container in the job, (4) executing the command script on each container, and (5) copying output files from each container. You must provide the following:
- the job name
- the image you want to run
- the number of work items
- the path to your input directory
- the path to your output directory

Run a job:
```bash
./kube-run.sh <job-name> <image-name> <job-size> <input-dir> <output-dir>
```

Check the status of your jobs:
```bash
kubectl get jobs
```

Get information on a job:
```bash
kubectl describe job <job-name>
```

Get information on a pod:
```bash
kubectl describe pod <pod-name>
```

Get an interactive shell into a pod:
```bash
kubectl exec -it <pod-name> -- bash
```

Delete a job:
```bash
kubectl delete job <job-name>
```

__Always delete jobs that are finished to return their resources to the cluster.__
