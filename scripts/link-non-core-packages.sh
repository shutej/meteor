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
  for pkg in $(ls -d *); do
    if [ -L "../${pkg}" ]; then
      echo "Package ${pkg} is already linked."
    elif [ -e "../${pkg}" ] || [ -d "../${pkg}" ]; then
      echo "Package ${pkg} does already exist."
    elif [ -L "${pkg}" ] || [ -d "${pkg}" ]; then
      # link only if folder oder sym-link detected
      ln -s "non-core/${pkg}" "../${pkg}"
      echo "Package ${pkg} linked."
    fi
  done

fi
