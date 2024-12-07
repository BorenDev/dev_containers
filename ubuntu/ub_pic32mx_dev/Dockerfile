# syntax=docker/dockerfile:1
#
# Setup a pic32mx ubuntu development container with the latest cmake
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

ARG MPLABX_VERSION=6.20
ARG XC_TOOLCHAIN=xc32
ARG XC_TOOLCHAIN_VERSION=4.45
ARG ATPACK_NAME=PIC32MZ-EF_DFP
ARG ATPACK_VERSION=1.4.168
ARG SIM_ATPACK_NAME=Simulator_TP
ARG SIM_ATPACK_VERSION=1.7.660
ARG CURIOSITY_ATPACK_NAME=PKOB4_TP
ARG CURIOSITY_ATPACK_VERSION=1.14.1168
ARG USER_NAME=developer
ARG USER_ID=1000
ARG GROUP_ID=1000

RUN dpkg --add-architecture i386 && \
    apt-get -y update && \
    apt-get -f install -y \
    zip

WORKDIR /workdir

COPY xc32-v${XC_TOOLCHAIN_VERSION}-full-install-linux-x64-installer.run /tmp/${XC_TOOLCHAIN}.run
RUN chmod a+x "/tmp/${XC_TOOLCHAIN}.run" \
    && "/tmp/${XC_TOOLCHAIN}.run" --mode unattended --unattendedmodeui none \
    --netservername localhost --LicenseType FreeMode \
    && rm "/tmp/${XC_TOOLCHAIN}.run" \
    && rm -rf "/opt/microchip/xc32/v${XC_TOOLCHAIN_VERSION}/pic32c/" \
    && rm -rf "/opt/microchip/xc32/v${XC_TOOLCHAIN_VERSION}/examples/" \
    && rm -rf "/opt/microchip/xc32/v${XC_TOOLCHAIN_VERSION}/docs/" \
    && mkdir -p /opt/microchip/packs/

ENV PATH /opt/microchip/${XC_TOOLCHAIN}/v${XC_TOOLCHAIN_VERSION}/bin:$PATH

COPY cpluslic.sh /tmp/cpluslic.sh
RUN bash /tmp/cpluslic.sh

ENV CUR_ATPACK_NAME ${ATPACK_NAME}
ENV CUR_ATPACK_VER ${ATPACK_VERSION}
ENV CUR_ATPACK_DIR "/opt/microchip/packs/${CUR_ATPACK_NAME}/${CUR_ATPACK_VER}"

ENV INSTALL_ATPACK Microchip.${CUR_ATPACK_NAME}.${CUR_ATPACK_VER}.atpack
ENV TMP_ATPACK /tmp/tmp-pack.atpack

COPY "${INSTALL_ATPACK}" "${TMP_ATPACK}"
RUN mkdir -p "${CUR_ATPACK_DIR}" \
    && unzip -o ${TMP_ATPACK} -d "${CUR_ATPACK_DIR}" \
    && rm ${TMP_ATPACK}


ENV CUR_ATPACK_NAME ${SIM_ATPACK_NAME}
ENV CUR_ATPACK_VER ${SIM_ATPACK_VERSION}
ENV CUR_ATPACK_DIR "/opt/microchip/packs/${CUR_ATPACK_NAME}/${CUR_ATPACK_VER}"

ENV INSTALL_ATPACK Microchip.${CUR_ATPACK_NAME}.${CUR_ATPACK_VER}.atpack
ENV TMP_ATPACK /tmp/tmp-pack.atpack

COPY "${INSTALL_ATPACK}" "${TMP_ATPACK}"
RUN mkdir -p "${CUR_ATPACK_DIR}" \
    && unzip -o ${TMP_ATPACK} -d "${CUR_ATPACK_DIR}" \
    && rm ${TMP_ATPACK}


ENV CUR_ATPACK_NAME ${CURIOSITY_ATPACK_NAME}
ENV CUR_ATPACK_VER ${CURIOSITY_ATPACK_VERSION}
ENV CUR_ATPACK_DIR "/opt/microchip/packs/${CUR_ATPACK_NAME}/${CUR_ATPACK_VER}"

ENV INSTALL_ATPACK Microchip.${CUR_ATPACK_NAME}.${CUR_ATPACK_VER}.atpack
ENV TMP_ATPACK /tmp/tmp-pack.atpack

COPY "${INSTALL_ATPACK}" "${TMP_ATPACK}"
RUN mkdir -p "${CUR_ATPACK_DIR}" \
    && unzip -o ${TMP_ATPACK} -d "${CUR_ATPACK_DIR}" \
    && rm ${TMP_ATPACK}

COPY --from=cmake_build /workdir/cmake-install/ /usr/local/

WORKDIR /workdir
