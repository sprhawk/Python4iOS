#!/bin/bash

ROOT="`pwd`"
PACKAGE="Twisted-13.1.0"
PACKAGE_URL="https://pypi.python.org/packages/source/T/Twisted/Twisted-13.1.0.tar.bz2#md5=5609c91ed465f5a7da48d30a0e7b6960 "
LIB_NAME="twisted"
PACKAGE_ROOT="$PACKAGE"
SOURCE_DIR="$PACKAGE_ROOT/twisted"
# SOURCES is a list for c source file to be compiled and linked into a static lib
# portmap is not support under iPhoneOS
SOURCES=("sendmsg.c" "raiser.c")
BUILD_DIR="$ROOT/build/$LIB_NAME"
LIB_DIR="$BUILD_DIR/lib"
PY_DIR="$BUILD_DIR/twisted"
EXT_LIB_NAME="lib$LIB_NAME.a"
PYTHON_INCLUDE="$ROOT/build/python/universal/include/python2.7"

source _build_package.sh
source _build_ext.sh

echo "creating $BUILD_DIR/$LIB_NAME.h"
echo -e "#include <Python.h>\n" > "$BUILD_DIR/$LIB_NAME.h"

for SOURCE in ${SOURCES[@]}
do
    module="${SOURCE%.c}"
    echo -e "extern PyMODINIT_FUNC init$module(void);\n" >> "$BUILD_DIR/$LIB_NAME.h"
done

echo "Done."
