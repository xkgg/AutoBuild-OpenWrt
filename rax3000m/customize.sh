#!/bin/bash
#=================================================
# Description: DIY script
# Lisence: MIT
# Author: eSirPlayground
# Youtube Channel: https://goo.gl/fvkdwm 
#=================================================
#1. Modify default IP
sed -i 's/192.168.1.1/192.168.10.1/g' openwrt/package/base-files/files/bin/config_generate
#2. 修改 TZ 时区
echo "::notice ::设置openwrt默认时区为timezone=CST-8,时区区域名称为zonename=Asia/Shanghai"
sed -i -e "s/set system.@system\[-1].hostname='OpenWrt'/set system.@system\[-1].hostname='OpenWrt'/g" -e "s/set system.@system\[-1].timezone='UTC'/set system.@system\[-1].timezone=\'CST-8\'/g" -e "/set system.@system\[-1].timezone='CST-8'/i\		set system.@system\[-1].zonename=\'Asia/Shanghai\'" openwrt/package/base-files/files/bin/config_generate

#3. 修改顺序分配IP地址
sed -i '15a option sequential_ip	1' openwrt/package/network/services/dnsmasq/files/dhcp.conf
sed -i 's/option start 	100/option start 	2/g' openwrt/package/network/services/dnsmasq/files/dhcp.conf
sed -i 's/option limit	150/option limit	255/g' openwrt/package/network/services/dnsmasq/files/dhcp.conf
sed -i 's/option leasetime	12h/option leasetime	7d/g' openwrt/package/network/services/dnsmasq/files/dhcp.conf


#4. Clear the login password
#sed -i 's/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.//g' openwrt/package/base-files/files/etc/shadows

#5. Replace with JerryKuKu’s Argon
#rm openwrt/package/lean/luci-theme-argon -rf


#7. 修改wifi名字
rm openwrt/package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
#cd openwrt/package/network/config/wifi-scripts/files/lib/wifi/
cp "$GITHUB_WORKSPACE/rax3000m/mac80211.uc" "openwrt/package/network/config/wifi-scripts/files/lib/wifi/"
chmod 0755 $GITHUB_WORKSPACE/openwrt/package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
sed -i "s#ssid='[^']*'#ssid='OpenWrt'#g" openwrt/package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc
cat openwrt/package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc

#8. 修复rust报错
MAKEFILE_PATH="openwrt/feeds/packages/lang/rust/Makefile"
sed -i 's|	--set=llvm.download-ci-llvm=true |	--set=llvm.download-ci-llvm=false |g' "$MAKEFILE_PATH"


