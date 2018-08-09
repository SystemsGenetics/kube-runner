FROM ubuntu:xenial

# install package dependencies
RUN apt-get update \
   && apt-get install -y build-essential git libgsl-dev libopenblas-dev libopenmpi-dev ocl-icd-opencl-dev python wget xz-utils

# install Qt
RUN cd /opt \
   && wget -q http://download.qt.io/official_releases/qt/5.11/5.11.1/single/qt-everywhere-src-5.11.1.tar.xz \
   && tar -xf qt-everywhere-src-5.11.1.tar.xz \
   && rm qt-everywhere-src-5.11.1.tar.xz \
   && mkdir Qt \
   && cd Qt \
   && echo -e 'o\ny\n\n' | ../qt-everywhere-src-5.11.1/configure -prefix . \
   && make -j 16 \
   && make -j 16 install \
   && rm -rf ../qt-everywhere-src-5.11.1

RUN export QTDIR="/opt/Qt"
RUN export PATH="$QTDIR/bin:$PATH"

# install ACE
RUN cd /opt \
   && git clone https://github.com/SystemsGenetics/ACE.git \
   && cd ACE/build \
   && qmake ../src/ACE.pro PREFIX=$HOME/software \
   && make -j 16 install

RUN export INSTALL_PREFIX="$HOME/software"
RUN export PATH="$INSTALL_PREFX/bin:$PATH"
RUN export CPLUS_INCLUDE_PATH="$INSTALL_PREFIX/include:$CPLUS_INCLUDE_PATH"
RUN export LIBRARY_PATH="$INSTALL_PREFIX/lib:$LIBRARY_PATH"
RUN export LD_LIBRARY_PATH="$INSTALL_PREFIX/lib:$LD_LIBRARY_PATH"

# install KINC
RUN cd /opt \
   && git clone https://github.com/SystemsGenetics/KINC.git \
   && cd KINC/build \
   && qmake ../src/KINC.pro \
   && make -j 16
