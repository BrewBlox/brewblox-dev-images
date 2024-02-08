FROM debian:bullseye
LABEL org.opencontainers.image.source="https://github.com/BrewBlox/brewblox-dev-images"

ENV TZ=Europe/Amsterdam \
    DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    BOOST_ROOT=/usr/include/boost \
    GCC_ARM_URL="https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.07/gcc-arm-none-eabi-10.3-2021.07-x86_64-linux.tar.bz2" \
    GCC_ARM_VERSION="10.3-2021.07" \
    PATH=/usr/local/gcc-arm-none-eabi/bin:$PATH

RUN <<EOF
    set -ex

    dpkg --add-architecture i386

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
        bzip2 \
        ccache \
        dfu-util \
        g++-10 \
        gcc-10 \
        gcovr \
        git \
        isomd5sum \
        libarchive-zip-perl \
        libboost1.74-all-dev \
        libc6:i386 \
        libprotobuf-dev \
        libtool \
        pkg-config \
        protobuf-compiler \
        python3 \
        python3-pip \
        python-is-python3 \
        rsync \
        tzdata \
        unzip \
        vim-common

    python3 -m pip install --upgrade \
        pip \
        setuptools
    python3 -m pip install \
        invoke \
        protobuf \
        pyserial

    echo "tzdata tzdata/Areas select Europe" > /tmp/preseed.txt
    echo "tzdata tzdata/Zones/Europe select Amsterdam" >> /tmp/preseed.txt
    debconf-set-selections /tmp/preseed.txt
    rm -rf /etc/timezone
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
    echo $TZ > /etc/timezone
    dpkg-reconfigure --frontend noninteractive tzdata

    # Manually install gcc-arm-none-eabi for gcc 10
    # Bullseye apt only carries the gcc 8 version
    curl -sSL -o /tmp/gcc-arm-none-eabi.tar.bz2 -sSL ${GCC_ARM_URL}
    tar -xjvf /tmp/gcc-arm-none-eabi.tar.bz2 -C /usr/local
    mv /usr/local/gcc-arm-none-eabi-${GCC_ARM_VERSION}/ /usr/local/gcc-arm-none-eabi
    rm -rf /usr/local/gcc-arm-none-eabi/share

    # Apt cleanup
    apt-get clean
    apt-get purge
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    git config --system --add safe.directory '*'
EOF

WORKDIR /firmware
CMD bash
