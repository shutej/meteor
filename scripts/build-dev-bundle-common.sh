#!/usr/bin/env bash

set -e
set -u

UNAME=$(uname)
ARCH=$(uname -m)
UNIVERSAL_ARCH=

if [ "$UNAME" == "Linux" ] ; then
    if [ "$ARCH" != "i686" -a "$ARCH" != "x86_64" ] ; then
        # test for platform installed binaries
        if [ "$(which node)" != "" -a "$(which npm)" != "" -a "$(which mongo)" != "" -a "$(which mongod)" != "" ] ; then
            # we are using installation for platform installed binaries
            ARCH="${ARCH}_universal"
            UNIVERSAL_ARCH=$(uname -a)
        else
            echo "Unsupported architecture: $ARCH"
            echo "Meteor only supports i686 and x86_64 or universal for now."
            echo "To use universal architecture make sure that the necessary binaries are pre-installed."
            # get status of installed binaries
            for TEST_PACKAGE in node npm mongo mongod ; do
              echo -e "\tcheck $TEST_PACKAGE: \c"; [[ "$(which $TEST_PACKAGE)" != "" ]] && echo "ok" || echo "fail"
            done
            exit 1
        fi
    fi

    OS="linux"

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
