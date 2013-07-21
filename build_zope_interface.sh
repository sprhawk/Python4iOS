#!/bin/bash

ROOT="`pwd`"
PACKAGE_NAME="zope.interface"
PACKAGE_VER="4.0.5"
LIB_NAME="zope_interface"
PACKAGE="$PACKAGE_NAME-$PACKAGE_VER"
PACKAGE_URL=""
PACKAGE_ROOT="$PACKAGE"
BUILD_DIR="$ROOT/build/$PACKAGE_NAME"
LIB_DIR="$BUILD_DIR/lib"
PY_DIR="$BUILD_DIR/$PACKAGE_NAME"

SOURCE_DIR="$PACKAGE_ROOT/src"
EXT_LIB_NAME="lib$LIB_NAME.a"
SOURCES=("_zope_interface_coptimizations.c")

PYTHON_INCLUDE="$ROOT/build/python/universal/include/python2.7"

source _build_package.sh
source _build_ext.sh

# work around
rm -f "$BUILD_DIR/zope/interface/_zope_interface_coptimizations.py*"

echo "creating $BUILD_DIR/$LIB_NAME.h"
echo "#include <Python.h>" > "$BUILD_DIR/$LIB_NAME.h"

# the init module func has different function name in Python 2 or 3
echo "extern PyMODINIT_FUNC init_zope_interface_coptimizations(void);" >> "$BUILD_DIR/$LIB_NAME.h"

echo "Done."
