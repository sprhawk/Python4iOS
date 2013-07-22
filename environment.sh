#! /bin/sh
#
# by hongbo.yang.me
# 2013-Jul-21

# 
# build environment
#

SDKVERSION=6.1
IPHONEOS_MIN_VERSION=5.0

unset CC
unset CFLAGS
unset CPP
unset CPPFLAGS
unset LD
unset LDFLAGS
unset AR

XCODE=`xcode-select -print-path`

if [ ! -d "$XCODE" ]; then
    echo "The Developer tools at $XCODE is not found"
    exit 1
fi
if [ "$ARCH" == "i386" ]; then
    PLATFORM="iPhoneSimulator"
else
    PLATFORM="iPhoneOS"
    CFLAGS="-mthumb "
fi

# adding -miphoneos-version-min to surpress compilation errors
DEVELOPER="$XCODE/Platforms/$PLATFORM.platform/Developer"
SDKROOT="$DEVELOPER/SDKs/$PLATFORM$SDKVERSION.sdk"
export CC="$DEVELOPER/usr/bin/llvm-gcc"
# http://developer.apple.com/library/mac/#releasenotes/Darwin/SymbolVariantsRelNotes/index.html
# sys/cdefs.h
#
export CFLAGS+=" -D__DARWIN_ONLY_VERS_1050=1 -D__DARWIN_ONLY_64_BIT_INO_T=1 -D__DARWIN_ONLY_UNIX_CONFORMANCE=1 -g -pipe -arch $ARCH -O2 -I$SDKROOT/usr/include -isysroot $SDKROOT -miphoneos-version-min=$IPHONEOS_MIN_VERSION  -F$SDKROOT/System/Library/Frameworks -g -Wall "
export CPP="$CPP"
export CPPFLAGS=$CFLAGS

export CXX="$DEVELOPER/usr/bin/llvm-g++"
export CXXFLAGS=$CPPFLAGS

export LD="$DEVELOPER/usr/bin/ld"
export LDFLAGS="-arch $ARCH -L$SDKROOT/usr/lib -miphoneos-version-min=$IPHONEOS_MIN_VERSION -F$SDKROOT/System/Library/Frameworks -L$SDKROOT/usr/lib/system"

export AR="$DEVELOPER/usr/bin/ar"

PYINSTDIR="--prefix=$BUILD_PATH/$ARCH"
# due to some bug of configure script, you must remove a "exit 1" when testing availablity of getaddrinfo 
#BUILD_TARGET="`$CC -arch $ARCH -v 2>&1| sed -nE 's/Target: (.+)/\1/p'`"
BUILD_TARGET="$ARCH-apple-darwin"
BUILD="--build=$BUILD_TARGET"

HOST_PLATFORM="`$CC -v 2>&1 | sed -nE 's/Target: (.+)/\1/p'`"
HOST="--host=$HOST_PLATFORM"

TARGET="--target $BUILD_TARGET"

export _PYTHON_HOST_PLATFORM="$HOST_PLATFORM"
    
