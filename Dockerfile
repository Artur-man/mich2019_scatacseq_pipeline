FROM ubuntu:16.04
LABEL author="artur.manukyan@umassmed.edu" description="Docker image containing all requirements for the dolphinnext/mich2021_scatacseq pipeline"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates curl git libtbb-dev g++ && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc
    
# configure image 
RUN apt-get -y update 
RUN apt-get -y install software-properties-common build-essential
RUN add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu xenial-cran40/'
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
RUN apt-get -y install apt-transport-https
RUN apt-get -y update

RUN conda update -n base -c defaults conda
RUN conda config --set channel_priority strict
COPY environment.yml /
RUN conda env create -f /environment.yml --debug && conda clean -a

# Install standard utilities for HOMERv4.10
RUN apt-get clean all
RUN apt-get update
RUN apt-get dist-upgrade -y
RUN apt-get -y install zip unzip gcc g++ make

# Install dolphin-tools
RUN git clone https://github.com/dolphinnext/tools /usr/local/bin/dolphin-tools
RUN mkdir -p /project /nl /mnt /share
ENV PATH /opt/conda/envs/dolphinnext-mich2021-1.0/bin:/usr/local/bin/dolphin-tools/:$PATH

COPY r_packages.R /
RUN Rscript r_packages.R
