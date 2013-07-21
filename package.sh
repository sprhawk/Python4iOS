#!/bin/bash

ROOT=`pwd`
LIB_DIR="pythonlib"

PYTHON_DIR="build/python/universal" 

SITE_PACKAGES_DIR="$LIB_DIR/lib/python2.7/site-packages"

if [ ! -d "$LIB_DIR" ]; then
    mkdir -p "$LIB_DIR"
fi


if [ -d "$PYTHON_DIR" ]; then
    cp -v -r "$PYTHON_DIR"/* "$LIB_DIR"/
else
    echo "libpython is not built yet ?"
    exit 1
fi

if [ ! -d "$SITE_PACKAGES_DIR" ]; then
    echo "not found $SITE_PACKAGES_DIR"
    exit 1
fi

cp -v -r "build/twisted/twisted" "$SITE_PACKAGES_DIR/"
cp -v "build/twisted/libtwisted_ext.a" "$LIB_DIR/"
cp -v "build/twisted/twisted.h" "$LIB_DIR/"

cp -v -r "build/zope.interface/zope" "$SITE_PACKAGES_DIR/"
cp -v "build/zope.interface/libzope_interface.a" "$LIB_DIR/"
cp -v "build/zope.interface/zope_interface.h" "$LIB_DIR/"
