#!/bin/bash
# SPDX-License-Identifier: MIT
# Copyright (C) 2026 VIKINGYFY

FEEDS_PATH="./feeds"
PACKAGE_PATH="./package"

#修补命令统一入口：FIX <名称> <守卫目录> <命令...>
#守卫目录不存在时直接跳过，保证在 bash -e 下不中断
FIX() {
	local NAME=$1
	local GUARD=$2
	shift 2

	[ -d "$GUARD" ] || return 0

	echo " "
	if "$@"; then
		echo "$NAME has been fixed!"
	else
		echo "$NAME fix failed; continuing!"
	fi
}

#修改argon主题字体和颜色
FIX "theme-argon" "$PACKAGE_PATH/luci-theme-argon" sed -i \
	"s/primary '.*'/primary '#31a1a1'/g; s/'0.2'/'0.5'/g; s/'none'/'bing'/g; s/'600'/'normal'/g" \
	"$PACKAGE_PATH/luci-theme-argon/luci-app-argon-config/root/etc/config/argon"

#修改aurora菜单式样
FIX "theme-aurora" "$PACKAGE_PATH/luci-app-aurora-config" find \
	"$PACKAGE_PATH/luci-app-aurora-config/root/usr/share/aurora/" -type f -name '*.template' -exec sed -i \
	"s/nav_type '.*'/nav_type 'dropdown'/g; s/struct_radius_base '.*'/struct_radius_base '0.125rem'/g" {} +

#修改vantage进度条标签字体（anothaDev/luci-theme-vantage#52）
FIX "theme-vantage" "$PACKAGE_PATH/luci-theme-vantage" sed -i \
	-e '/^\/\* progress bars: thin track/,$ { /^\.cbi-progressbar::before {/,/^}/ { s/^[[:space:]]*font: 500 var(--fs-micro)\/1\.2 var(--mono);/\tfont: inherit; line-height: normal;/; } }' \
	"$PACKAGE_PATH/luci-theme-vantage/luci-theme-vantage/htdocs/luci-static/vantage/vantage.css"

#修改mini-diskmanager菜单位置
FIX "mini-diskmanager" "$PACKAGE_PATH/luci-app-mini-diskmanager" sed -i "s/services/system/g" \
	"$PACKAGE_PATH/luci-app-mini-diskmanager/luci-app-mini-diskmanager/root/usr/share/luci/menu.d/luci-app-mini-diskmanager.json"

#修改natmapt菜单位置
FIX "natmapt" "$PACKAGE_PATH/luci-app-natmapt" sed -i "s/network/services/g" \
	"$PACKAGE_PATH/luci-app-natmapt/root/usr/share/luci/menu.d/luci-app-natmap.json"

# SDK 已提供 ndisc6 时，移除 QModem 内重复定义的副本。
if [ -d "$PACKAGE_PATH/mtk/applications/ndisc" ]; then
	FIX "qmodem-ndisc" "$PACKAGE_PATH/QModem/application/ndisc6" rm -rf \
		"$PACKAGE_PATH/QModem/application/ndisc6"
fi

# 保留 meta 一侧的冲突声明，避免双向 CONFLICTS 形成 Kconfig 循环。
FIX "mihomo-conflicts" "$PACKAGE_PATH/OpenWrt-nikki/mihomo-alpha" sed -i \
	'/^  CONFLICTS:=mihomo-meta$/d' "$PACKAGE_PATH/OpenWrt-nikki/mihomo-alpha/Makefile"

# 避免新版 WeeChat 虚拟依赖生成 Kconfig 自循环。
if grep -q '^define Package/weechat-minimal$' "$FEEDS_PATH/packages/net/weechat/Makefile"; then
	FIX "weechat-dependency" "$FEEDS_PATH/luci/applications/luci-app-weechat" sed -i \
		's/ +weechat / +!PACKAGE_weechat-full:weechat-minimal +PACKAGE_weechat-full:weechat-full /g' \
		"$FEEDS_PATH/luci/applications/luci-app-weechat/Makefile"
fi
