#!/usr/bin/env bash
#=================================================
# Description: Clean redundant software & caches in Ubuntu 24.04 GitHub Actions Runner
#=================================================

set -euo pipefail

echo "==> [1/5] Disabling swap..."
sudo -E swapoff -a || true
sudo -E rm -f /swapfile /mnt/swapfile || true

echo "==> [2/5] Cleaning snap packages and system logs..."
sudo -E snap set system refresh.retain=2 2>/dev/null || true

echo "==> [3/5] Removing large pre-installed toolchains & runtimes (~25GB+)..."
sudo -E rm -rf \
  /usr/share/dotnet \
  /usr/local/lib/android \
  /opt/ghc \
  /opt/hostedtoolcache || true
# Ubuntu 24.04 官方主仓库配置为 /etc/apt/sources.list.d/ubuntu.sources，切勿误删
sudo find /etc/apt/sources.list.d/ -type f ! -name "ubuntu.sources" -delete 2>/dev/null || true

echo "==> [4/5] Purging unused large packages..."
sudo -E apt-get -y purge \
  azure-cli \
  ghc* \
  zulu* \
  firefox \
  google-chrome-stable \
  dotnet* \
  powershell \
  openjdk* \
  mysql* \
  mongodb* \
  moby* \
  docker* \
  containerd* || true

sudo -E apt-get -y autoremove --purge
sudo -E apt-get -y clean

echo "==> [5/5] Cleaning user caches..."
sudo sed -i '/NVM_DIR/d;/skel/d' /root/{.bashrc,.profile} 2>/dev/null || true
rm -rf ~/{.cargo,.dotnet,.rustup,.npm,.cache} 2>/dev/null || true

echo "==> System cleanup finished successfully!"
df -Th
