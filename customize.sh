#!/bin/bash
#=================================================
# Description: DIY script
# Lisence: MIT
# Author: eSirPlayground
# Youtube Channel: https://goo.gl/fvkdwm 
#=================================================
#1. Modify default IP
sed -i 's/192.168.1.1/192.168.31.1/g' openwrt/package/base-files/files/bin/config_generate

#2. Clear the login password
#sed -i 's/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.//g' openwrt/package/base-files/files/etc/shadows

#3. Replace with JerryKuKu’s Argon
#rm openwrt/package/lean/luci-theme-argon -rf
#4. 修改wifi名字
sed -i "s#ssid='[^']*'#ssid='Redmi_5A21'#g" openwrt/package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc

#5. 修改顺序分配IP地址
sed -i '15a option sequential_ip	1' openwrt/package/network/services/dnsmasq/files/dhcp.conf
sed -i 's/option start 	100/option start 	2/g' openwrt/package/network/services/dnsmasq/files/dhcp.conf
sed -i 's/option limit	150/option limit	255/g' openwrt/package/network/services/dnsmasq/files/dhcp.conf
sed -i 's/option leasetime	12h/option leasetime	7d/g' openwrt/package/network/services/dnsmasq/files/dhcp.conf
