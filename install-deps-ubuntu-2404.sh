#!/usr/bin/env bash
#=================================================
# Description: Install OpenWrt build dependencies for Ubuntu 24.04
#=================================================

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "==> [1/2] Updating apt package lists..."
sudo apt-get -y update

echo "==> [2/2] Installing OpenWrt build dependencies for Ubuntu 24.04..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEPENDS_FILE="${SCRIPT_DIR}/depends-ubuntu-2404"

if [[ -f "$DEPENDS_FILE" ]]; then
    sudo apt-get -y --no-install-recommends install $(grep -v '^#' "$DEPENDS_FILE")
else
    sudo apt-get -y --no-install-recommends install \
        ack antlr3 aria2 asciidoc autoconf automake autopoint binutils bison \
        btrfs-progs build-essential bzip2 ca-certificates ccache cmake coreutils cpio \
        curl device-tree-compiler ecj fastjar flex g++-multilib gawk gcc-multilib \
        genisoimage gettext git gnutls-dev gperf gzip haveged help2man intltool jq \
        lib32gcc-s1 libc6-dev-i386 libelf-dev libfuse-dev libglib2.0-dev libgmp-dev \
        libltdl-dev libmpc-dev libmpfr-dev libncurses-dev libpython3-dev libreadline-dev \
        libssl-dev libtool libyaml-dev libz-dev lld llvm lrzsz mkisofs msmtp nano \
        ninja-build p7zip p7zip-full patch pigz pkgconf python3 python3-docutils \
        python3-pip python3-ply python3-pyelftools python3-setuptools qemu-utils quilt \
        re2c rsync scons squashfs-tools subversion swig tar texinfo uglifyjs unzip \
        upx vim wget xmlto xsltproc xxd xz-utils yasm zip zlib1g-dev zstd
fi

echo "==> Dependencies installation completed successfully!"
