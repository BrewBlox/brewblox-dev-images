#! /usr/bin/env bash
set -euo pipefail
pushd "$(dirname "$0")" >/dev/null

# The particle image is expected to remain relatively stable
# It wraps the Particle CLI in a docker image, so it can easily be used to flash the firmware

bash ../prepare-buildx.sh

# Don't forget to call with --push
docker buildx build \
    --pull \
    --tag ghcr.io/brewblox/firmware-particle:20 \
    --platform linux/amd64,linux/arm/v7,linux/arm64/v8 \
    "$@" \
    .
