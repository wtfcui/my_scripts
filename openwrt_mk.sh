#!/bin/bash
sudo pacman -S --needed bash bc bin86 binutils bzip2 cdrkit core/which diffutils fastjar findutils flex gawk gcc gettext git intltool libusb libxslt make ncurses openssl patch perl-extutils-makemaker pkgconf rsync sharutils time unzip util-linux wget zlib
git clone -b openwrt-21.02 https://github.com/openwrt/openwrt.git
git clone https://github.com/coolsnowwolf/lede.git

SRC_DIR=$(cd $(dirname $0) && pwd)
export ALL_PROXY=socks5://127.0.0.1:1080
# 添加插件源码
echo "src-git helloworld https://github.com/fw876/helloworld.git" >>feeds.conf.default
# 修改主题文件
rm -rf package/lean/luci-theme-argon
git clone https://github.com/jerrykuku/luci-theme-argon.git package/lean/luci-theme-argon
git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git package/lean/luci-theme-argon

# 添加 feeds
git clone https://github.com/shadowsocks/openwrt-feeds.git package/feeds
# 获取 simple-obfs Makefile
git clone https://github.com/aa65535/openwrt-simple-obfs.git package/simple-obfs
# 获取 shadowsocks-libev Makefile
git clone https://github.com/shadowsocks/openwrt-shadowsocks.git package/shadowsocks-libev
# mkdir -p package/helloworld
# for i in "dns2socks" "microsocks" "ipt2socks" "pdnsd-alt" "redsocks2"; do
#     svn checkout "https://github.com/immortalwrt/packages/trunk/net/$i" "package/helloworld/$i"
# done

# svn checkout https://github.com/coolsnowwolf/lede/trunk/tools/ucl tools/ucl
# svn checkout https://github.com/coolsnowwolf/lede/trunk/tools/upx tools/upx

sed -i 'N;24a\tools-y += ucl upx' tools/Makefile
sed -i 'N;40a\$(curdir)/upx/compile := $(curdir)/ucl/compile' tools/Makefile

# 修改openwrt登陆地址,把下面的192.168.5.1修改成你想要的就可以了
sed -i 's/192.168.1.1/192.168.5.1/g' package/base-files/files/bin/config_generate

# 修改默认wifi名称ssid为Xiaomi_R4A
sed -i 's/ssid=OpenWrt/ssid=CMCC_BC00/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh
# 开启wifi
sed -i '/set wireless.*disabled=1/d' package/kernel/mac80211/files/lib/wifi/mac80211.sh

mkdir -p package/helloworld
for i in "dns2socks" "microsocks" "ipt2socks" "pdnsd-alt" "redsocks2"; do
    svn checkout "https://github.com/immortalwrt/packages/trunk/net/$i" "package/helloworld/$i"
done

svn checkout https://github.com/coolsnowwolf/lede/trunk/tools/ucl tools/ucl
svn checkout https://github.com/coolsnowwolf/lede/trunk/tools/upx tools/upx

./scripts/feeds update -a
./scripts/feeds install -a
make defconfig
./scripts/diffconfig.sh >diff.config
make menuconfig

# make -j8 download V=s 下载dl库（国内请尽量全局科学上网）
# make -j8 V=s
# 输入 make -j1 V=s （-j1 后面是线程数。第一次编译推荐用单线程）即可开始编译你要的固件了。
# make -j$(($(nproc) + 1)) V=s
