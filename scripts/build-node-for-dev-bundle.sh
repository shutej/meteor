#!/usr/bin/env bash

set -e
set -u

source "$(dirname $0)/build-dev-bundle-common.sh"
echo CHECKOUT DIR IS "$CHECKOUT_DIR"
echo BUILDING NODE "v$NODE_VERSION" IN "$DIR"

git clone --branch "v${NODE_VERSION}" --depth 1 \
    https://github.com/nodejs/node.git
cd node
rm -rf .git
if [ "$METEOR_UNIVERSAL_FLAG" == "ARM" ] ; then
  ./configure --without-snapshot --prefix="$DIR"
else
  ./configure --prefix="$DIR"
fi

# check number of cores for parallelism flag
if [ "$NPROCESSORS" -lt "4" ] ; then
    make -j1
else
    make -j4
fi
make install PORTABLE=1
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
