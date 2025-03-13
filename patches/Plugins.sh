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

#Pass Wall
#git clone --depth=1 --single-branch --branch "main" https://github.com/xiaorouji/openwrt-passwall.git ./pw_luci
#git clone --depth=1 --single-branch --branch "main" https://github.com/xiaorouji/openwrt-passwall-packages.git ./pw_packages
#Open Clash
#
#预置OpenClash内核和GEO数据
export CORE_VER=https://raw.githubusercontent.com/vernesong/OpenClash/core/dev/core_version
export TUN_VER=$(curl -sfL $CORE_VER | sed -n "2{s/\r$//;p;q}")
#export CORE_TUN=https://raw.githubusercontent.com/vernesong/OpenClash/core/master/premium/clash-linux-arm64
#export CORE_DEV=https:/raw.githubusercontent.com/vernesong/OpenClash/core/master/dev/clash-linux-arm64.tar.gz
#export CORE_MATE=https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz

if [ "$(grep -c "^CONFIG_PACKAGE_luci-app-openclash=y$" $GITHUB_WORKSPACE/openwrt/.config)" -ne '0' ]; then
    git clone --depth=1 --single-branch --branch "dev" https://github.com/vernesong/OpenClash.git
    Archt="$(sed -n '/CONFIG_ARCH=/p' $GITHUB_WORKSPACE/openwrt/.config | sed -e 's/CONFIG_ARCH\=\"//' -e 's/\"//')"
    echo "架构为 $Archt 的openclash内核"
    case $ARCHT in
        aarch64)
            CORE_ARCH="linux-arm64"
            ;;
        arm)
            if [ "$(grep -c "CONFIG_ARM_" $GITHUB_WORKSPACE/openwrt/.config)" -ne '0' ]; then
                armv="$(sed -n '/CONFIG_ARM_/p' $GITHUB_WORKSPACE/openwrt/.config | sed -e 's/CONFIG_ARM_//' -e 's/=y//')"
            else
                armv=v5
            fi
            CORE_ARCH="linux-arm${armv}"
            ;;
        i386)
            CORE_ARCH="linux-386"
            ;;
        mips64)
            CORE_ARCH="linux-mips64"
            ;;
        mips)
            CORE_ARCH="linux-mips-softfloat"
            ;;
        mipsel)
            CORE_ARCH="linux-mipsle-softfloat"
            ;;
        x86_64)
            CORE_ARCH="linux-amd64"
            ;;
        *)
            CORE_ARCH="1"
            ;;
    esac
    echo "::notice ::检测到luci-app-openclash配置为编译进固件,下载架构为$CORE_ARCH的openclash内核"
    if [ "$CORE_ARCH" != "1" ]; then
        CPU_MODEL=$CORE_ARCH
        
        export CORE_MATE=https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-$CPU_MODEL.tar.gz
        export GEO_MMDB=https://github.com/alecthw/mmdb_china_ip_list/raw/release/lite/Country.mmdb
        export GEO_SITE=https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geosite.dat
        export GEO_IP=https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geoip.dat

        cd $GITHUB_WORKSPACE/openwrt/package/feeds/luci/OpenClash/luci-app-openclash/root/etc/openclash || exit 1

        curl -sfL -o ./Country.mmdb $GEO_MMDB
        curl -sfL -o ./GeoSite.dat $GEO_SITE
        curl -sfL -o ./GeoIP.dat $GEO_IP

        mkdir -p ./core && cd ./core
        curl -sfL -o ./meta.tar.gz "$CORE_MATE"
        tar -zxf ./meta.tar.gz && mv -f clash ./clash_meta
        chmod 0755 ./clash_meta
        chmod +x ./clash* 
        rm -rf ./*.gz
        echo "OpenClash 加入内置内核成功."
    else
        echo "::warning ::openclash内核不支持此架构,退出执行下载openclash内核。"
        rm -rf $GITHUB_WORKSPACE/openwrt/package/feeds/luci/OpenClash/luci-app-openclash/root/etc/openclash/core
    fi
else
  echo "::notice ::未检测到luci-app-openclash配置为编译进固件,退出执行下载openclash内核。"
  rm -rf $GITHUB_WORKSPACE/openwrt/package/feeds/luci/OpenClash/luci-app-openclash
fi



rm $GITHUB_WORKSPACE/openwrt/package/feeds/packages/frp/files/frpc.config
cd $GITHUB_WORKSPACE/openwrt/package/feeds/packages/frp/files
cp "$GITHUB_WORKSPACE/patches/frpc.config" "$GITHUB_WORKSPACE/openwrt/package/feeds/packages/frp/files/"
chmod 0755 ./frpc.config
cat $GITHUB_WORKSPACE/openwrt/package/feeds/packages/frp/files/frpc.config


