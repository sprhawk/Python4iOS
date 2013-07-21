#! /bin/sh
#
# by hongbo.yang.me
# 2013-Jul-07

# 
# build python 2.7.5 for iOS
#

PYTHON_MAJOR_VER="2.7"
PYTHONVER="2.7.5"
PYTHONDIR="Python-$PYTHONVER"
MAKEFILE_PRE_IN_PATCH="Makefile.pre.in-ios-$PYTHONVER.patch"
CONFIGURE_PATCH="configure-ios-$PYTHONVER.patch"
SETUP_PY_PATCH="setup.py-ios-$PYTHONVER.patch"

PYFEATURES="--enable-shared=no --enable-profiling=no --enable-ipv6=yes --with-threads"
OPTIONAL="--with-signal-module --disable-toolbox-glue"

PYTHON_DISABLED_MODULE_LIST=("_ctypes")

ARCHS=(i386 armv7 armv7s)
#ARCHS=(i386)

ROOT=`pwd`

# build native machine version of Python

BUILD_PATH=$ROOT/build

if [ -d $BUILD_PATH ]; then
    echo "Cleaning build directory ..."
    rm -rf build/*
fi

# Due to modifications to multiple files in Python dir, we need a clean source base
if [ -d "$PYTHONDIR" ]; then
    echo "Cleaning $PYTHONDIR source ..."
    rm -rf "$PYTHONDIR" 
fi

if [ ! -f "Python-$PYTHONVER.tar.bz2" ]; then
    wget -c "http://python.org/ftp/python/$PYTHONVER/Python-$PYTHONVER.tar.bz2"
fi
echo "Extracting Python-$PYTHONVER.tar.bz2"
tar xf "Python-$PYTHONVER.tar.bz2"

#####################################################################
# for executing setup.py, a cross compliation need a native python first
cd $ROOT/$PYTHONDIR
./configure --prefix=$BUILD_PATH/macosx $PYFEATURES $OPTIONAL
make && make install
if [ 0 != $? ]; then
    echo "Making native error, exiting ..."
    exit 1
fi
cp Parser/pgen $BUILD_PATH/MacOSX/bin
make clean
cd $ROOT

PYTHON_FOR_BUILD=$BUILD_PATH/MacOSX/bin/python
PGEN_FOR_BUILD=$BUILD_PATH/MacOSX/bin/pgen

####################################################################
echo "patching configure and Makefile ..."
cd $ROOT/$PYTHONDIR
#hack: to use native build of pgen
patch -Np0 <../$MAKEFILE_PRE_IN_PATCH
#hack: 1. to add cross complication support to iOS/MacOSX
#      2. to fix a bug for checking getaddrinfo
patch -Np0 <../$CONFIGURE_PATCH
#hack: 1. to add a enabled_module_list (not used at the moment)
#      2. to work around to build static libaries of modules
patch -Np0 <../$SETUP_PY_PATCH

#hack: to remove ctypes support
LIST=""
for module in ${PYTHON_DISABLED_MODULE_LIST[@]} 
do
    LIST="\"$module\", $LIST"
done

if [ "$LIST" != "" ]; then
    sed -e "s/\(disabled_module_list = \)\[\]/\1\[$LIST\]/" -i .org setup.py
fi

cd $ROOT

##################################################################
# configure needs config.site for cross compiling
touch "$PYTHONDIR/config.site"
echo "ac_cv_file__dev_ptmx=no" > "$ROOT/$PYTHONDIR/config.site"
echo "ac_cv_file__dev_ptc=no" >> "$ROOT/$PYTHONDIR/config.site"
export CONFIG_SITE="$ROOT/$PYTHONDIR/config.site"

for ARCH in ${ARCHS[@]}
do
    echo ""
    echo "building arch: $ARCH ..."
    echo ""
    
    source ./environment.sh

    cd "$ROOT/$PYTHONDIR"
    PYTHON_FOR_BUILD="$PYTHON_FOR_BUILD" PGEN_FOR_BUILD="$PGEN_FOR_BUILD" ./configure $BUILD $HOST $TARGET $PYINSTDIR $PYFEATURES $OPTIONAL 
    
    if [ 0 != $? ]; then
        echo "exiting ..."
        cd $ROOT
        exit 1
    fi 
    
    
    PYTHON_FOR_BUILD=$PYTHON_FOR_BUILD PGEN_FOR_BUILD=$PGEN_FOR_BUILD make libpython$PYTHON_MAJOR_VER.a sharedmods && make bininstall libinstall sharedinstall inclinstall 
    if [ 0 != $? ]; then
        echo "making error, exiting ..."
        cd "$ROOT"
        exit 1
    fi
    echo ""
    echo "Building python modules ..."
    CC="$CC" CFLAGS="$CFLAGS" AR="$AR" $PYTHON_FOR_BUILD setup.py install_lib
    make clean
    cd "$ROOT"
done

#if [ -f "$PYTHONDIR/config.site" ]; then
#    rm -f "$PYTHONDIR/config.site"
#fi
#export CONFIG_SITE=
#
#cd $ROOT/$PYTHONDIR
#if [ -f "setup.py.org" ]; then
#    cp -f setup.py.org setup.py
#fi
#cd $ROOT 

echo "Packaging ..."
cd $BUILD_PATH

mkdir -p universal/{lib,include}
LIBPYTHON_FILES=""
EXTENSIONS_FILES=""
for ARCH in ${ARCHS[@]} 
do
   LIBPYTHON_FILES+="$ARCH/lib/libpython$PYTHON_MAJOR_VER.a "
    # because building of static library is just a work around, the path for the 
    # lib is not very proper. I don't want to make more modifications, so just 
    # leave as it.
   EXTENSIONS_FILES+="$ARCH/lib/python$PYTHON_MAJOR_VER/lib-dynload/liball_extensions.a "
done

echo "Combing multi-arch libpython$PYTHON_MAJOR_VER.a ..."
lipo $LIBPYTHON_FILES -create -output universal/libpython$PYTHON_MAJOR_VER.a 

if [ 0 != $? ]; then
    echo "Create universal lib error, exiting ..."
    cd "$ROOT"
    exit 1
fi

echo "Combing multi-arch liball_extensions2.7.a ..."
lipo $EXTENSIONS_FILES -create -output universal/liball_extensions$PYTHON_MAJOR_VER.a 

if [ 0 != $? ]; then
    echo "Create universal lib error, exiting ..."
    cd "$ROOT"
    exit 1
fi

ARCH=${ARCHS[0]}
echo "Copying lib files ..."
cp -r $ARCH/lib/python$PYTHON_MAJOR_VER universal/lib/
cp -r $ARCH/include/python$PYTHON_MAJOR_VER universal/include/
find universal -iname "*.pyc" -exec rm -f {} \;
find universal -iname "*.py" -exec rm -f {} \;
rm -rf universal/lib/python$PYTHON_MAJOR_VER/lib-dynload

cd $ROOT
echo "Done."

