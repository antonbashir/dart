#!/bin/bash

set -e

export CPATH=""

case "$1" in
    debug)
        out/DebugX64/dart-sdk/bin/dart compile aot-snapshot --enable-asserts runtime/tests/vm/dart/fiber/fiber_stress.dart
    ;;
    release)
        out/ReleaseX64/dart-sdk/bin/dart compile aot-snapshot --enable-asserts runtime/tests/vm/dart/fiber/fiber_stress.dart
    ;;
    product)
        out/ProductX64/dart-sdk/bin/dart compile aot-snapshot --enable-asserts runtime/tests/vm/dart/fiber/fiber_stress.dart
    ;;
    *)
    ;;
esac