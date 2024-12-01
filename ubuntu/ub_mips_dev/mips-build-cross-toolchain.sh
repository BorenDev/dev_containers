#!/bin/bash

##-------------------------------------------------------------
## Configuration variables
##-------------------------------------------------------------
start_dir=$PWD
target="mipsel-elf"
root_dir="$start_dir/$target"

clean_install=true build_binutils=true
build_gcc_static=true
build_newlib=true
build_gcc=true

_GCC_VERSION=11.1.0
_BINUTILS_VERSION=2.36
_GDB_VERSION=10.2
_NEWLIB_VERSION=4.1.0
_GMP_VERSION=6.1.0
_ISL_VERSION=0.18
_MPC_VERSION=1.0.3
_MPFR_VERSION=3.1.4

_GCC_DIR=gcc-$_GCC_VERSION
_BINUTILS_DIR=binutils-$_BINUTILS_VERSION
_GDB_DIR=gdb-$_GDB_VERSION
_NEWLIB_DIR=newlib-$_NEWLIB_VERSION
_GMP_DIR=gmp-$_GMP_VERSION
_ISL_DIR=isl-$_ISL_VERSION
_MPC_DIR=mpc-$_MPC_VERSION
_MPFR_DIR=mpfr-$_MPFR_VERSION

_GCC_TARBALL=$_GCC_DIR.tar.xz
_BINUTILS_TARBALL=$_BINUTILS_DIR.tar.xz
_GDB_TARBALL=$_GDB_DIR.tar.xz
_NEWLIB_TARBALL=$_NEWLIB_DIR.tar.gz
_GMP_TARBALL=$_GMP_DIR.tar.bz2
_ISL_TARBALL=$_ISL_DIR.tar.xz
_MPC_TARBALL=$_MPC_DIR.tar.gz
_MPFR_TARBALL=$_MPFR_DIR.tar.xz

if ! [ -f "$_GCC_TARBALL" ]; then
    wget https://ftp.gnu.org/gnu/gcc/gcc-$_GCC_VERSION/$_GCC_TARBALL
fi
if ! [ -f "$_BINUTILS_TARBALL" ]; then
    wget https://ftp.gnu.org/gnu/binutils/$_BINUTILS_TARBALL
fi
if ! [ -f "$_GDB_TARBALL" ]; then
    wget https://ftp.gnu.org/gnu/gdb/$_GDB_TARBALL
fi
if ! [ -f "$_NEWLIB_TARBALL" ]; then
    wget ftp://sourceware.org/pub/newlib/$_NEWLIB_TARBALL
fi
if ! [ -f "$_GMP_TARBALL" ]; then
    wget https://ftp.gnu.org/gnu/gmp/$_GMP_TARBALL
fi
if ! [ -f "$_ISL_TARBALL" ]; then
    wget https://libisl.sourceforge.io/$_ISL_TARBALL
fi
if ! [ -f "$_MPC_TARBALL" ]; then
    wget https://ftp.gnu.org/gnu/mpc/$_MPC_TARBALL
fi
if ! [ -f "$_MPFR_TARBALL" ]; then
    wget https://ftp.gnu.org/gnu/mpfr/$_MPFR_TARBALL
fi

binutils_tar_link="$start_dir/$_BINUTILS_TARBALL"
gcc_tar_link="$start_dir/$_GCC_TARBALL"
gmp_tar_link="$start_dir/$_GMP_TARBALL"
isl_tar_link="$start_dir/$_ISL_TARBALL"
mpc_tar_link="$start_dir/$_MPC_TARBALL"
mpfr_tar_link="$start_dir/$_MPFR_TARBALL"
newlib_tar_link="$start_dir/$_NEWLIB_TARBALL"

##-------------------------------------------------------------
## Function definitions
##-------------------------------------------------------------
function announce {
    now=$(date +"%T")
    echo
    echo "[$now] $1"
    echo
}

_pushd() {
    command pushd "$@" >/dev/null || exit 1
}

_popd() {
    command popd >/dev/null || exit 1
}

# extract (URL, tarball_name)
extract() {
    local url=$1
    local tarball_name=$2

    local tarball="${url##*/}"

    # Eat up strings after 2 dots i.e.   .tar.gz
    local tarball_dir="${tarball%.*}"
    local tarball_dir="${tarball_dir%.*}"

    # extract
    tar xf "$url"
    mv "$tarball_dir" "$tarball_name"
}

##-------------------------------------------------------------
## Script main
##-------------------------------------------------------------

install_dir="${root_dir}/install"
PATH=${PATH}:$install_dir/bin
PATH=${PATH}:$install_dir

mkdir -p "$root_dir"
announce "Moving to root=$root_dir"
cd "$root_dir" || exit 1

