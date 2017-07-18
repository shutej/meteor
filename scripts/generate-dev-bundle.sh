#!/usr/bin/env bash

set -e
set -u

# Read the bundle version from the meteor shell script.
BUNDLE_VERSION=$(perl -ne 'print $1 if /BUNDLE_VERSION=(\S+)/' meteor)
if [ -z "$BUNDLE_VERSION" ]; then
    echo "BUNDLE_VERSION not found"
    exit 1
fi

source "$(dirname $0)/build-dev-bundle-common.sh"
echo CHECKOUT DIR IS "$CHECKOUT_DIR"
echo BUILDING DEV BUNDLE "$BUNDLE_VERSION" IN "$DIR"

cd "$DIR"

# Check if have to build for an universal environment on yet not
# officially supported architectures
if [ -z "$METEOR_UNIVERSAL_FLAG" ] ; then

    S3_HOST="s3.amazonaws.com/com.meteor.jenkins"

    # Update these values after building the dev-bundle-node Jenkins project.
    # Also make sure to update NODE_VERSION in generate-dev-bundle.ps1.
    NODE_URL="https://nodejs.org/dist/v${NODE_VERSION}/${NODE_TGZ}"
    echo "Downloading Node from ${NODE_URL}"
    curl "${NODE_URL}" | tar zx --strip-components 1

    # Download Mongo from mongodb.com
    MONGO_NAME="mongodb-${OS}-${ARCH}-${MONGO_VERSION}"
    MONGO_TGZ="${MONGO_NAME}.tgz"
    MONGO_URL="http://fastdl.mongodb.org/${OS}/${MONGO_TGZ}"
    echo "Downloading Mongo from ${MONGO_URL}"
    curl "${MONGO_URL}" | tar zx

    # Put Mongo binaries in the right spot (mongodb/bin)
    mkdir -p mongodb/bin
    mv "${MONGO_NAME}/bin/mongod" mongodb/bin
    mv "${MONGO_NAME}/bin/mongo" mongodb/bin
    rm -rf "${MONGO_NAME}"

else

    # For an universal build we can use a self compiled tarballs for
    # node and mongo or try on nodejs.org or use system installed binaries

    # Take the node version from common
    # If a local archive for node exists, we bundle that
    NODE_TGZ_FILE="node_${PLATFORM}_v${NODE_VERSION}.tar.gz"
    if [ -f "${CHECKOUT_DIR}/${NODE_TGZ_FILE}" ] ; then
        tar zxf "${CHECKOUT_DIR}/${NODE_TGZ_FILE}"
    elif [ -n "${NODE_TGZ}" ] ; then
        # if exists try to download node binary from nodejs
        NODE_URL="https://nodejs.org/dist/v${NODE_VERSION}/${NODE_TGZ}"
        echo "Downloading Node from ${NODE_URL}"
        curl "${NODE_URL}" | tar zx --strip-components 1
    else
        # test for system installed binaries
        if [ -z "$(which node 2>/dev/null)" -o -z "$(which npm 2>/dev/null)" ] ; then
            echo "To generate dev bundle with system binaries please make sure"
            echo "that node (compatible to $NODE_VERSION) and npm is installed."
            echo -e "\tnode version:" $(which node 2>/dev/null)
            echo -e "\tnpm version:" $(which npm 2>/dev/null)
            exit 1
        fi
        # link to pre-installed binaries on universal build
        # also need etc for "global" npmrc
        mkdir -p "$DIR/bin"
        mkdir -p "$DIR/etc"
        ln -s "$(which node 2>/dev/null)" "$DIR/bin/node"
        ln -s "$(which npm 2>/dev/null)"  "$DIR/bin/npm"
    fi

    # Take the mongo version from common
    MONGO_TGZ_FILE="mongo_${PLATFORM}_v${MONGO_VERSION}.tar.gz"
    # If a local archive for mongo exists, we bundle that
    if [ -f "${CHECKOUT_DIR}/${MONGO_TGZ_FILE}" ] ; then
        tar zxf "${CHECKOUT_DIR}/${MONGO_TGZ_FILE}"
    else
        # test for system installed binaries
        if [ -z "$(which mongo 2>/dev/null)" -o -z "$(which mongod 2>/dev/null)" ] ; then
            echo "To generate dev bundle with system binaries please make sure"
            echo "that mongo and mongod is installed."
            echo -e "\tmongo version:" $(which mongo 2>/dev/null)
            echo -e "\tmongod version:" $(which mongod 2>/dev/null)
            exit 1
        fi
        # link to pre-installed binaries on universal build
        mkdir -p "$DIR/mongodb/bin"
        ln -s "$(which mongo 2>/dev/null)"  "$DIR/mongodb/bin/mongo"
        ln -s "$(which mongod 2>/dev/null)" "$DIR/mongodb/bin/mongod"
    fi

fi

# export path so we use the downloaded node and npm
export PATH="$DIR/bin:$PATH"

cd "$DIR/lib"
# Overwrite the bundled version with the latest version of npm.
npm install "npm@$NPM_VERSION"

which node
which npm
npm version

