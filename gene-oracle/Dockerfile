FROM tensorflow/tensorflow:latest-gpu
MAINTAINER Cole McKnight <cbmckni@clemson.edu> Colin Targonski <ctargon@clemson.edu>

# install package dependencies
RUN apt-get update \
   && apt-get install -y git python-pip python-tk vim \
   && pip install argparse halo matplotlib msgpack numpy scikit-learn scipy \
   && pip install update

# install gene-oracle
WORKDIR /root
RUN git clone https://github.com/ctargon/gene-oracle

# install Kubernetes entrypoint
WORKDIR /root
COPY ../run.sh run.sh
