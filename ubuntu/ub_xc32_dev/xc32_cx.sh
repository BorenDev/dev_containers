#!/bin/sh

XC32_VERSION=v4.35
# Location of XC32
XC32DIR=/opt/microchip/xc32/$XC32_VERSION
# Where the sources are located.
SRCDIR=/workdir/xc32-${XC32_VERSION}-src/pic32c-source
# Where to store build artifacts.
BUILDDIR=/workdir/xc32-${XC32_VERSION}-src/pic32c-build
# Where to install the compiler.
INSTALLDIR=/workdir/xc32-${XC32_VERSION}-install

######################################
# At this point, you don't need to change anything unless you are
# customizing.
libmchp_srcdir=${SRCDIR}/mchp
expat_srcdir=${SRCDIR}/expat-2.1.1
binutils_srcdir=${SRCDIR}/binutils
gcc_srcdir=${SRCDIR}/gcc

# This is needed to hold libraries and include files needed by
# binutils and gcc.
hostinstalldir=${BUILDDIR}/opt

libmchp_builddir=${BUILDDIR}/libmchp
expat_builddir=${BUILDDIR}/expat
binutils_builddir=${BUILDDIR}/binutils
gcc_builddir=${BUILDDIR}/gcc

# First, build libmchp.
PS4="[libmchp] "
(
    set -ex

    rm -rf ${libmchp_builddir}
    mkdir -p ${libmchp_builddir}
    cd ${libmchp_builddir}

    ${libmchp_srcdir}/configure \
        --installdir=${hostinstalldir} \
        --smart-io-suffixdir=${libmchp_srcdir}

    make -f ${libmchp_srcdir}/Makefile all
    make -f ${libmchp_srcdir}/Makefile install
)
ret_code="$?"
if [ $ret_code -ne 0 ]; then
    echo "Error: ${PS4}failed to build!"
    exit "$ret_code"
fi

# Next, build expat.
PS4="[expat] "
(
    set -ex

    rm -rf ${expat_builddir}
    mkdir -p ${expat_builddir}
    cd ${expat_builddir}

    ${expat_srcdir}/configure --prefix=${hostinstalldir} --disable-shared

    make install
)
ret_code="$?"
if [ $ret_code -ne 0 ]; then
    echo "Error: ${PS4}failed to build!"
    exit "$ret_code"
fi

# Now set some macros that everything will need and put them in a
# header.  Although they are defined in the binutils target
# configuration, sometimes it doesn't reach the every file.  Also,
# host-lm.h is needed by license manager code.
PS4="[macros] "
(
    set -ex

    cat >${hostinstalldir}/include/host-defs.h <<EOF
#ifndef _BUILD_MCHP_
#define _BUILD_MCHP_ 1
#endif
#ifndef _BUILD_XC32_
#define _BUILD_XC32_ 1
#endif
#ifndef MCHP_BUILD_DATE
#define MCHP_BUILD_DATE __DATE__
#endif
#ifndef _XC32_VERSION_
#define _XC32_VERSION_ 4300
#endif
#ifndef TARGET_MCHP_pic32cX
#define TARGET_MCHP_pic32cX 1
#endif
#ifndef TARGET_IS_pic32cX
#define TARGET_IS_pic32cX 1
#endif
#ifndef MCHP_VERSION
#define MCHP_VERSION 4.35
#endif
EOF

    cat >${hostinstalldir}/include/host-lm.h <<EOF
#ifndef SKIP_LICENSE_MANAGER
#define SKIP_LICENSE_MANAGER
#endif
EOF
)
ret_code="$?"
if [ $ret_code -ne 0 ]; then
    echo "Error: ${PS4}failed to build!"
    exit "$ret_code"
fi

# Now binutils.
PS4="[binutils] "
(
    set -ex

    rm -rf ${binutils_builddir}
    mkdir -p ${binutils_builddir}
    cd ${binutils_builddir}

    ${binutils_srcdir}/configure \
        --target=pic32cx \
        --prefix=${INSTALLDIR} \
        --program-prefix=pic32c- \
        --with-sysroot=${INSTALLDIR}/pic32cx \
        --with-bugurl=http://example.com \
        --with-pkgversion="Microchip XC32 Compiler v4.35 custom" \
        --bindir=${INSTALLDIR}/bin/bin \
        --infodir=${INSTALLDIR}/share/doc/xc32-pic32c-gcc/info \
        --mandir=${INSTALLDIR}/share/doc/xc32-pic32c-gcc/man \
        --libdir=${INSTALLDIR}/lib \
        --disable-nls \
        --disable-werror \
        --disable-sim \
        --disable-gdb \
        --enable-interwork \
        --enable-plugins \
        --disable-64-bit-bfd \
        CPPFLAGS="-I${hostinstalldir}/include -imacros host-defs.h" \
        CFLAGS=-fcommon \
        LDFLAGS=-L${hostinstalldir}/lib

    make all \
        CPPFLAGS="-I${hostinstalldir}/include -imacros host-defs.h" \
        CFLAGS=-fcommon \
        LDFLAGS=-L${hostinstalldir}/lib

    make install

)
ret_code="$?"
if [ $ret_code -ne 0 ]; then
    echo "Error: ${PS4}failed to build!"
    exit "$ret_code"
