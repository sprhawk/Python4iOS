#!/bin/bash

cd "$ROOT"
echo "building extensions ..."

ARCHS=(i386 armv7 armv7s)
archives=()
objs=()
for ARCH in ${ARCHS[@]}
do
    echo "buiding $ARCH ..." 
    if [ ! -d "$LIB_DIR/$ARCH" ]; then
        mkdir -p "$LIB_DIR/$ARCH"
    fi

    source "environment.sh"
    CFLAGS+=" -I$PYTHON_INCLUDE "

    
    objs=()
    for SOURCE in ${SOURCES[@]}
    do
        obj=${SOURCE%.c}.o
        files=$(find $SOURCE_DIR -name "$SOURCE" -type f) 
        # generate output .o files
        for f in ${files[@]}
        do
            o="$LIB_DIR/$ARCH/$obj"
            objs+=($o)
            $CC $CFLAGS -o "$o" -c $f
        done
    done
    
    libpath="$LIB_DIR/$ARCH/$EXT_LIB_NAME"
    $AR -r "$libpath" ${objs[@]}
    archives+=("$libpath") 
done
echo "combining multi-arch ..."
lipo ${archives[@]} -create -output "$BUILD_DIR/$EXT_LIB_NAME"

if [ 0 != $? ]; then
    echo "lipo failed ..."
    exit 1
fi

echo "create module file to load static linked extension"
for SOURCE in ${SOURCES[@]}
do
    files=$(find $BUILD_DIR -name "$SOURCE" -type f ) 
    for f in ${files[@]}
    do
        x=$(dirname $f)
        f=$(basename $f)
        x="$x/__init__.py"
        m=${f%.c}
        echo "generating fake $(basename $x)"
        echo "# a hack to the extension" >> $x
        echo "try:" >> $x
        echo "    import $m" >> $x
        echo "except:" >> $x
        echo "    $m = None" >> $x
        echo "# just a work around" >> $x
        python -OO $x
    done
done

echo "removing *.py ..."
cd "$BUILD_DIR"
#find . -name "*.py" -type f -exec rm -f {} \;

cd "$ROOT"

