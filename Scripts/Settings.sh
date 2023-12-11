#!/bin/bash

#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#添加编译日期标识
sed -i "s/DISTRIB_TARGET='\(.*\)'/DISTRIB_TARGET='\1 $WRT_REPO-$WRT_DATE'/g" ./package/base-files/files/etc/openwrt_release

CFG_FILE="./package/base-files/files/bin/config_generate"
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" $CFG_FILE
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" $CFG_FILE
#修改默认时区
sed -i "s/timezone='.*'/timezone='CST-8'/g" $CFG_FILE
sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" $CFG_FILE

#修改默认WIFI名
WIFI_FILE="./package/mtk/applications/mtwifi-cfg/files/mtwifi.sh"
sed -i "23s/ssid=\".*\"/ssid=\"$WRT_WIFI\"/" $WIFI_FILE
sed -i "29s/ssid=\".*\"/ssid=\"$WRT_WIFI-5G\"/" $WIFI_FILE

#配置文件修改
echo "CONFIG_PACKAGE_luci-theme-$WRT_THEME=y" >> ./.config
echo "CONFIG_PACKAGE_luci-app-$WRT_THEME-config=y" >> ./.config
echo "CONFIG_MTK_MEMORY_SHRINK=$([[ $WRT_SHRINK == "true" ]] && echo "y" || echo "n")" >> ./.config
echo "CONFIG_MTK_MEMORY_SHRINK_AGGRESS=$([[ $WRT_SHRINK == "true" ]] && echo "y" || echo "n")" >> ./.config