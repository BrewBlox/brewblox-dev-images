FROM debian:bookworm
LABEL org.opencontainers.image.source="https://github.com/BrewBlox/brewblox-dev-images"

ENV TZ=Europe/Amsterdam \
    DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    BOOST_ROOT=/usr/include/boost \
    CMAKE_VERSION=3.23.2

RUN <<EOF
    set -ex

    dpkg --add-architecture arm64
    dpkg --add-architecture armhf

    apt-get update -q
    apt-get install -y --no-install-recommends \
        curl \
        wget \
        software-properties-common
    apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        bash \
        bear \
        build-essential \
        ccache \
        gcc-12 \
        git \
        libboost-program-options1.74-dev \
        libboost-random1.74-dev \
        libboost-system1.74-dev \
        libboost-thread1.74-dev \
        libprotobuf-dev \
        libssl-dev \
        libtool \
        pkg-config \
        protobuf-compiler \
        python3 \
        python3-pip \
        python-is-python3 \
        rsync \
        unzip

    # ARM32 cross compilation toolchain
    apt-get install -y \
        gcc-12-arm-linux-gnueabihf \
        g++-12-arm-linux-gnueabihf \
        libboost-program-options1.74-dev:armhf \
        libboost-random1.74-dev:armhf \
        libboost-system1.74-dev:armhf \
        libboost-thread1.74-dev:armhf \
        libssl-dev:armhf

    # ARM64 cross compilation toolchain
    apt-get install -y \
        gcc-12-aarch64-linux-gnu \
        g++-12-aarch64-linux-gnu \
        libboost-program-options1.74-dev:arm64 \
        libboost-random1.74-dev:arm64 \
        libboost-system1.74-dev:arm64 \
        libboost-thread1.74-dev:arm64 \
        libssl-dev:arm64

    python3 -m pip install --upgrade --break-system-packages \
        pip \
        setuptools
    python3 -m pip install --upgrade --break-system-packages \
        invoke

    # Manually install CMake
    # The version carried by apt is heavily outdated
    curl -sSL \
        -o /tmp/cmake-installer.sh \
        https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.sh
    sh /tmp/cmake-installer.sh --skip-license --prefix=/usr/local/

    # Apt cleanup
    apt-get clean
    apt-get purge
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

    # Fix git handling of non-owned directories
    git config --system --add safe.directory "*"
EOF

WORKDIR /firmware
CMD bash
