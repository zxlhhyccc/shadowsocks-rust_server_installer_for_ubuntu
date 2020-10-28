#!/bin/bash

arch_shadowsocks_rust="x86_64"
kernel_shadowsocks_rust="linux"
system_shadowsocks_rust="gnu"

arch_v2ray_plugin="amd64"
kernel_v2ray_plugin="linux"
arch_version_v2ray_plugin=""

path_install_to="/usr/bin"

guess_package_manager(){
    local res
    local package_managers="apt opkg"
	for package_manager in $package_managers
	do
        which $package_manager >/dev/null
        if [ $? == 0 ];then
            res=$package_manager
            break
        fi
	done
    echo $res
}

get_version_new(){
    local version=$(curl -s https://github.com/shadowsocks/$1/releases/latest | cut -d "\"" -f2 | cut -d "/" -f8 | grep -oE '([0-9]{1,4}\.)*[0-9]{1,4}')
    echo $version
}

get_version_cur(){
    local version=$($1 --version | sed -n 1p | cut -d " " -f2 | grep -oE '([0-9]{1,4}\.)*[0-9]{1,4}')
    echo $version
}

install_shadowsocks_rust(){
    local need_update="0"
    local version_new=$(get_version_new "shadowsocks-rust")
    local version_cur=""
    local bins="sslocal ssmanager ssserver ssurl"
	for bin in $bins
	do
        version_cur=$(get_version_cur $bin)
        if [ "$version_new" != "$version_cur" ];then
            need_update="1"
            break
        fi
	done
    if [ "$need_update" == "1" ];then
        local tmp_dir=`mktemp -d /tmp/shadowsocks-rust_bin.XXXXXX`
        cd $tmp_dir
        wget https://github.com/shadowsocks/shadowsocks-rust/releases/download/v"$version_new"/shadowsocks-v"$version_new"."$arch_shadowsocks_rust"-unknown-"$kernel_shadowsocks_rust"-"$system_shadowsocks_rust".tar.xz > /dev/null 2>&1
        tar xvf shadowsocks-v"$version_new"."$arch_shadowsocks_rust"-unknown-"$kernel_shadowsocks_rust"-"$system_shadowsocks_rust".tar.xz > /dev/null 2>&1
        service shadowsocks-rust_transproxy stop > /dev/null 2>&1
        service shadowsocks-rust_server stop > /dev/null 2>&1
	    for bin in $bins
        do
            mv -f $bin $path_install_to/$bin
            chmod +x $path_install_to/$bin
        done
        service shadowsocks-rust_transproxy start > /dev/null 2>&1
        service shadowsocks-rust_server start > /dev/null 2>&1
        rm -rf $tmp_dir
    fi
}

install_v2ray_plugin(){
    local need_update="0"
    local version_new=$(get_version_new "v2ray-plugin")
    local version_cur=""
    local bins="v2ray-plugin"
	for bin in $bins
	do
        version_cur=$(get_version_cur $bin)
        if [ "$version_new" != "$version_cur" ];then
            need_update="1"
            break
        fi
	done
    if [ "$need_update" == "1" ];then
        local tmp_dir=`mktemp -d /tmp/v2ray-plugin_bin.XXXXXX`
        cd $tmp_dir
        wget https://github.com/shadowsocks/v2ray-plugin/releases/download/v"$version_new"/v2ray-plugin-"$kernel_v2ray_plugin"-"$arch_v2ray_plugin"-v"$version_new".tar.gz > /dev/null 2>&1
        tar xvf v2ray-plugin-"$kernel_v2ray_plugin"-"$arch_v2ray_plugin"-v"$version_new".tar.gz > /dev/null 2>&1
        service shadowsocks-rust_transproxy stop > /dev/null 2>&1
        service shadowsocks-rust_server stop > /dev/null 2>&1
        mv -f v2ray-plugin_"$kernel_v2ray_plugin"_"$arch_v2ray_plugin""$arch_version_v2ray_plugin" $path_install_to/v2ray-plugin
        chmod +x $path_install_to/v2ray-plugin
        service shadowsocks-rust_transproxy start > /dev/null 2>&1
        service shadowsocks-rust_server start > /dev/null 2>&1
        rm -rf $tmp_dir
    fi
}

install(){
    pm=$(guess_package_manager)
    $pm install curl -y > /dev/null 2>&1
    install_shadowsocks_rust
    install_v2ray_plugin
}

uninstall(){
    local bins="sslocal ssmanager ssserver ssurl v2ray-plugin"
	for bin in $bins
    do
        rm -f $path_install_to/$bin
    done
}

case "$1" in
install)			install
					;;
uninstall)			uninstall
					;;
*)					echo "Usage: install|uninstall"
					exit 2
					;;
esac
exit 0