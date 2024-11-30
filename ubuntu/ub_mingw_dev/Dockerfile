# syntax=docker/dockerfile:1
#
# Setup a mingw ubuntu development container with the latest cmake
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

FROM ubuntu:24.04 AS ub_dev

COPY --from=cmake_build /workdir/cmake-install/ /usr/local/

RUN dpkg --add-architecture i386 && \
    apt-get -y update && \
    apt-get -f install -y \
    mingw-w64

#    g++-mingw-w64-i686 \
#    gcc-mingw-w64-i686 \
#    gcc-mingw-w64-x86-64 \
#    g++-mingw-w64-x86-64
