FROM armhfbuild/debian

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python-pip \
    build-essential \
    libguestfs-tools \
    libncurses5-dev \
    tree \
    binfmt-support \
    qemu \
    qemu-user-static \
    debootstrap \
    kpartx \
    lvm2 \
    dosfstools \
    zip \
    unzip \
    awscli \
    ruby \
    ruby-dev \
    shellcheck \
    --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y curl wget xz-utils coreutils

COPY builder /builder
CMD /builder/partitioner.sh && /builder/build.sh
