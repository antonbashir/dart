#!/bin/bash
export CPATH=""
./tools/build.py -m product -a x64 runtime dart_precompiled_runtime ddc dartanalyzer analysis_server create_common_sdk create_platform_sdk
