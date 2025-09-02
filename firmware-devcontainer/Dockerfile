FROM mcr.microsoft.com/vscode/devcontainers/base:bookworm
LABEL org.opencontainers.image.source="https://github.com/BrewBlox/brewblox-dev-images"

ARG USERNAME=vscode

ENV IDF_CLONE_URL=https://github.com/espressif/esp-idf.git \
    # Bumped from v5.1.1 -> v5.5 (2025 upgrade). If pinning a specific commit, set IDF_CHECKOUT_REF.
    IDF_CLONE_BRANCH_OR_TAG=v5.5 \
    IDF_VERSION=v5.5 \
    IDF_CHECKOUT_REF= \
    IDF_PATH=/opt/esp/idf \
    IDF_TOOLS_PATH=/opt/esp \
    IDF_CCACHE_ENABLE=1 \
    BOOST_ROOT=/usr/include/boost \
    CMAKE_VERSION=3.31.0 \
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
        catch2 \
        check \
        dfu-util \
        flex \
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

    python3 -m pip install --upgrade --break-system-packages --no-cache-dir \
        pip \
        wheel
    python3 -m pip install --upgrade --break-system-packages --no-cache-dir \
        autopep8 \
        flake8 \
        invoke \
        nanopb==0.4.7 \
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

    # install latest LLVM toolchain via apt.llvm.org installer.
    # LLVM / clang installer - edit LLVM_VERSION (ENV) above to change the installed toolchain
    # Run the apt.llvm.org installer with the requested LLVM_VERSION and 'all' to install
    # additional tools (clang-format, clang-tidy, clang-tools, etc.).
    wget -qO /tmp/llvm.sh https://apt.llvm.org/llvm.sh
    bash /tmp/llvm.sh ${LLVM_VERSION} all

    # Register any installed versioned LLVM binaries as versionless alternatives.
    # Detect an installed clang-* binary to infer the LLVM version, then register
    # all /usr/bin/*-<version> executables with update-alternatives so 'clang',
    # 'clang-format', 'clang-tidy', 'clangd', etc. work without the version suffix.
    LLVM_VER=""
    for v in /usr/bin/clang-[0-9]*; do
        [ -e "$v" ] || continue
        if [ -x "$v" ]; then
            LLVM_VER="${v##*-}"
            break
        fi
    done

    if [ -n "$LLVM_VER" ]; then
        echo "Registering LLVM tools for version: $LLVM_VER"
        for vp in /usr/bin/*-"$LLVM_VER"; do
            [ -e "$vp" ] || continue
            [ -x "$vp" ] || continue
            binname="$(basename "$vp")"
            # strip the -<version> suffix
            base="${binname%-${LLVM_VER}}"
            # ensure base is not empty
            if [ -n "$base" ]; then
                echo " -> $base -> $vp"
                update-alternatives --install "/usr/bin/${base}" "${base}" "$vp" 200 || true
                update-alternatives --set "${base}" "$vp" || true
            fi
        done
    else
        echo "No versioned clang binary found; skipping LLVM alternatives registration"
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

    # Apt cleanup + remove pip caches to reduce image size
    apt-get autoremove -y
    apt-get clean -y
    apt-get purge
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/.cache/pip /home/$USERNAME/.cache/pip || true

    # Remove esp-idf activation temp dir if created during build (will be recreated per-user)
    rm -rf /tmp/esp_idf_activate_vscode || true
EOF

# Install IDF dependencies in a separate RUN
# Use bash to allow export.sh to detect its path (needs BASH_SOURCE) and force IDF_PATH usage
SHELL ["/bin/bash","-c"]
RUN <<'EOF'
set -euo pipefail
export IDF_PATH_FORCE=1
source /opt/esp/idf/export.sh
pip3 install --upgrade pyclang
idf_tools.py install esp-clang

# Ensure activation temp dir does not persist root ownership
rm -rf /tmp/esp_idf_activate_vscode || true
# Remove pip caches left by pyclang/idf_tools.py
rm -rf /root/.cache/pip /home/$USERNAME/.cache/pip || true
EOF

# Default to non-root user for devcontainer runtime (use USERNAME at the top of the file)
USER ${USERNAME}
