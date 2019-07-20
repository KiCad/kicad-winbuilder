#!/bin/bash

# This script is intedned to copy the relevant dll's and other KiCad binaries
# from the MSYS2 version of the KiCad build, for standalone inclusion in the
# NSIS installer, which is run in the end of this script.


display_help() {
    echo "Usage: copydlls.sh [OPTION]"
    echo "  -h, --help           This help message"
    echo "  -a, --arch=ARCH      Determine arch for packaging"
    echo "  -p, --pkgpath=PATH   Path to pkg.tar.xz package"
    echo "  -d, --dirpath=PATH   Path to make install location (DESTDIR)"
    echo "  -m, --makensis=PATH  Path to makensis.exe"
    echo "  -s, --nsispath=PATH  Path to the NSIS packaging scripts"
    echo "  -o, --outdir=PATH    Path to output directory"
    echo "  -v, --version=VERSTR Version string"
    exit 1
}

decode_arch() {
    #echo $1
    tmp=${1#*-}
    tmp=${tmp#*-}
    tmp=${tmp%%-*}
    ARCH=$tmp
}

decode_ver() {
    tmp=${1#*-}
    tmp=${tmp#*-}
    tmp=${tmp#*-}
    tmp=${tmp#*-}
    tmp=${tmp#*-}
    tmp=${tmp%%-*}
    VERSION=$tmp
}

# This function expects a basename as:
# mingw-w64-x86_64-kicad-git-r5464.25b9a42-1-any.pkg.tar.xz
decode_pkg() {
    decode_arch $1
    decode_ver $1
}

extract_pkg() {
    pwd
    echo ======================

    # Extract the pkg.tar.xz
    bsdtar xf $1 --strip-components 1 -C $2
}

copy_pkg() {
    pwd
    echo ======================

    # Copy kicad install
    echo Copying KiCad binaries from $1 to $2
    cp -r $1/* $2
}

# Sets some other variables depending on the ARCH set
handle_arch() {
    #ARCH="x86_64"
    #ARCH="i686"

    if [ -z $ARCH ]; then
        echo "error: ARCH is not set"
        exit 0
    fi

    if [ "$ARCH" == "x86_64" ]; then
        echo 64bit
        MINGWBIN="mingw64"
    elif [ "$ARCH" == "i686" ]; then
        echo 32bit
        MINGWBIN="mingw32"
    else
        echo "Use either \"x86_64\" or \"i686\" for the ARCH variable"
        exit 0
    fi
}


for i in "$@"; do
case $i in
    -h|--help)
    display_help
    shift
    ;;
    -a=*|--arch=*)
    ARCH="${i#*=}"
    echo "\$ARCH=$ARCH"
    handle_arch
    shift
    ;;
    -p=*|--pkgpath=*)
    PKGPATH="${i#*=}"
    echo "\$PKGPATH=$PKGPATH"
    decode_pkg
    shift
    ;;
    -d=*|--dirpath=*)
    DIRPATH="${i#*=}"
    echo "\$DIRPATH=$DIRPATH"
    shift
    ;;
    -m=*|--makensis=*)
    MAKENSIS="${i#*=}"
    echo "\$MAKENSIS=$MAKENSIS"
    shift
    ;;
    -s=*|--nsispath=*)
    NSISPATH="${i#*=}"
    echo "\$NSISPATH=$NSISPATH"
    shift
    ;;
    -o=*|--outdir=*)
    OUTDIR="${i#*=}"
    echo "\$OUTDIR=$OUTDIR"
    shift
    ;;
    -v=*|--version=*)
    VERSION="${i#*=}"
    echo "\$VERSION=$VERSION"
    shift
    ;;
    *)
    echo "Unknown option, see the help info below:"
    echo "Arguments not understood: $@"
    display_help
    ;;
esac
done

# TODO: Check if both -p and -d is specified, this is illegal!

# Temporary dir to store the file structure
if [ -z "$OUTDIR" ]; then
    OUTDIR="$HOME/out"
    echo "warning: using hardcoded outdir path"
fi
# Path to the KiCad NSIS scripts
if [ -z "$NSISPATH" ]; then
    NSISPATH="$HOME/kicad-windows-nsis-packaging/nsis"
    echo "warning: using hardcoded nsis path"
fi
# Path to the NSIS compiler
if [ -z "$MAKENSIS" ]; then
    MAKENSIS="$HOME/NSIS-bin/Bin/makensis.exe"
    echo "warning: using hardcoded makensis path"
fi

copystuff() {
    SEARCHLIST=( \
        "*wx*.dll" \
        "*glew*.dll" \
        "*jpeg*.dll" \
        "libcairo*.dll" \
        "*ssl*.dll" \
        "libgomp*.dll" \
        "libstd*.dll" \
        "libgcc*.dll" \
        "libwinpthread-1.dll" \
        "libboost*.dll" \
        "libeay32.dll" \
        "ssleay32.dll" \
        "libpng*.dll" \
        "libpixman*.dll" \
        "libfreetype*.dll" \
        "libfontconfig*.dll" \
        "libharfbuzz*.dll" \
        "libexpat*.dll" \
        "libbz2*.dll" \
        "libglib*.dll" \
        "libiconv*.dll" \
        "zlib*.dll" \
        "libintl*.dll" \
        "libtiff*.dll" \
        "liblzma*.dll" \
        "libpython*.dll" \
        "libxml*.dll" \
        "libxslt*.dll" \
        "libexslt*.dll" \
        "xsltproc.exe"  \
        "libcurl*.dll" \
        "libidn*.dll" \
        "libssh*.dll" \
        "libbrotlicommon.dll" \
        "libbrotlidec.dll" \
        "librtmp*.dll" \
        "libgnutls*.dll" \
        "libhogweed*.dll" \
        "libnettle*.dll" \
        "libtasn*.dll" \
        "libp11-kit*.dll" \
        "libgmp*.dll" \
        "libffi*.dll" \
        "libFWOSPlugin.dll" \
        "libPTKernel.dll" \
        "libTK*.dll" \
        "libgraphite2.dll" \
        "libicu*.dll" \
        "libpcre*.dll" \
        "libngspice-0.dll" \
        "libfftw*.dll" \
        "libnghttp2*dll" \
        "libunistring-2.dll" \
        "libreadline7.dll" \
        "libtermcap-0.dll" \
        "libpsl-5.dll" \
        "libcrypto-1_1*.dll" \
        "libzstd.dll" )

    #echo Copying kicad binaries and stuff...
    #cp -r $MSYSDIR/bin/* $TARGETDIR/bin

    echo Copying dll dependencies...
    for i in ${SEARCHLIST[@]}; do
        FILE_LIST=$(find "$MSYSDIR/bin" -name "$i")
        if [ -z "$FILE_LIST" ]; then
            echo "Did not find any files matching $i"
        else
            echo "Copying $i"
            echo "$FILE_LIST" | xargs cp -t "$TARGETDIR/bin"
        fi
    done

    echo Copying include/python2.7...
    cp -r "$MSYSDIR/include/python2.7" "$TARGETDIR/include"

    echo Copying lib/python2.7...
    cp -r "$MSYSDIR/lib/python2.7/" "$TARGETDIR/lib/"
    # Get rid of any parts of the python install that are not required by
    # a KiCad installation
    rm -f "${TARGETDIR}/lib/python2.7/config/libpython2.7.dll.a"
    rm -rf "${TARGETDIR}/lib/python2.7/test"
    find "${TARGETDIR}/lib/python2.7/" -name "*.pyc" -type f -delete
    find "${TARGETDIR}/lib/python2.7/" -name "*.pyo" -type f -delete

    echo Copying ssl/certs/ca-bundle.crt...
    cp "$MSYSDIR/ssl/certs/ca-bundle.crt" "$TARGETDIR/ssl/certs/"

    echo Copying python...
    cp $MSYSDIR/bin/python.exe $TARGETDIR/bin
    cp $MSYSDIR/bin/python2w.exe $TARGETDIR/bin/pythonw.exe

    echo Copying Tk for python...
    cp $MSYSDIR/bin/tk86.dll $TARGETDIR/bin
    cp $MSYSDIR/bin/tcl86.dll $TARGETDIR/bin
    cp -r $MSYSDIR/lib/tk8.6 $TARGETDIR/lib
    cp -r $MSYSDIR/lib/tcl8.6 $TARGETDIR/lib

    echo Copying setuptools for python...
    cp $MSYSDIR/bin/easy_install.exe $TARGETDIR/bin
    cp $MSYSDIR/bin/easy_install-script.py $TARGETDIR/bin
    sed -i 's/^#!.*exe$/#!python.exe/' $TARGETDIR/bin/easy_install-script.py
    # Rest of setuptools in lib/python2.7/site-packages

    echo Copying pip for python...
    cp $MSYSDIR/bin/pip2.exe $TARGETDIR/bin/pip.exe
    cp $MSYSDIR/bin/pip2-script.py $TARGETDIR/bin/pip-script.py
    sed -i 's/^#!.*exe$/#!python.exe/' $TARGETDIR/bin/pip-script.py
    # Rest of pip in lib/python2.7/site-packages

    echo Copying ngspice library files...
    cp -r $MSYSDIR/lib/ngspice $TARGETDIR/lib

    echo Copying gdb...
    cp -r $MSYSDIR/bin/gdb.exe $TARGETDIR/bin

    echo Building NSIS installer exe...
    cp -r $NSISPATH $TARGETDIR
}


makensis() {
    cd "$TARGETDIR/nsis"
    pwd
    echo "This is still a work in progress... but GPL..." > ../COPYRIGHT.txt
    "$MAKENSIS" \
        //DPRODUCT_VERSION=$VERSION \
        //DOUTFILE="..\kicad-$VERSION-$ARCH.exe" \
        //DARCH="$ARCH" \
        install.nsi
    cd -
}

if [ ! -z $DIRPATH ]; then
    echo DIRPATH=$DIRPATH
    echo ARCH=$ARCH
    echo MINGWBIN=$MINGWBIN
    echo VERSION=$VERSION

    TARGETDIR="$OUTDIR/pack-$ARCH"
    MSYSDIR="/$MINGWBIN"

    echo Output will be in $TARGETDIR
    if [ -e $TARGETDIR ]; then
        rm -rf $TARGETDIR/*
    fi
    mkdir -p "$TARGETDIR/bin"
    mkdir -p "$TARGETDIR/lib"
    mkdir -p "$TARGETDIR/include"
    mkdir -p "$TARGETDIR/ssl/certs"
    #mkdir -p "$TARGETDIR/nsis"

    copystuff
    copy_pkg $DIRPATH "$TARGETDIR"
    makensis
fi

if [ ! -z $PKGPATH ]; then
    # This loop looks for package files in the PKGPATH
    for entry in "$PKGPATH"/*; do
    if [[ $entry == *"pkg.tar.xz"* ]]; then
        decode_pkg $(basename $entry)
        echo "Decoded pkg is $ARCH and $VERSION"
        handle_arch
        echo $ARCH $ARCH

        TARGETDIR="$OUTDIR/pack-$ARCH"
        MSYSDIR="/$MINGWBIN"

        echo "\$TARGETDIR=$TARGETDIR"
        echo "\$MSYSDIR=$MSYSDIR"

        echo Output will be in $TARGETDIR
        if [ -e $TARGETDIR ]; then
            rm -rf $TARGETDIR/*
        fi
        mkdir -p "$TARGETDIR/bin"
        mkdir -p "$TARGETDIR/lib"
        mkdir -p "$TARGETDIR/include"
        mkdir -p "$TARGETDIR/ssl/certs"
        #mkdir -p "$TARGETDIR/nsis"

        copystuff
        extract_pkg $entry "$TARGETDIR"
        makensis
    fi
    done
fi
