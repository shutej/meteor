#!/usr/bin/env bash

set -e
set -u

# When upgrading node versions, also update the values of MIN_NODE_VERSION at
# the top of tools/main.js and tools/server/boot.js, and the text in
# docs/client/full-api/concepts.html and the README in tools/bundler.js.
NODE_VERSION=4.4.6

source "$(dirname $0)/build-dev-bundle-common.sh"
echo CHECKOUT DIR IS "$CHECKOUT_DIR"
echo BUILDING NODE "v$NODE_VERSION" IN "$DIR"

git clone --branch "v${NODE_VERSION}" --depth 1 \
    https://github.com/nodejs/node.git
cd node
rm -rf .git
if [ "$ARCH" = "armv6l" -o "$ARCH" = "armv7l" -o "$ARCH" = "armv8l" -o "$ARCH" != "aarch64" ] ; then
  ./configure --without-snapshot --prefix="$DIR"
else
  ./configure --prefix="$DIR"
fi

if [ "$OS" = "bsd" ] ; then
    MAKE_CMD=gmake
else
    MAKE_CMD=make
fi

# check number of cores for parallelism flag
if [ "$NPROCESSORS" -lt "4" ] ; then
    $MAKE_CMD -j1
else
    $MAKE_CMD -j4
fi
$MAKE_CMD install PORTABLE=1
# PORTABLE=1 is a node hack to make npm look relative to itself instead
# of hard coding the PREFIX.

cd "$DIR"
stripBinary bin/node

# export path so we use our new node for later builds
PATH="$DIR/bin:$PATH"
which node
which npm

echo BUNDLING

cd "$DIR"
rm -rf build
tar czvf "${CHECKOUT_DIR}/node_${PLATFORM}_v${NODE_VERSION}.tar.gz" .

echo DONE
