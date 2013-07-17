#! /bin/sh
#
# by hongbo.yang.me
# 2013-Jul-07

# 
# build python 2.7.5 for iOS
#

# Clang
# -Wno-unused-value -Wno-empty-body -Qunused-arguments

# LLVM 2.8
# -no-integrated-as ----- for ctypes

SDKVERSION=6.1
PYTHONVER="2.7.5"
PYTHONDIR="Python-$PYTHONVER"

PWD=`pwd`

if [ ! -d "$PYTHONDIR" ]; then
    echo "Please download python source code and extract it into $PYTHONDIR"
    exit 1
fi

XCODE=`xcode-select -print-path`

if [ ! -d "$XCODE" ]; then
    echo "The Developer tools at $XCODE is not found"
    exit 1
fi

#ARCHS="i386 armv7 armv7s"
ARCHS="i386"
for ARCH in ${ARCHS}
do
    echo "building arch: $ARCH ..."

    unset CC
    unset CFLAGS
    unset CPP
    unset CPPFLAGS
    unset LD
    unset LDFLAGS

    if [ "$ARCH" == "i386" ]; then
        PLATFORM="iPhoneSimulator"
    else
        PLATFORM="iPhoneOS"
    fi

    DEVELOPER="$XCODE/Platforms/$PLATFORM.platform/Developer"
    SDKROOT="$DEVELOPER/SDKs/$PLATFORM$SDKVERSION.sdk"
    export CC="$DEVELOPER/usr/bin/llvm-gcc"
    export CFLAGS="-arch $ARCH -I$SDKROOT/usr/include -isysroot $SDKROOT"

    export CPPFLAGS=$CFLAGS

    export CXX="$DEVELOPER/usr/bin/llvm-g++"
    export CXXFLAGS=$CPPFLAGS

    export LD="$DEVELOPER/usr/bin/ld"
    export LDFLAGS="-isysroot "$SDKROOT" -L$SDKROOT/usr/lib"


    PYINSTDIR="--prefix=$PWD/python-staticlib-ios/$ARCH"
    # due to some bug of configure script, you must remove a "exit 1" when testing availablity of getaddrinfo 
    patch -Np0 $PWD/$PYTHONDIR/configure <$PWD/configure.patch
    PYFEATURES="--enable-shared=no --enable-profiling=no --enable-ipv6=yes --with-threads"
    OPTIONAL="--with-system-ffi --with-signal-module --disable-toolbox-glue"
    BUILD_TARGET="`$CC -arch $ARCH -v 2>&1| sed -nE 's/Target: (.+)/\1/p'`"
    BUILD="--build $BUILD_TARGET"
    HOST="--host `$CC -v 2>&1 | sed -nE 's/Target: (.+)/\1/p'`"
    TARGET="--target $BUILD_TARGET"

    cd $PYTHONDIR
    ./configure $BUILD $HOST $TARGET $PYINSTDIR $PYFEATURES $OPTIONAL
    #$HOST $BUILD $TARGET"

    if [ 0 != $? ]; then
        echo "exiting ..."
        cd $PWD 
        exit 1
    fi 
    make && make install && make clean
    cd $PWD
done

echo "Done."

