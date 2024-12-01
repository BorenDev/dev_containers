# syntax=docker/dockerfile:1
#
# Setup a xc32 ubuntu development container with the latest cmake
FROM ubuntu:24.04 AS cmake_build

RUN apt-get -y update && \
    DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC apt-get -y install tzdata && \
    apt-get -y upgrade && \
    apt-get -f install -y \
    autoconf \
    build-essential \
    curl \
    libssl-dev \
    libtool \
    unzip \
    wget

WORKDIR /workdir

RUN VER=$(curl --silent -qI https://github.com/Kitware/CMake/releases/latest | awk -F '/' '/^location/ {print  substr($NF, 1, length($NF)-1)}') && \
    wget https://github.com/Kitware/CMake/releases/download/$VER/cmake-${VER#v}.tar.gz && \
    tar xzf cmake-${VER#v}.tar.gz && \
    mkdir /workdir/cmake-install && \
    cd cmake-${VER#v}/ && \
    ./bootstrap --parallel=$(nproc) --prefix=/workdir/cmake-install && \
    make -j $(nproc) && \
    make install

FROM cmake_build as xc32_build

RUN dpkg --add-architecture i386 && \
    apt-get -y update && \
    apt-get -f install -y \
    apt-src \
    autoconf \
    autogen \
    binutils-mingw-w64-i686 \
    bison \
    curl \
    dejagnu \
    flex \
    flip \
    g++-mingw-w64-i686 \
    gawk \
    gcc-mingw-w64-i686 \
    git \
    gperf \
    gzip \
    libisl-dev \
    nsis \
    openssh-client \
    p7zip-full \
    perl \
    python3-dev \
    scons \
    tcl \
    texinfo \
    texlive \
    texlive-extra-utils \
    tofrodos \
    tree \
    vim \
    wget \
    zip

WORKDIR /workdir

ARG XC_TOOLCHAIN_VERSION=4.45
ARG XC_TOOLCHAIN_SRC_ARCHIVE=xc32-v${XC_TOOLCHAIN_VERSION}-src.zip

# Retrieve compiler source
RUN curl -fSL -A "Mozilla/4.0" -o ${XC_TOOLCHAIN_SRC_ARCHIVE} \
    https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/SoftwareTools/${XC_TOOLCHAIN_SRC_ARCHIVE}

RUN mkdir /workdir/xc32-v${XC_TOOLCHAIN_VERSION}-install && \
    mkdir /workdir/xc32-v${XC_TOOLCHAIN_VERSION}-src && \
    unzip xc32-v${XC_TOOLCHAIN_VERSION}-src.zip -d xc32-v${XC_TOOLCHAIN_VERSION}-src && \
    cd xc32-v${XC_TOOLCHAIN_VERSION}-src/ && \
    tar xjf pic32c-gcc-binutils.tar.bz2 && \
    tar xjf pic32c-newlib.tar.bz2 && \
    tar xjf pic32m-gcc-binutils.tar.bz2 

# # Build libmchp
# RUN cd xc32-v${XC_TOOLCHAIN_VERSION}-src/ && \
#     cd pic32m-source/mchp && \
#     ./configure --installdir /workdir/xc32-v${XC_TOOLCHAIN_VERSION}-install && \
#     make -j$(nproc) && \
#     make install

# RUN cd xc32-v${XC_TOOLCHAIN_VERSION}-src/ && \
#     cd pic32m-source/binutils && \
#     ;
COPY c30_resource/ /workdir/xc32-v${XC_TOOLCHAIN_VERSION}-src/pic32m-source/c30_resource
COPY xc32_device.info .
COPY env.sh .
COPY xc32_mx.sh .
RUN /workdir/xc32_mx.sh

# FROM ubuntu:24.04 AS ub_dev
#
# ARG XC_TOOLCHAIN_VERSION=4.45
#
# COPY --from=cmake_build /workdir/cmake-install/ /usr/local/
# COPY --from=xc32_build /workdir/xc32-v${XC_TOOLCHAIN_VERSION}-install/ /usr/local/pic32m
#
# # Add the directory to the PATH
# ENV PATH $PATH:/usr/local/pic32m/bin/bin
#
# WORKDIR /workdir
#
# # RUN dpkg --add-architecture i386 && \
# #     apt-get -y update && \
# #     apt-get -f install -y \
# #     mingw-w64
# # 
# # #    g++-mingw-w64-i686 \
# # #    gcc-mingw-w64-i686 \
# # #    gcc-mingw-w64-x86-64 \
# # #    g++-mingw-w64-x86-64
