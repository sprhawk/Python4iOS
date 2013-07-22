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
# according to https://github.com/kivy/kivy-ios/commit/0062353c5812b893d6d4bcc97eb221cd782a298c
# use --without-pymalloc to suppress "32-bit absolute address out of range " warning
OPTIONAL="--with-signal-module --disable-toolbox-glue --without-pymalloc"

PYTHON_DISABLED_MODULE_LIST=("_ctypes")

ARCHS=(i386 armv7 armv7s)
#ARCHS=(armv7)

ROOT=`pwd`
BUILD_PATH="$ROOT/build/python"

PYTHON_FOR_BUILD=$BUILD_PATH/macosx/bin/python
PGEN_FOR_BUILD=$BUILD_PATH/macosx/bin/pgen

## Due to modifications to multiple files in Python dir, we need a clean source base
#if [ -d "$PYTHONDIR" ]; then
#    echo "Cleaning $PYTHONDIR source ..."
#    rm -rf "$PYTHONDIR" 
#fi

if [ ! -d "$PYTHONDIR" ]; then
    if [ ! -f "Python-$PYTHONVER.tar.bz2" ]; then
        wget -c "http://python.org/ftp/python/$PYTHONVER/Python-$PYTHONVER.tar.bz2"
    fi
    echo "Extracting Python-$PYTHONVER.tar.bz2"
    tar xf "Python-$PYTHONVER.tar.bz2"
fi
    
# ###################################
# build native machine version of Python
if [ ! -e "$PYTHON_FOR_BUILD" ]; then
    if [ -d $BUILD_PATH ]; then
        echo "Cleaning build directory ..."
        rm -rf "$BUILD_PATH/*"
    else
        mkdir -p "$BUILD_PATH"
    fi

    #####################################################################
    # for executing setup.py, a cross compliation need a native python first
    cd $ROOT/$PYTHONDIR
    ./configure --prefix=$BUILD_PATH/macosx $PYFEATURES $OPTIONAL
    make && make install
    if [ 0 != $? ]; then
        echo "Making native error, exiting ..."
        exit 1
    fi
    cp Parser/pgen $BUILD_PATH/macosx/bin
    make clean
fi
# #################################
# end build for native


cd $ROOT

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
#      3. to eliminate duplicated symbols (math.o and timemodule.o)
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

    if [ -d "$BUILD_PATH/$ARCH" ]; then
        echo "cleaning old builds .."
        rm -rf "$BUILD_PATH/$ARCH"
    fi

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

mkdir -p universal/{lib,include,modules}
LIBPYTHON_FILES=""
for ARCH in ${ARCHS[@]} 
do
   LIBPYTHON_FILES+="$ARCH/lib/libpython$PYTHON_MAJOR_VER.a "
done

echo "Combing multi-arch libpython$PYTHON_MAJOR_VER.a ..."
lipo $LIBPYTHON_FILES -create -output universal/libpython$PYTHON_MAJOR_VER.a 

if [ 0 != $? ]; then
    echo "Create universal lib error, exiting ..."
    cd "$ROOT"
    exit 1
fi

cd $BUILD_PATH
echo "Combing multi-arch modules  ..."
MODULE_H="universal/modules/pythonmodules.h"
echo "#include <Python.h>\n" > $MODULE_H

for a in ${ARCHS[0]}/lib/python$PYTHON_MAJOR_VER/lib-dynload/*.a
do
    a="`basename ${a}`"
    
    fn=""
    if [[ "$a" =~ lib(.+)module.a ]]; then
        mn=${BASH_REMATCH[1]}
        case "$mn" in
            "socket" )
                fn="init_socket"
                ;;
            *)
                fn="init$mn"
                ;;
        esac
    else
        case "$a" in
            "liboperator.a")
                fn="initoperator"        
                ;;
        esac
    fi
    if [ ! -z $fn ]; then
        echo "adding $fn() definition into header"
        echo "extern PyMODINIT_FUNC $fn(void);\n" >> $MODULE_H
    fi
    EXTENSIONS_FILES=""
    for ARCH in ${ARCHS[@]} 
    do
        # because building of static library is just a work around, the path 
        #for the lib is not very proper. I don't want to make more modifications, 
        # so just leave as it.
       EXTENSIONS_FILES+=" $ARCH/lib/python$PYTHON_MAJOR_VER/lib-dynload/$a "
    done
    lipo $EXTENSIONS_FILES -create -output "universal/modules/$a"
    
    if [ 0 != $? ]; then
        echo "Create universal lib error, exiting ..."
        cd "$ROOT"
        exit 1
    fi
done

ARCH=${ARCHS[0]}
echo "Copying lib files ..."
cp -v -r $ARCH/lib/python$PYTHON_MAJOR_VER universal/lib/
echo "Copying include headers ..."
cp -r $ARCH/include/python$PYTHON_MAJOR_VER universal/include/
echo "Removing .pyc files .."
find universal -iname "*.pyc" -exec rm -f {} \;
echo "Removing .py files .."
find universal -iname "*.py" -exec rm -f {} \;
echo "Removing lib-dynload ..."
rm -rf universal/lib/python$PYTHON_MAJOR_VER/lib-dynload

cd $ROOT
echo "Done."