# When adding new node modules (or any software) to the dev bundle,
# remember to update LICENSE.txt! Also note that we include all the
# packages that these depend on, so watch out for new dependencies when
# you update version numbers.

# First, we install the modules that are dependencies of tools/server/boot.js:
# the modules that users of 'meteor bundle' will also have to install. We save a
# shrinkwrap file with it, too.  We do this in a separate place from
# $DIR/server-lib/node_modules originally, because otherwise 'npm shrinkwrap'
# will get confused by the pre-existing modules.
mkdir "${DIR}/build/npm-server-install"
cd "${DIR}/build/npm-server-install"
node "${CHECKOUT_DIR}/scripts/dev-bundle-server-package.js" > package.json
npm install
npm shrinkwrap

mkdir -p "${DIR}/server-lib/node_modules"
# This ignores the stuff in node_modules/.bin, but that's OK.
cp -R node_modules/* "${DIR}/server-lib/node_modules/"

mkdir -p "${DIR}/etc"
mv package.json npm-shrinkwrap.json "${DIR}/etc/"

# Fibers ships with compiled versions of its C code for a dozen platforms. This
# bloats our dev bundle. Remove all the ones other than our
# architecture. (Expression based on build.js in fibers source.)
shrink_fibers () {
    FIBERS_ARCH=$(node -p -e 'process.platform + "-" + process.arch + "-" + process.versions.modules')
    mv $FIBERS_ARCH ..
    rm -rf *
    mv ../$FIBERS_ARCH .
}

cd "$DIR/server-lib/node_modules/fibers/bin"
shrink_fibers

# Now, install the npm modules which are the dependencies of the command-line
# tool.
mkdir "${DIR}/build/npm-tool-install"
cd "${DIR}/build/npm-tool-install"
node "${CHECKOUT_DIR}/scripts/dev-bundle-tool-package.js" >package.json
npm install
mkdir -p "${DIR}/lib/node_modules/"
cp -R node_modules/* "${DIR}/lib/node_modules/"
# Also include node_modules/.bin, so that `meteor npm` can make use of
# commands like node-gyp and node-pre-gyp.
cp -R node_modules/.bin "${DIR}/lib/node_modules/"

# Make node-gyp install Node headers and libraries in $DIR/.node-gyp/.
# https://github.com/nodejs/node-gyp/blob/4ee31329e0/lib/node-gyp.js#L52
export HOME="$DIR"
export USERPROFILE="$DIR"
node "${DIR}/lib/node_modules/node-gyp/bin/node-gyp.js" install
INCLUDE_PATH="${DIR}/.node-gyp/${NODE_VERSION}/include/node"
echo "Contents of ${INCLUDE_PATH}:"
ls -al "$INCLUDE_PATH"

cd "${DIR}/lib"

# Clean up some bulky stuff.
cd node_modules

# Used to delete bulky subtrees. It's not an error anymore but WARNING if they
# don't exist, because that might mean it moved somewhere else and we should
# update the delete line.
delete () {
    if [ ! -e "$1" ]; then
        echo "WARNING! Nothing to clean anymore. Missing or moved?: $1"
    else
        rm -rf "$1"
    fi
}

delete browserstack-webdriver/docs
delete browserstack-webdriver/lib/test

delete npm/test
delete npm/node_modules/node-gyp
pushd npm/node_modules
ln -s ../../node-gyp ./
popd

delete sqlite3/deps
delete sqlite3/node_modules/nan
delete sqlite3/node_modules/node-pre-gyp
delete wordwrap/test
delete moment/min

# Remove esprima tests to reduce the size of the dev bundle
find . -path '*/esprima-fb/test' | xargs rm -rf

cd "$DIR/lib/node_modules/fibers/bin"
shrink_fibers

# Check if have to build on universal architecture
if [ -z "$METEOR_UNIVERSAL_FLAG" ] ; then

    # Download BrowserStackLocal binary.
    BROWSER_STACK_LOCAL_URL="https://browserstack-binaries.s3.amazonaws.com/BrowserStackLocal-07-03-14-$OS-$ARCH.gz"

    cd "$DIR/build"
    curl -O $BROWSER_STACK_LOCAL_URL
    gunzip BrowserStackLocal*
    mv BrowserStackLocal* BrowserStackLocal
    mv BrowserStackLocal "$DIR/bin/"

fi

# Sanity check to see if we're not breaking anything by replacing npm
INSTALLED_NPM_VERSION=$(cat "$DIR/lib/node_modules/npm/package.json" |
xargs -0 node -e "console.log(JSON.parse(process.argv[1]).version)")
if [ "$INSTALLED_NPM_VERSION" != "$NPM_VERSION" ]; then
  echo "Unexpected NPM version in lib/node_modules: $INSTALLED_NPM_VERSION"
  echo "Update this check if you know what you're doing."
  exit 1
fi

echo BUNDLING

cd "$DIR"
echo "${BUNDLE_VERSION}" > .bundle_version.txt
rm -rf build CHANGELOG.md ChangeLog LICENSE README.md

tar czf "${CHECKOUT_DIR}/dev_bundle_${PLATFORM}_${BUNDLE_VERSION}.tar.gz" .

echo DONE
