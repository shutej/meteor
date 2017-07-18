#!/usr/bin/env bash

set -e
set -u

UNAME=$(uname)
ARCH=$(uname -m)
MONGO_VERSION=3.2.12
NODE_VERSION=4.8.1
NPM_VERSION=4.4.4

# save number of processors to define max parallelism for build processes
# we call that via additional bash process to not get trapped on error
# Linux and compatible...
NPROCESSORS=$(/usr/bin/env bash -c "getconf _NPROCESSORS_ONLN 2>/dev/null; exit 0")
# FreeBSD and compatible...
[ -z "$NPROCESSORS" ] && NPROCESSORS=$(/usr/bin/env bash -c "getconf NPROCESSORS_ONLN 2>/dev/null; exit 0")
# Not identifiable, set fix to minimal resources...
[ -z "$NPROCESSORS" ] && NPROCESSORS=1

# The METEOR_UNIVERSAL_FLAG will save the indicator how to handle unofficially
# support environments. For armvXl boards we are support pre built binaries from
# bintray. For all other systems we check, that there are system binries available
# for node and mongo. If METEOR_UNIVERSAL_FLAG is not set, then this runs as same 
# as official meteor installer and starter
METEOR_UNIVERSAL_FLAG=

if [ "$UNAME" == "Linux" ] ; then
    if [ "$ARCH" != "i686" -a "$ARCH" != "x86_64" ] ; then
        if [ "$ARCH" != "armv6l" -a "$ARCH" != "armv7l" -a "$ARCH" != "armv8l" -a "$ARCH" != "aarch64" ] ; then
            # set flag that we are in universal system environment support mode
            METEOR_UNIVERSAL_FLAG="env"
        else
            # set flag that we are in unofficial ARM support mode
            METEOR_UNIVERSAL_FLAG="arm"
        fi
    fi

    OS="linux"

    stripBinary() {
        strip --remove-section=.comment --remove-section=.note $1
    }
elif [ "$UNAME" = "FreeBSD" -o "$UNAME" = "OpenBSD" -o "$UNAME" = "NetBSD" ] ; then
    if [ "$ARCH" != "i686" -a "$ARCH" != "x86_64" -a "$ARCH" != "amd64" ] ; then
        # set flag that we are in universal system environment support mode
        METEOR_UNIVERSAL_FLAG="env"
    else
        # set flag that we are in unofficial xBSD support mode
        METEOR_UNIVERSAL_FLAG="bsd"
    fi

    OS="bsd"

    stripBinary() {
        strip --remove-section=.comment --remove-section=.note $1
    }
elif [ "$UNAME" == "Darwin" ] ; then
    SYSCTL_64BIT=$(sysctl -n hw.cpu64bit_capable 2>/dev/null || echo 0)
    if [ "$ARCH" == "i386" -a "1" != "$SYSCTL_64BIT" ] ; then
        # some older macos returns i386 but can run 64 bit binaries.
        # Probably should distribute binaries built on these machines,
        # but it should be OK for users to run.
        ARCH="x86_64"
    fi

    if [ "$ARCH" != "x86_64" ] ; then
        echo "Unsupported architecture: $ARCH"
        echo "Meteor only supports x86_64 for now."
        exit 1
    fi

    OS="osx"

    # We don't strip on Mac because we don't know a safe command. (Can't strip
    # too much because we do need node to be able to load objects like
    # fibers.node.)
    stripBinary() {
        true
    }
else
    echo "This OS not yet supported"
    exit 1
fi

PLATFORM="${UNAME}_${ARCH}"

if [ "$UNAME" == "Linux" ]
then
    if [ "$ARCH" == "i686" ]
    then
        NODE_TGZ="node-v${NODE_VERSION}-linux-x86.tar.gz"
    elif [ "$ARCH" == "x86_64" ]
    then
        NODE_TGZ="node-v${NODE_VERSION}-linux-x64.tar.gz"
    elif [ "$ARCH" == "armv8l" -o "$ARCH" == "aarch64" ]
    then
        NODE_TGZ="node-v${NODE_VERSION}-linux-arm64.tar.gz"
    elif [ "$ARCH" == "armv7l" ]
    then
        NODE_TGZ="node-v${NODE_VERSION}-linux-armv7l.tar.gz"
    elif [ "$ARCH" == "armv6l" ]
    then
        NODE_TGZ="node-v${NODE_VERSION}-linux-armv6l.tar.gz"
    elif [ -n "$METEOR_UNIVERSAL_FLAG" ]
    then
      # If using METEOR UNIVERSAL we can skip this test for NODE_TGZ
      # create unusable setting here just as a "Debug" output
      # this will be normally overriden in generate-dev-bundle.sh when
      # separate build of node is available by build-node-for-dev-bundle.sh
      NODE_TGZ=""
    else
        echo "Unknown architecture: $UNAME $ARCH"
        exit 1
    fi
elif [ "$UNAME" == "Darwin" ]
then
    NODE_TGZ="node-v${NODE_VERSION}-darwin-x64.tar.gz"
elif [ "$UNAME" = "FreeBSD" -o "$UNAME" = "OpenBSD" -o "$UNAME" = "NetBSD" ]
then
    if [ -n "$METEOR_UNIVERSAL_FLAG" ]
    then
      # If using METEOR UNIVERSAL we can skip this test for NODE_TGZ
      # create unusable setting here just as a "Debug" output
      # this will be normally overriden in generate-dev-bundle.sh when
      # separate build of node is available by build-node-for-dev-bundle.sh
      NODE_TGZ=""
    else
        echo "Unknown architecture: $UNAME $ARCH"
        exit 1
    fi
else
    echo "Unknown architecture: $UNAME $ARCH"
    exit 1
fi

SCRIPTS_DIR=$(dirname $0)
cd "$SCRIPTS_DIR/.."
CHECKOUT_DIR=$(pwd)

DIR=$(mktemp -d -t generate-dev-bundle-XXXXXXXX)
trap 'rm -rf "$DIR" >/dev/null 2>&1' 0

cd "$DIR"
chmod 755 .
umask 022
mkdir build
cd build
