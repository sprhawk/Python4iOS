#!/bin/bash

ROOT=`pwd`
LIB_DIR="pythonlib"

PYTHON_DIR="build/python/universal" 

SITE_PACKAGES_DIR="$LIB_DIR/lib/python2.7/site-packages"

if [ ! -d "$SITE_PACKAGES_DIR" ]; then
    mkdir -p "$SITE_PACKAGES_DIR"
fi

if [ -d "$PYTHON_DIR" ]; then
    zip -r $PYTHON_DIR/lib/python2.7.zip $PYTHON_DIR/lib/python2.7
    
    if [ 0 == $? ]; then
        rm -rf $PYTHON_DIR/lib/python2.7
    fi
    cp -v -r "$PYTHON_DIR"/* "$LIB_DIR"/
else
    echo "libpython is not built yet ?"
    exit 1
fi

#if [ ! -d "$SITE_PACKAGES_DIR" ]; then
#    echo "not found $SITE_PACKAGES_DIR"
#    exit 1
#fi

zip -r build/twisted/twisted.zip build/twisted/twisted
cp -v -r "build/twisted/twisted.zip" "$SITE_PACKAGES_DIR/"
cp -v "build/twisted/libtwisted_ext.a" "$LIB_DIR/"
cp -v "build/twisted/twisted.h" "$LIB_DIR/"

zip -r build/zope.interface/zope.zip build/zope.interface/zope
cp -v -r "build/zope.interface/zope.zip" "$SITE_PACKAGES_DIR/"
cp -v "build/zope.interface/libzope_interface.a" "$LIB_DIR/"
cp -v "build/zope.interface/zope_interface.h" "$LIB_DIR/"
