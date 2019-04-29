# kube-runner

This repository provides scripts for running nextflow pipelines on a Kubernetes cluster. These scripts have been tested for the following pipelines:

- [SystemsGenetics/GEMmaker](https://github.com/SystemsGenetics/GEMmaker)
- [SystemsGenetics/gene-oracle-nf](https://github.com/SystemsGenetics/gene-oracle-nf)
- [SystemsGenetics/KINC-nf](https://github.com/SystemsGenetics/KINC-nf)

(In Progress) 
- [ebenz99/MPCM-Nextflow] (https://github.com/ebenz99/MPCM-Nextflow) 

## Dependencies

To get started, all you need is [nextflow](https://nextflow.io/), [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/), and access to a Kubernetes cluster (in the form of `~/.kube/config`). If you want to test Docker images on your local machine, you will also need [docker](https://docker.com/) and [nvidia-docker](https://github.com/NVIDIA/nvidia-docker) (for GPU-enabled Docker images).

## Configuration

There are a few administrative tasks which must be done in order for nextflow to be able to run properly on the Kubernetes cluster. These tasks only need to be done once, but they may require administrative access to the cluster, so you may need your system administrator to handle this part for you.

- Nextflow needs a service account with the `edit` and `view` cluster roles:
```bash
kubectl create rolebinding default-edit --clusterrole=edit --serviceaccount=<namespace>:default 
kubectl create rolebinding default-view --clusterrole=view --serviceaccount=<namespace>:default
```

- Nextflow needs access to shared storage in the form of a [Persistent Volume Claim](https://kubernetes.io/docs/concepts/storage/persistent-volumes/) (PVC) with `ReadWriteMany` access mode. The process for provisioning a PVC depends on what types of storage is available. The `kube-create-pvc.sh` script provides an example of creating a PVC for CephFS storage, but it may not apply to your particular cluster. Consult your system administrator for assistance if necessary.

## Usage

It is recommended that you create a separate directory for each pipeline that you use, for example:
```bash
mkdir KINC
cd KINC
../kube-load.sh [...]
```

First you must transfer your input data from your local machine to the cluster. You can use the `kube-load.sh` script to do this:
```bash
../kube-load.sh <pvc-name> <input-dir>
```

Then you can run the pipeline using nextflow's `kuberun` command:
```bash
nextflow [-C nextflow.config] kuberun <pipeline>
```

__NOTE__: If you create your own `nextflow.config` in your current directory then nextflow will use that config file instead of the default.

Once the pipeline finishes successfully, you can transfer your output data from the cluster using `kube-save.sh`:
```bash
../kube-save.sh <pvc-name> <output-dir>
```

You can also use nextflow to create an interactive terminal on the cluster where you can access your PVC directly:
```bash
nextflow kuberun login
```

Consult the [Nextflow Kubernetes documentation](https://www.nextflow.io/docs/latest/kubernetes.html) for more information.

## Appendix

### Working with Docker images

__NOTE__: Generally speaking, Docker requires admin privileges in order to run. On Linux, for example, you may need to run Docker commands with `sudo`. Alternatively, if you add your user to the `docker` group then you will be able to run `docker` without `sudo`.

Build a Docker image:
```bash
docker build -t <tag> <build-directory>
```

Run a Docker container:
```bash
docker run [--runtime=nvidia] --rm -it <tag> <command>
```

List the Docker images on your machine:
```bash
docker images
```

Push a Docker image to Docker Hub:
```bash
docker push <tag>
```

Remove old Docker data:
```bash
docker system prune
```

### Interacting with a Kubernetes cluster

Test your Kubernetes configuration:
```bash
kubectl config view
```

View the physical nodes on your cluster:
```bash
kubectl get nodes --show-labels
```

Check the status of your pods:
```bash
kubectl get pods -o wide
```

Get information on a pod:
```bash
kubectl describe pod <pod-name>
```

Get an interactive shell into a pod:
```bash
kubectl exec -it <pod-name> -- bash
```

Delete a pod:
```bash
kubectl delete pod <pod-name>
```
