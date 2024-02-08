FROM mcr.microsoft.com/vscode/devcontainers/base:bookworm
LABEL org.opencontainers.image.source="https://github.com/BrewBlox/brewblox-dev-images"

ARG USERNAME=vscode

ENV IDF_CLONE_URL=https://github.com/espressif/esp-idf.git \
    IDF_CLONE_BRANCH_OR_TAG=v5.1.1 \
    IDF_CHECKOUT_REF= \
    IDF_PATH=/opt/esp/idf \
    IDF_TOOLS_PATH=/opt/esp \
    IDF_CCACHE_ENABLE=1 \
    BOOST_ROOT=/usr/include/boost \
    CMAKE_VERSION=3.23.2 \
    SHFMT_VERSION=v3.4.2 \
    NODE_MAJOR=20 \
    GCC_ARM_URL="https://developer.arm.com/-/media/Files/downloads/gnu-rm/10.3-2021.07/gcc-arm-none-eabi-10.3-2021.07-x86_64-linux.tar.bz2" \
    GCC_ARM_VERSION="10.3-2021.07" \
    PATH=/usr/local/gcc-arm-none-eabi/bin:$PATH

RUN <<EOF
    set -ex

    export DEBIAN_FRONTEND=noninteractive
    dpkg --add-architecture i386

    apt-get update -q
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        wget \
        software-properties-common

    # Install Node.js sources
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
        | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_MAJOR}.x nodistro main" \
        > /etc/apt/sources.list.d/nodesource.list

    apt-get update -q
    apt-get install -y --no-install-recommends \
        autoconf \
        automake \
        bash-completion \
        bear \
        bison \
        build-essential \
        bzip2 \
        ccache \
        check \
        dfu-util \
        flex \
        g++-12 \
        gcc-12 \
        gcovr \
        gdb \
        git \
        gperf \
        isomd5sum \
        jq \
        lcov \
        libarchive-zip-perl \
        libboost1.74-all-dev \
        libc6:i386 \
        libffi-dev \
        libncurses-dev \
        libprotobuf-dev \
        libtool \
        libusb-1.0-0-dev \
        make \
        ninja-build \
        nodejs \
        pkg-config \
        protobuf-compiler \
        python3 \
        python3-pip \
        python3-protobuf \
        python3-venv \
        python-is-python3 \
        ripgrep \
        rsync \
        shellcheck \
        tzdata \
        udev \
        unzip \
        usbutils \
        vim-common \
        xxd \
        xz-utils \
        zip

    npm install -g \
        lv_font_conv \
        diff-so-fancy

    python3 -m pip install --upgrade --break-system-packages \
        autopep8 \
        flake8 \
        invoke \
        nanopb==0.4.7 \
        pip \
        pyserial \
        pyusb \
        virtualenv

    # Manually install gcc-arm-none-eabi-10
    # The Particle build tools are incompatible with later GCC versions
    curl -sSL -o /tmp/gcc-arm-none-eabi.tar.bz2 -sSL ${GCC_ARM_URL}
    tar -xjvf /tmp/gcc-arm-none-eabi.tar.bz2 -C /usr/local
    mv /usr/local/gcc-arm-none-eabi-${GCC_ARM_VERSION}/ /usr/local/gcc-arm-none-eabi
    rm -rf /usr/local/gcc-arm-none-eabi/share

    # Manually install CMake
    # The version carried by apt is heavily outdated
    curl -sSL \
        -o /tmp/cmake-installer.sh \
        https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.sh
    sh /tmp/cmake-installer.sh --skip-license --prefix=/usr/local/

    # Install IDF
    echo IDF_CHECKOUT_REF=$IDF_CHECKOUT_REF IDF_CLONE_BRANCH_OR_TAG=$IDF_CLONE_BRANCH_OR_TAG
    git clone --recursive --depth 1 --shallow-submodules --single-branch \
        ${IDF_CLONE_BRANCH_OR_TAG:+-b $IDF_CLONE_BRANCH_OR_TAG} \
        $IDF_CLONE_URL $IDF_PATH

    if [ -n "$IDF_CHECKOUT_REF" ]; then
        cd $IDF_PATH
        git checkout $IDF_CHECKOUT_REF
        git submodule update --init --recursive --depth 1 --single-branch
    fi

    update-ca-certificates --fresh
    $IDF_PATH/tools/idf_tools.py --non-interactive install required
    $IDF_PATH/tools/idf_tools.py --non-interactive install cmake
    $IDF_PATH/tools/idf_tools.py --non-interactive install-python-env
    rm -rf $IDF_TOOLS_PATH/dist

    # Give the user the required permissions for using USB devices
    # Sets ownership of IDF dir to user to prevent git ownership errors
    usermod -aG dialout $USERNAME
    usermod -aG plugdev $USERNAME
    chown $USERNAME $IDF_PATH
    chown $USERNAME $IDF_PATH/components/openthread/openthread

    # Fix git handling of non-owned directories
    git config --system --add safe.directory "*"

    # Install shfmt
    curl -sSfL \
        -o /usr/local/bin/shfmt \
        https://github.com/mvdan/sh/releases/download/${SHFMT_VERSION}/shfmt_${SHFMT_VERSION}_linux_amd64
    chmod +x /usr/local/bin/shfmt

    # Set udev rules so we can flash Particle devices
    mkdir -p /etc/udev/rules.d
    echo 'SUBSYSTEMS=="usb", ATTRS{idVendor}=="2b04", ATTRS{idProduct}=="[cd]00?", GROUP="plugdev", MODE="0666"' \
        > /etc/udev/rules.d/50-particle.rules

    # Enable autocompletion for invoke
    echo 'source <(invoke --print-completion-script bash)' >> /etc/bash.bashrc

    # Create and chown directories for VSCode extensions
    # This will be mounted to act as a cache
    mkdir -p \
        /home/$USERNAME/.vscode-server/extensions \
        /home/$USERNAME/.vscode-server-insiders/extensions
    chown -R $USERNAME \
        /home/$USERNAME/.vscode-server \
        /home/$USERNAME/.vscode-server-insiders

    # Install Azure CLI
    curl -sL https://aka.ms/InstallAzureCLIDeb | bash

    # Apt cleanup
    apt-get clean
    apt-get purge
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
EOF

# Install IDF dependencies in a separate RUN
# This prevents polluting the environment with idf/export.sh variables
RUN <<EOF
    set -ex

    . /opt/esp/idf/export.sh
    pip3 install --upgrade pyclang
    idf_tools.py install esp-clang

    # Export again to add clang-format to path
    # Create a system-wide link so it can be used outside the IDF context
    . /opt/esp/idf/export.sh
    sudo ln -s "$(which clang-format)" /usr/local/bin/clang-format
EOF
