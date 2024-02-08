#!/usr/bin/env bash
set -euo pipefail
pushd "$(dirname "$0")" >/dev/null

# Call script with --push to upload to ghcr.io
docker build \
    --pull \
    --tag ghcr.io/brewblox/firmware-devcontainer:bookworm-idf5.1.1 \
    "$@" \
    .
