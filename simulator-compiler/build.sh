#! /usr/bin/env bash
set -euo pipefail
pushd "$(dirname "$0")" >/dev/null

# The compiler image is expected to remain relatively stable
# It does not contain any firmware code - just the software required to compile the firmware

# We don't need a multiplatform image
# Cross-compilation is done by GCC on AMD64 images

# don't forget to call with --push
docker buildx build \
    --pull \
    --tag ghcr.io/brewblox/simulator-compiler:12 \
    --platform linux/amd64 \
    "$@" \
    .
