FROM tensorflow/tensorflow:latest-gpu
MAINTAINER Cole McKnight <cbmckni@clemson.edu> Colin Targonski <ctargon@clemson.edu>

# install package dependencies
RUN apt-get update -qq \
	&& apt-get install -qq -y git python-pip python-tk vim \
	&& pip install argparse halo matplotlib msgpack numpy scikit-learn scipy \
	&& pip install update

# install gene-oracle
WORKDIR /root
RUN git clone https://github.com/feltus/gene-oracle
