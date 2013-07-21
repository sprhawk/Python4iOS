#!/bin/bash

if [ ! -f "$PYTHON_INCLUDE/Python.h" ]; then
    echo "you must build libpython first ..."
    exit 1
fi

if [ ! -d "$PACKAGE_ROOT" ]; then
    if [ -f "$PACKAGE.tar.bz2" ]; then
        tar xvf "$PACKAGE.tar.bz2"
    else
        if [ ! -z "$PACKAGE_URL" ]; then
             wget --no-check-certificate "$PACKAGE_URL"
             if [ 0 == $? ]; then
                 tar xvf "$PACKAGE.tar.bz2"
             else
                 echo "failed to download $PACKAGE.tar.bz2"
                exit 1
             fi
        else
            echo "please download $PACKAGE by yourself"
            exit 1
        fi
    fi
fi

cd "$PACKAGE_ROOT"
python setup.py build_py -O2 -d "$BUILD_DIR"

cd "$ROOT"

