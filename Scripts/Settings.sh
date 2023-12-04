#!/bin/bash

#修改默认主题
sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" ./package/base-files/files/bin/config_generate
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" ./package/base-files/files/bin/config_generate
#修改默认时区
sed -i "s/timezone='.*'/timezone='CST-8'/g" ./package/base-files/files/bin/config_generate
sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" ./package/base-files/files/bin/config_generate
#修改默认WIFI名
sed -i "23s/ssid=\".*\"/ssid=\"$WRT_WIFI\"/" ./wrt/package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
sed -i "29s/ssid=\".*\"/ssid=\"$WRT_WIFI-5G\"/" ./wrt/package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
