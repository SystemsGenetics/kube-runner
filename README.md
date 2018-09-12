# KINC-docker

This repository contains Docker resources for KINC. In particular, this repository provides two Docker images for KINC:

1. An Ubuntu-based image for running KINC on Kubernetes.
2. A CentOS-based container for providing KINC as an Lmod module.

## Dependencies

This repository depends on `docker` as well as `nvidia-docker2` for GPU support.

## Usage

To build a Docker image:
```
sudo docker build -t [tag] -f [Dockerfile] .
```

To run a Docker container:
```
sudo docker run --rm -it [tag]
```
