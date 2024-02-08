FROM node:20-bookworm-slim
LABEL org.opencontainers.image.source="https://github.com/BrewBlox/brewblox-dev-images"

WORKDIR /app

ENV PIP_EXTRA_INDEX_URL=https://www.piwheels.org/simple

RUN <<EOF
    set -ex

    apt-get update -q
    apt-get install -y --no-install-recommends \
        build-essential \
        udev \
        libudev-dev \
        libffi-dev \
        python3-dev \
        python3-pip \
        usbutils \
        curl \
        dfu-util

    python3 -m pip install --break-system-packages \
        esptool

    npm install --production --build-from-source --unsafe-perm \
        serialport \
        particle-cli \
        particle-usb

    echo 'alias particle="/app/node_modules/.bin/particle --no-update-check"' \
        >> /etc/bash.bashrc

    apt-get remove -y \
        build-essential

    apt-get autoremove -y
    rm -rf /var/cache/apt/archives /var/lib/apt/lists
EOF

ENTRYPOINT [ "/bin/bash" ]
