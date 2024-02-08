#! /usr/bin/env bash
set -euo pipefail
pushd "$(dirname "$0")" >/dev/null

# The compiler image is expected to remain relatively stable
# It does not contain any firmware code - just the software required to compile the firmware

# don't forget to call with --push
docker buildx build \
    --pull \
    --tag ghcr.io/brewblox/firmware-compiler:10 \
    "$@" \
    .