mkdir -p "$install_dir"
if [ "$clean_install" = "true" ]; then
    _pushd "$install_dir"
    rm -rf ./*
    _popd
fi

#libs
#-------------------
announce "Working on libs..."
libs_dir="$root_dir/libs"

mkdir -p "$libs_dir"
_pushd "$libs_dir"

# download source
extract "$gmp_tar_link" gmp
extract "$mpfr_tar_link" mpfr
extract "$mpc_tar_link" mpc
extract "$isl_tar_link" isl

_popd # back to root dir

announce "Working on libs... Complete!"

if [ "$build_binutils" = "true" ]; then
    #binutils
    #-------------------
    announce "Working on binutils..."
    binutils_dir="$root_dir/binutils"
    binutils_src_dir="$binutils_dir/binutils-src"
    binutils_build_dir="$binutils_dir/build-$target"

    mkdir -p "$binutils_dir"
    _pushd "$binutils_dir"

    # download source
    extract "$binutils_tar_link" binutils-src

    # link any required libraries
    ln -s "$libs_dir/isl" "$binutils_src_dir/isl"
    ln -s "$libs_dir/gmp" "$binutils_src_dir/gmp"

    mkdir -p "$binutils_build_dir"
    _pushd "$binutils_build_dir"

    # perform cleanup
    _pushd "$binutils_src_dir"
    make distclean >/dev/null
    _popd
    rm -rf ./*

    # build and install
    $binutils_src_dir/configure \
        --prefix=$install_dir \
        --target=$target \
        >log-configure-$target.log
    make -j$(nproc) >log-make-$target.log
    make install >log-install-$target.log
    _popd

    _popd # back to root dir
    tree "$install_dir" >"$install_dir/post-binutils-install.tree"
    announce "Working on binutils... Complete!"
fi

if [ "$build_gcc_static" = "true" ]; then
    #gcc-static
    #-------------------
    announce "Working on gcc-static..."
    gcc_dir="$root_dir/gcc"
    gcc_src_dir="$gcc_dir/gcc-src"
    gcc_build_dir="$gcc_dir/build-$target"

    mkdir -p "$gcc_dir"
    _pushd "$gcc_dir"

    # download source
    extract "$gcc_tar_link" gcc-src

    # link any required libraries
    ln -s "$libs_dir/isl" "$gcc_src_dir/isl"
    ln -s "$libs_dir/gmp" "$gcc_src_dir/gmp"
    ln -s "$libs_dir/mpfr" "$gcc_src_dir/mpfr"
    ln -s "$libs_dir/mpc" "$gcc_src_dir/mpc"

    mkdir -p "$gcc_build_dir"
    _pushd "$gcc_build_dir"

    # perform cleanup
    rm -rf ./*

    # build and install
    announce "gcc-static configure"
    $gcc_src_dir/configure \
        --prefix=$install_dir \
        --target=$target \
        --enable-languages=c \
        --with-newlib \
        >log-configure-$target.log
    announce "gcc-static make"
    make -j$(nproc) all-gcc >log-make-$target.log
    announce "gcc-static install"
    make install-gcc >log-install-$target.log

    tree "$install_dir" >"$install_dir/post-gcc-static-install.tree"

    announce "gcc-static-libgcc make"
    make -j$(nproc) -k all-target-libgcc
    announce "gcc-static-libgcc install"
    make -i install-target-libgcc
    _popd

    _popd # back to root dir
    tree "$install_dir" >"$install_dir/post-gcc-static-libgcc-install.tree"
    announce "Working on gcc-static... Complete!"
fi

if [ "$build_newlib" = "true" ]; then
    #newlib
    #-------------------
    announce "Working on newlib..."
    newlib_dir="$root_dir/newlib"
    newlib_src_dir="$newlib_dir/newlib-src"
    newlib_build_dir="$newlib_dir/build-$target"

    mkdir -p "$newlib_dir"
    _pushd "$newlib_dir"

    # download source
    extract "$newlib_tar_link" newlib-src

    mkdir -p "$newlib_build_dir"
    _pushd "$newlib_build_dir"

    # perform cleanup
    rm -rf ./*

    # build and install
    announce "newlib configure"
    $newlib_src_dir/configure \
        --prefix=$install_dir \
        --target=$target \
        >log-configure-$target.log
    announce "newlib make"
    make -j$(nproc) all >log-make-$target.log
    announce "newlib install"
    make install >log-install-$target.log
    _popd

    _popd # back to root dir
    tree "$install_dir" >"$install_dir/post-newlib-install.tree"
    announce "Working on newlib... Complete!"
fi

if [ "$build_gcc" = "true" ]; then
    #gcc
    #-------------------
    announce "Working on gcc..."
    gcc_dir="$root_dir/gcc"
    gcc_src_dir="$gcc_dir/gcc-src"
    gcc_build_dir="$gcc_dir/build-$target"

    _pushd "$gcc_build_dir"

    # build and install
    announce "gcc configure"
    $gcc_src_dir/configure \
        --prefix=$install_dir \
        --target=$target \
        --enable-languages=c,c++ \
        --with-newlib \
        >log-configure-$target.log
    announce "gcc make"
    make -j$(nproc) all >log-make-$target.log
    announce "gcc install"
    make install >log-install-$target.log

    _popd # back to root dir
    tree "$install_dir" >"$install_dir/post-gcc-install.tree"
    announce "Working on gcc... Complete!"
fi

announce "Cross toolchain ready!"
