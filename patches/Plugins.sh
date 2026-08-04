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
#export CORE_MATE=https://raw.githubusercontent.com/vernesong/OpenClash/core/master/meta/clash-linux-arm64.tar.gz

# 检查是否选择了编译 luci-app-openclash
if [ "$(grep -c "^CONFIG_PACKAGE_luci-app-openclash=y$" $GITHUB_WORKSPACE/openwrt/.config)" -ne '0' ]; then
    # 克隆 OpenClash 仓库
    git clone --depth=1 --single-branch --branch "dev" https://github.com/vernesong/OpenClash.git

    # 1. 获取主架构 (aarch64, arm, mips, etc.)
    ARCHT="$(sed -n '/CONFIG_ARCH=/p' $GITHUB_WORKSPACE/openwrt/.config | sed -e 's/CONFIG_ARCH\=\"//' -e 's/\"//')"
    
    # 修复了这里的变量名，从 $Archt 改为 $ARCHT
    echo "架构为 $ARCHT 的openclash内核"

    case $ARCHT in
        aarch64)
            CORE_ARCH="linux-arm64"
            ;;
        arm)
            # 2. 针对 arm 架构，更精确地提取版本号
            # 直接匹配 CONFIG_ARM_V* 或 CONFIG_ARM_V7 等格式，确保能提取到具体的版本号
            armv=$(grep -E "^CONFIG_ARM_V[0-9]=y" $GITHUB_WORKSPACE/openwrt/.config | sed -e 's/CONFIG_ARM_//' -e 's/=y//')
            
            # 如果没有提取到具体的版本号，则默认为 v5
            if [ -z "$armv" ]; then
                armv="v5"
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
            # 3. 针对 mips 架构，增加对 hardfloat 的判断
            # 检查是否启用了 mips hardfloat 支持
            if grep -q "^CONFIG_MIPS_FPU_EMU=y" $GITHUB_WORKSPACE/openwrt/.config; then
                 CORE_ARCH="linux-mips-hardfloat"
            else
                 CORE_ARCH="linux-mips-softfloat"
            fi
            ;;
        mipsel)
            # 同样为 mipsel 增加 hardfloat 判断
            if grep -q "^CONFIG_MIPS_FPU_EMU=y" $GITHUB_WORKSPACE/openwrt/.config; then
                 CORE_ARCH="linux-mipsle-hardfloat"
            else
                 CORE_ARCH="linux-mipsle-softfloat"
            fi
            ;;
        x86_64)
            CORE_ARCH="linux-amd64"
            ;;
        *)
            # 如果是不支持的架构，最好直接报错退出，而不是继续执行
            echo "::error ::不支持的CPU架构: $ARCHT"
            CORE_ARCH="1"
            ;;
    esac

    echo "::notice ::检测到luci-app-openclash配置为编译进固件,下载架构为$CORE_ARCH的openclash内核"

    if [ "$CORE_ARCH" != "1" ]; then
        CPU_MODEL=$CORE_ARCH
        
        export CORE_MATE=https://raw.githubusercontent.com/vernesong/OpenClash/refs/heads/core/dev/meta/clash-$CPU_MODEL.tar.gz
        export GEO_MMDB=https://github.com/alecthw/mmdb_china_ip_list/raw/release/lite/Country.mmdb
        export GEO_SITE=https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geosite.dat
        export GEO_IP=https://github.com/Loyalsoldier/v2ray-rules-dat/raw/release/geoip.dat

        cd $GITHUB_WORKSPACE/openwrt/package/feeds/luci/OpenClash/luci-app-openclash/root/etc/openclash || exit 1
       
        curl -sfL -o ./Country.mmdb $GEO_MMDB
        curl -sfL -o ./GeoSite.dat $GEO_SITE
        curl -sfL -o ./GeoIP.dat $GEO_IP
        # ========== Clash Meta 内核下载（失败跳过，不中断构建）========== 
        CORE_DOWNLOADED=false
        MAX_RETRIES=3
        RETRY_DELAY=5
        
        mkdir -p ./core && cd ./core
        
        for ((i=1; i<=MAX_RETRIES; i++)); do
            echo "⬇️  [Attempt $i/$MAX_RETRIES] Downloading Clash Meta core..."
            
            # -f: HTTP错误时返回非零退出码; -s: 静默; -L: 跟随重定向
            if curl -sfL --connect-timeout 15 --max-time 300 -o ./meta.tar.gz "$CORE_MATE"; then
                # 额外校验：防止下载到空文件或 404 HTML 页面
                if [[ -s ./meta.tar.gz ]] && tar -tzf ./meta.tar.gz >/dev/null 2>&1; then
                    echo "✅ Clash Meta core downloaded and verified successfully."
                    CORE_DOWNLOADED=true
                    break
                else
                    echo "⚠️  Downloaded file is invalid or empty, will retry..."
                    rm -f ./meta.tar.gz
                fi
            else
                echo "⚠️  Download failed (curl exit code: $?), will retry..."
                rm -f ./meta.tar.gz
            fi
        
            # 未达到最大次数时等待后重试（指数退避）
            if [[ $i -lt $MAX_RETRIES ]]; then
                echo "⏳ Waiting ${RETRY_DELAY}s before next attempt..."
                sleep "$RETRY_DELAY"
                RETRY_DELAY=$((RETRY_DELAY * 2))
            fi
        done
        
        # ========== 根据下载结果决定是否解压 ==========
        if [[ "$CORE_DOWNLOADED" == "true" ]]; then
            tar -zxf ./meta.tar.gz
            mv -f clash ./clash_meta 2>/dev/null || true
            chmod 0755 ./clash_meta
            rm -rf ./*.gz
            echo "✅ OpenClash 内置内核准备就绪: $(./clash_meta -v 2>/dev/null || echo 'version unknown')"
        else
            echo "⚠️  Skipping Clash Meta core setup after $MAX_RETRIES failed attempts."
            echo "⚠️  Build will continue WITHOUT built-in clash_meta binary."
        fi

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
#cp "$GITHUB_WORKSPACE/patches/wmk.config" "$GITHUB_WORKSPACE/openwrt/package/feeds/packages/frp/files/"
#mv wmk.config frpc.config
chmod 0755 ./frpc.config
cat $GITHUB_WORKSPACE/openwrt/package/feeds/packages/frp/files/frpc.config


#修复uppnp文件数据
rm $GITHUB_WORKSPACE/openwrt/package/feeds/packages/miniupnpd/files/upnpd.config
cd $GITHUB_WORKSPACE/openwrt/package/feeds/packages/miniupnpd/files
cp "$GITHUB_WORKSPACE/patches/upnpd.config-rax3000" "$GITHUB_WORKSPACE/openwrt/package/feeds/packages/miniupnpd/files/"
mv upnpd.config-rax3000 upnpd.config
chmod 0755 ./upnpd.config

