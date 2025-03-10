#!/bin/bash

#Design Theme
#git clone --depth=1 --single-branch --branch $(echo $OWRT_URL | grep -iq "lede" && echo "main" || echo "js") https://github.com/gngpp/luci-theme-design.git
#git clone --depth=1 --single-branch https://github.com/gngpp/luci-app-design-config.git
#sed -i 's/dark/light/g' luci-app-design-config/root/etc/config/design
#Argon Theme
#git clone --depth=1 --single-branch --branch $(echo $OWRT_URL | grep -iq "lede" && echo "18.06" || echo "master") https://github.com/jerrykuku/luci-theme-argon.git
#git clone --depth=1 --single-branch --branch $(echo $OWRT_URL | grep -iq "lede" && echo "18.06" || echo "master") https://github.com/jerrykuku/luci-app-argon-config.git
#Linkease
#git clone --depth=1 --single-branch https://github.com/linkease/istore.git
#git clone --depth=1 --single-branch https://github.com/linkease/nas-packages.git
#git clone --depth=1 --single-branch https://github.com/linkease/nas-packages-luci.git
#Open Clash
git clone --depth=1 --single-branch --branch "dev" https://github.com/vernesong/OpenClash.git
#Pass Wall
#git clone --depth=1 --single-branch --branch "main" https://github.com/xiaorouji/openwrt-passwall.git ./pw_luci
#git clone --depth=1 --single-branch --branch "main" https://github.com/xiaorouji/openwrt-passwall-packages.git ./pw_packages

#预置OpenClash内核和GEO数据
export CORE_VER=https://raw.githubusercontent.com/vernesong/OpenClash/core/dev/core_version
export TUN_VER=$(curl -sfL $CORE_VER | sed -n "2{s/\r$//;p;q}")
export CORE_TUN=https://raw.githubusercontent.com/vernesong/OpenClash/core/master/premium/clash-linux-arm64
export CORE_DEV=https:/raw.githubusercontent.com/vernesong/OpenClash/core/master/dev/clash-linux-arm64.tar.gz
export CORE_MATE=https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz

#export CORE_TYPE=$(echo redmiax6000 | grep -Eiq "64|86" && echo "amd64" || echo "arm64")



export GEO_MMDB=https://github.com/alecthw/mmdb_china_ip_list/raw/release/lite/Country.mmdb
export GEO_SITE=https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geosite.dat
export GEO_IP=https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geoip.dat

cd $GITHUB_WORKSPACE/openwrt/package/feeds/luci/OpenClash/luci-app-openclash/root/etc/openclash

curl -sfL -o ./Country.mmdb $GEO_MMDB
curl -sfL -o ./GeoSite.dat $GEO_SITE
curl -sfL -o ./GeoIP.dat $GEO_IP

mkdir -p ./core && cd ./core

curl -sfL -o ./tun.gz "$CORE_TUN"-"$TUN_VER".gz
gzip -d ./tun.gz && mv ./tun ./clash_tun
chmod 0755 ./clash_tun

curl -sfL -o ./meta.tar.gz "$CORE_MATE"
tar -zxf ./meta.tar.gz && mv -f clash ./clash_meta
chmod 0755 ./clash_meta
echo "OpenClash core has been successfully integrated."

curl -sfL -o ./dev.tar.gz "$CORE_DEV"
tar -zxf ./dev.tar.gz
find . -type f -exec chmod 0755 {} \;
chmod +x ./clash* ; rm -rf ./*.gz

rm cd $GITHUB_WORKSPACE/openwrt/package/feeds/packages/frp/files/frpc.config
cd $GITHUB_WORKSPACE/openwrt/package/feeds/packages/frp/files

cat $GITHUB_WORKSPACE/patches/frpc.config


