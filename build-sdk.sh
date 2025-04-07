#!/bin/bash

export CPATH=""

case "$1" in
    debug)
        ./tools/build.py -m debug -a x64 --exclude-kernel-service runtime create_common_sdk
    ;;
    release)
        ./tools/build.py -m release -a x64 create_sdk
    ;;
    product)
        ./tools/build.py -m product -a x64 create_sdk
    ;;
    *)
    ;;
esac