#!/bin/bash

set -e
set -u

# save current path and switch inside packages
pushd "$(dirname $0)/../packages" >/dev/null 2>&1

# test that there are some non-core packages
if [ -d "non-core" ]; then

  # change to non-core
  cd non-core

  # link all ./packages/non-core/pkg to ./packages/pkg
  for pkg in $(find . -mindepth 1 -maxdepth 1 -type d); do
    if [ -L "../${pkg}" ]; then
      echo "Package ${pkg} is already linked."
    elif [ -e "../${pkg}" ] || [ -d "../${pkg}" ]; then
      echo "Package ${pkg} does already exist."
    else
      ln -s "${pkg}" ..
      echo "Package ${pkg} linked."
    fi
  done

fi

popd  >/dev/null 2>&1
