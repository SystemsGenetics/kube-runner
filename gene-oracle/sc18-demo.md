# SC18 Demo

For the SC18 demo we will show how to run a small gene-oracle job on a Kubernetes cluster and monitor the GPU usage through Grafana.

## Prerequisites

You will need the following on your local machine:

- Access to the NRP
- The `kubectl` command line tool
- This repo and the required input data

## Preparing the Input Data

You should have the input data directory set up as follows:
```
_input/
  command.sh
  gtex_gct_data_float_v7.npy
  gtex_gene_list_v7.npy
  gtex_tissue_count_v7.json
  hallmark_experiments.txt
```

The `command.sh` script can just be copied from `gene-oracle/command-example.sh`. The other data files come from elsewhere (we have them on Palmetto).

The file `hallmark_experiments.txt` contains a list of 50 Hallmark gene sets. In order to process these sets in a distributed fashion, we need to split this file into "chunks" corresponding to the number of pods we want to use. For this example we'll use 4 chunks:
```bash
gene-oracle/split.sh _input/hallmark_experiments.txt 4
```

You should now see the chunked files in the input directory. You can remove the `hallmark_experiments.txt` from the `_input` if you want to, it is no longer needed.

## Running a Job

Once your input data is set up, running a job is a simple one-liner:
```bash
./kube-run gene-oracle-example bentsherman/gene-oracle 4 _input _output
```

As you can see, there are five parameters:
1. The job name
2. The DockerHub URL of the Docker image to use
3. The number of pods (same as the number of chunks)
4. The input directory
5. The output directory

The job name can be anything, as long as there isn't a job with the same name already running. In Kubernetes terminology, a __job__ consists of multiple __pods__, and each pod has it's own Docker container which is pulled automatically from DockerHub. While a pod represents an isolated environment, a __node__ is a physical node, and multiple pods can be assigned to the same node. For example, if we request two pods with 1 GPU each and there is a node with 2 GPUs, Kubernetes could assign both pods to the same node.

Running the `kube-run.sh` script will show you each step of the process:
1. Create a config file for the job
2. Create the job with 4 pods
3. Wait until all pods are ready
4. Copy the input directory to each pod
5. Execute the command script on each pod
6. Wait for all pods to finish executing
7. Copy the output directory from each pod to the local machine
8. Delete the job

## Monitoring GPU Usage

Once all pods in a job are ready, `kube-run.sh` will print a list of the pods with their node assignments. You can also print this list yourself in a separate terminal:
```bash
kubectl get pods -o wide
```

You can view usage data from [Grafana](https://grafana.nautilus.optiputer.net/). Here are some noteworthy dashboards:
- __GPUs usage__: Global GPU usage stats
- __K8S Nvidia GPU - Cluster__: Global GPU usage stats with more detail
- __K8S Nvidia GPU - Node__: GPU usage stats for each node

Currently the only way to view specific GPU usage information is on a per-node basis. There are other dashboards for namespaces and pods, but they don't show GPU usage. So you can select a node from the afore-mentioned node assigments, search for that node on the __K8S Nvidia GPU - Node__ dashboard, and then you can see the GPU usage for that node. You can also use the menu in the top-right corner to control the time range and refresh interval.

## Monitoring the MSigDB Experiment

During SC18, the "big" experiment (evaluating the ~17,000 gene sets from MSigDB on GTEx, including random sets) will be running under the job name `gene-oracle-msigdb-gtex`. You can see the pods for this job with the same command as above:
```bash
kubectl get pods -o wide
```

The pods associated with this job will have the job name included in their pod name. You can use the same method as before to view GPU usage stats for the nodes associated with these pods.

## Collecting the Output Data

If your job finishes without any errors, you can merge the results from gene-oracle with the `merge.sh` script:
```bash
gene-oracle/merge.sh
```

You should then have two text files, `results.hallmark.txt` and `results.random.txt`.

## Troubleshooting

When `kube-run.sh` transfers the output data to your local machine, you may get an error like the following:
```bash
Copying output data from gene-oracle-24h76...
tar: Removing leading '/' from member names
tar: /root/output: Cannot stat: No such file or directory
tar: Exiting with failure status due to previous errors
error: root/output no such file or directory
```

We haven't figured out the source of this problem yet, but it doesn't seem to happen every time. Try re-running the experiment and decreasing the number of chunks to 1 or 2.

Also, be sure to remove the output directory before re-running an experiment:
```bash
rm -rf _output
```
