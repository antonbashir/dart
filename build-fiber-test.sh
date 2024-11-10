#!/bin/bash

set -e

dart --enable_mirrors=true compile aot-snapshot   runtime/tests/vm/dart/fiber/fiber_test.dart