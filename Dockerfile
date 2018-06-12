# Dockerfile to build openMS images for MS data processing
# Based on Ubuntu

# Add python3_scientific
FROM dmccloskey/python3scientific:latest

# File Author / Maintainer
LABEL maintainer Douglas McCloskey <dmccloskey87@gmail.com>

# Switch to root for install
USER root

# OpenMS versions
ENV OPENMS_CONTRIB_VERSION f74999a

# Install openMS dependencies
RUN apt-get -y update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
    # cmake \
    g++ \
    autoconf \
    patch \
    libtool \
    make \
    git \
    libsvm-dev \
    libglpk-dev \
    libzip-dev \
    libxerces-c-dev \
    zlib1g-dev \
    libbz2-dev \
    libsqlite3-dev \
    # Boost libraries
    libboost-test1.54-dev \
    libboost-date-time1.54-dev \
    libboost-iostreams1.54-dev \
    libboost-regex1.54-dev \
    libboost-math1.54-dev \
    libboost-random1.54-dev \
    # QT5 libraries
    software-properties-common \
    python-software-properties \
    libgl1-mesa-dev && \
    add-apt-repository ppa:beineri/opt-qt571-trusty && \
    apt-get -y update && \
    apt-get install -y qt57base qt57webengine qt57svg libgl1-mesa-dev \
    && \
    apt-get clean && \
    apt-get purge && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \

    # install cmake from source
    cd /usr/local/ && \
    wget http://www.cmake.org/files/v3.8/cmake-3.8.2.tar.gz && \
    tar xf cmake-3.8.2.tar.gz && \
    cd cmake-3.8.2 && \
    ./configure && \
    make -j8 && \

    # install Cuda
    cd /usr/local/ && \
    wget https://developer.nvidia.com/compute/cuda/9.2/Prod/local_installers/cuda_9.2.88_396.26_linux && \
    chmod +x cuda_9.2.88_396.26_linux && \
    ./cuda_9.2.88_396.26_linux --tar mxvf && \
    ./cuda-installer.pl --silent --driver && \
    ./cuda-installer.pl --silent --toolkit && \
    wget https://developer.nvidia.com/compute/cuda/9.2/Prod/patches/1/cuda_9.2.88.1_linux && \
    chmod +x cuda_9.2.88.1_linux && \
    ./cuda_9.2.88.1_linux --tar mxvf && \
    # ./install_patch.pl --silent --accept-eula && \
    ./install_patch.pl --silent --accept-eula && \

    ## install proteowizard
    #cd /usr/local/  && \
    #ZIP=pwiz-bin-linux-x86_64-gcc48-release-3_0_9740.zip && \
    #wget https://github.com/BioDocker/software-archive/releases/download/proteowizard/$ZIP -O /tmp/$ZIP && \
    #unzip /tmp/$ZIP -d /home/user/pwiz/ && \
    #chmod -R 755 /home/user/pwiz/* && \
    #rm /tmp/$ZIP && \

    # Install python packages using pip3
    pip3 install --no-cache-dir \
        autowrap==0.14.0 \
        nose \
        wheel \
    &&pip3 install --upgrade

## add pwiz to the path
#ENV PATH /usr/local/pwiz/pwiz-bin-linux-x86_64-gcc48-release-3_0_9740:$PATH

# add cmake to the path
ENV PATH /usr/local/cmake-3.8.2/bin:$PATH
ENV LD_LIBRARY_PATH /usr/local/cuda-9.2/lib64:$LD_LIBRARY_PATH
ENV PATH /usr/local/cuda-9.2/bin:$PATH

# Clone the OpenMS/contrib repository
RUN cd /usr/local/ && \
    git clone https://github.com/OpenMS/contrib.git && \
    cd /usr/local/contrib && \
    git checkout ${OPENMS_CONTRIB_VERSION} && \
    mkdir /usr/local/contrib-build/  && \
    # Build OpenMS/contrib
    cd /usr/local/contrib-build/  && \
    cmake -DBUILD_TYPE=SEQAN ../contrib && rm -rf archives src && \
    cmake -DBUILD_TYPE=WILDMAGIC ../contrib && rm -rf archives src && \
    cmake -DBUILD_TYPE=EIGEN ../contrib && rm -rf archives src && \
    cmake -DBUILD_TYPE=COINOR ../contrib && rm -rf archives src
    # cmake -DBUILD_TYPE=SQLITE ../contrib && rm -rf archives src

# switch back to user
WORKDIR $HOME
USER user

# set the command
CMD ["python3"]
