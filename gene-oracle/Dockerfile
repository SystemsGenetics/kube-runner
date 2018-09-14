FROM tensorflow/tensorflow:latest-gpu
MAINTAINER Cole McKnight <cbmckni@clemson.edu> Colin Targonski <ctargon@clemson.edu>

WORKDIR /root

# install package dependencies
RUN apt-get update \
   && apt-get install -y git python-pip python-tk vim \
   && pip install argparse halo matplotlib msgpack numpy scikit-learn scipy \
   && pip install update

# install gene-oracle
RUN git clone https://github.com/ctargon/gene-oracle 

# make input data directories
RUN mkdir data subsets

# install Kubernetes entrypoint
COPY run.sh run.sh
