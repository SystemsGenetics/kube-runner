FROM nvidia/cuda:9.0-devel
MAINTAINER Ben Shealy <btsheal@clemson.edu>

# install package dependencies
RUN apt-get update -qq \
	&& apt-get install -qq -y wget xz-utils \
	&& apt-get install -qq -y build-essential python gperf bison flex pkg-config libgl1-mesa-dev \
	&& apt-get install -qq -y clinfo git libgsl-dev liblapacke-dev libopenblas-dev libopenmpi-dev ocl-icd-opencl-dev

# add NVIDIA platform to OpenCL
RUN mkdir -p /etc/OpenCL/vendors \
	&& echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

# install Qt
RUN cd /opt \
	&& wget -q http://download.qt.io/official_releases/qt/5.11/5.11.1/single/qt-everywhere-src-5.11.1.tar.xz \
	&& tar -xf qt-everywhere-src-5.11.1.tar.xz \
	&& rm qt-everywhere-src-5.11.1.tar.xz \
	&& mkdir qt \
	&& cd qt \
	&& ../qt-everywhere-src-5.11.1/configure -prefix . -opensource -confirm-license \
	&& make -s -j $(nproc) \
	&& make -s -j $(nproc) install \
	&& rm -rf ../qt-everywhere-src-5.11.1

ENV QTDIR  "/opt/qt"
ENV PATH   "$QTDIR/bin:$PATH"

# install ACE
RUN cd /opt \
	&& git clone https://github.com/SystemsGenetics/ACE.git \
	&& cd ACE/build \
	&& git checkout v3.0.2 \
	&& qmake ../src/ACE.pro PREFIX=/opt/ace \
	&& make -s -j $(nproc) \
	&& make -s qmake_all \
	&& make -s install

ENV ACEDIR              "/opt/ace"
ENV PATH                "$ACEDIR/bin:$PATH"
ENV CPLUS_INCLUDE_PATH  "$ACEDIR/include:$CPLUS_INCLUDE_PATH"
ENV LIBRARY_PATH        "$ACEDIR/lib:$LIBRARY_PATH"
ENV LD_LIBRARY_PATH     "$ACEDIR/lib:$LD_LIBRARY_PATH"

# install KINC
RUN cd /opt \
	&& git clone https://github.com/SystemsGenetics/KINC.git \
	&& cd KINC/build \
	&& git checkout v3.2.2 \
	&& qmake ../src/KINC.pro PREFIX=/opt/kinc \
	&& make -s -j $(nproc) \
	&& make -s qmake_all \
	&& make -s install

ENV KINCDIR  "/opt/kinc"
ENV PATH     "$KINCDIR/bin:$PATH"
