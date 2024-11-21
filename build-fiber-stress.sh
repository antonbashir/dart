#!/bin/bash

set -e

dart compile aot-snapshot --enable-asserts runtime/tests/vm/dart/fiber/fiber_stress.dart