fi

#:J:#  # Finally, GCC.
#:J:#  PS4="[gcc] "
#:J:#  (
#:J:#      set -ex
#:J:#
#:J:#      rm -rf ${gcc_builddir}
#:J:#      mkdir -p ${gcc_builddir}
#:J:#      cd ${gcc_builddir}
#:J:#
#:J:#      ${gcc_srcdir}/configure \
#:J:#          --target=pic32cx \
#:J:#          --prefix=${INSTALLDIR} \
#:J:#          --program-prefix=pic32c- \
#:J:#          --with-sysroot=${INSTALLDIR}/pic32cx \
#:J:#          --with-bugurl=http://example.com \
#:J:#          --with-pkgversion="Microchip XC32 Compiler v4.40 custom" \
#:J:#          --bindir=${INSTALLDIR}/bin/bin \
#:J:#          --infodir=${INSTALLDIR}/share/doc/xc32-pic32c-gcc/info \
#:J:#          --mandir=${INSTALLDIR}/share/doc/xc32-pic32c-gcc/man \
#:J:#          --libdir=${INSTALLDIR}/lib \
#:J:#          --libexecdir=${INSTALLDIR}/bin/bin \
#:J:#          --with-build-sysroot=${INSTALLDIR}/pic32cx \
#:J:#          --enable-stage1-languages=c \
#:J:#          --enable-languages=c,c++ \
#:J:#          --enable-target-optspace \
#:J:#          --disable-comdat \
#:J:#          --disable-libstdcxx-pch \
#:J:#          --disable-libstdcxx-verbose \
#:J:#          --disable-libssp \
#:J:#          --disable-libmudflap \
#:J:#          --disable-libffi \
#:J:#          --disable-libfortran \
#:J:#          --disable-bootstrap \
#:J:#          --disable-shared \
#:J:#          --disable-nls \
#:J:#          --disable-gdb \
#:J:#          --disable-libgomp \
#:J:#          --disable-threads \
#:J:#          --disable-tls \
#:J:#          --disable-sim \
#:J:#          --disable-decimal-float \
#:J:#          --disable-libquadmath \
#:J:#          --disable-shared \
#:J:#          --disable-checking \
#:J:#          --disable-maintainer-mode \
#:J:#          --enable-lto \
#:J:#          --enable-fixed-point \
#:J:#          --enable-gofast \
#:J:#          --enable-static \
#:J:#          --enable-sgxx-sde-multilibs \
#:J:#          --enable-sjlj-exceptions \
#:J:#          --enable-poison-system-directories \
#:J:#          --enable-obsolete \
#:J:#          --without-isl \
#:J:#          --without-cloog \
#:J:#          --without-headers \
#:J:#          --with-musl \
#:J:#          --with-dwarf2 \
#:J:#          --with-gnu-as \
#:J:#          --with-gnu-ld \
#:J:#          '--with-host-libstdcxx=-static-libgcc -static-libstdc++ -Wl,-lstdc++ -lm' \
#:J:#          CPPFLAGS="-I${hostinstalldir}/include -imacros host-defs.h" \
#:J:#          LDFLAGS=-L${hostinstalldir}/lib
#:J:#
#:J:#      make all-gcc \
#:J:#          STAGE1_LIBS="-lexpat -lmchp -Wl,-Bstatic -lstdc++ -Wl,-Bdynamic" \
#:J:#          CPPFLAGS="-I${hostinstalldir}/include -imacros host-defs.h" \
#:J:#          LDFLAGS=-L${hostinstalldir}/lib
#:J:#
#:J:#      make install-gcc
#:J:#  )
#:J:#  ret_code="$?"
#:J:#  if [ $ret_code -ne 0 ]; then
#:J:#      echo "Error: ${PS4}failed to build!"
#:J:#      exit "$ret_code"
#:J:#  fi
#:J:#
#:J:#  # Copy in the resource info file from an existing compiler installation.
#:J:#  PS4="[resource] "
#:J:#  (
#:J:#      set -ex
#:J:#
#:J:#      mkdir -p ${INSTALLDIR}/bin
#:J:#      cp xc32_device.info ${INSTALLDIR}/bin/xc32_device.info
#:J:#  )
#:J:#  ret_code="$?"
#:J:#  if [ $ret_code -ne 0 ]; then
#:J:#      echo "Error: ${PS4}failed to build!"
#:J:#      exit "$ret_code"
#:J:#  fi
