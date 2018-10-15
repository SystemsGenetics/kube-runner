FROM ubuntu:xenial
MAINTAINER Cole McKnight <cbmckni@clemson.edu>

#
# Install package dependencies
#
RUN apt-get update \
	&& apt-get install -y default-jre git lbzip2 libbz2-dev libfuse2 liblzma-dev liblua5.2-dev lua5.2 lua-filesystem-dev lua-posix-dev python3 python3-pip tcl unzip vim wget zlib1g-dev \
	&& pip3 install matplotlib multiqc numpy pandas xmltodict

#
# Install other bioinformatics tools as Lmod modules
#
WORKDIR /opt

#
# Install the Lmod module system
#
RUN wget -q https://github.com/TACC/Lmod/archive/7.8.4.tar.gz \
	&& tar -xf 7.8.4.tar.gz \
	&& cd Lmod-7.8.4 \
	&& ./configure -q --prefix=/usr/local \
	&& make -s install \
	&& ln -s /usr/local/lmod/lmod/init/profile /etc/profile.d/z00_lmod.sh \
	&& ln -s /usr/local/lmod/lmod/init/cshrc /etc/profile.d/z00_lmod.csh \
	&& mkdir -p /usr/local/modulefiles/Linux \
	&& echo "source /etc/profile.d/z00_lmod.sh" >> ~/.bashrc \
	&& rm -f 7.8.4.tar.gz

#
# Install sratoolkit
#
RUN wget -q https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/2.8.2/sratoolkit.2.8.2-ubuntu64.tar.gz \
	&& tar -xf sratoolkit.2.8.2-ubuntu64.tar.gz \
	&& mv sratoolkit.2.8.2-ubuntu64 /usr/local/sratoolkit.2.8.2 \
	&& rm -f sratoolkit.2.8.2-ubuntu64.tar.gz

#
# Install trimmomatic
#
RUN wget -q http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.38.zip \
	&& unzip -q Trimmomatic-0.38.zip \
	&& mv Trimmomatic-0.38 /usr/local \
	&& rm -f Trimmomatic-0.38.zip

#
# Install hisat2
#
RUN wget -q ftp://ftp.ccb.jhu.edu/pub/infphilo/hisat2/downloads/hisat2-2.1.0-Linux_x86_64.zip \
	&& unzip -q hisat2-2.1.0-Linux_x86_64.zip \
	&& mv hisat2-2.1.0 /usr/local \
	&& rm -f hisat2-2.1.0-Linux_x86_64.zip

#
# Install samtools
#
RUN wget -q https://github.com/samtools/samtools/releases/download/1.9/samtools-1.9.tar.bz2 \
	&& tar -xf samtools-1.9.tar.bz2 \
	&& cd samtools-1.9 \
	&& ./configure -q --prefix=/usr/local/samtools-1.9 --without-curses \
	&& make -s install \
	&& rm -f samtools-1.9.tar.bz2

#
# Install stringtie
#
RUN wget -q http://ccb.jhu.edu/software/stringtie/dl/stringtie-1.3.4d.Linux_x86_64.tar.gz \
	&& tar -xf stringtie-1.3.4d.Linux_x86_64.tar.gz \
	&& mv stringtie-1.3.4d.Linux_x86_64 /usr/local/stringtie-1.3.4d \
	&& rm -f stringtie-1.3.4d.Linux_x86_64.tar.gz

#
# Install fastqc
#
RUN wget -q https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.7.zip \
	&& unzip -q fastqc_v0.11.7.zip \
	&& chmod +x FastQC/fastqc \
	&& mv FastQC /usr/local/FastQC-0.11.7 \
	&& rm -f fastqc_v0.11.7.zip

#
# Install modulefiles for all of the bioinformatics tools
#
ADD modulefiles/. /usr/local/modulefiles/Linux

#
# Install nextflow
#
RUN wget -q -O - https://get.nextflow.io | bash \
	&& chmod +x nextflow \
	&& mv nextflow /usr/local/bin

#
# Install irods-icommands
#
RUN wget -q ftp://ftp.renci.org/pub/irods/releases/4.1.11/ubuntu14/irods-icommands-4.1.11-ubuntu14-x86_64.deb \
	&& dpkg -i irods-icommands-4.1.11-ubuntu14-x86_64.deb \
	&& rm -f irods-icommands-4.1.11-ubuntu14-x86_64.deb

#
# Install GEMmaker
#
WORKDIR /root
RUN git clone https://github.com/SystemsGenetics/GEMmaker.git
