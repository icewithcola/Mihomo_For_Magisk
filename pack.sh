#! /bin/bash

set -e

. ./files.config


# 检测环境
if [ -z "$(wget --version)" ]; then 
    apt install -y wget
fi

if [ -z "$(gunzip --version)" ]; then
    apt install -y gzip
fi


# 下载文件
download_binaries(){
    # mihomo
    echo "正在下载mihomo..."
    mihomo_version=$(curl -sL "${Mihomo_url}version.txt")
    echo "mihomo版本: ${mihomo_version}"
    wget "${Mihomo_url}mihomo-android-arm64-${mihomo_version}.gz" -O mihomo.gz 
    gunzip mihomo.gz
    mv "mihomo" ./binary/clash
    chmod 0755 ./binary/clash
    rm -f mihomo.gz

    # curl
    echo "正在下载curl..."
    wget "${Curl_url}" -O curl.tar.xz 
    tar -xvf curl.tar.xz
    mv curl ./binary/curl
    chmod 0755 ./binary/curl
    rm -f curl.tar.xz
}

download_geoX(){
    # GeoIP
    echo "正在下载GeoIP..."
    wget "${GeoIP_dat_url}" -O ./clash/GeoIP.dat 

    # Country.mmdb
    echo "正在下载Country.mmdb..."
    wget "${Country_mmdb_url}" -O ./clash/Country.mmdb 

    # GeoSite
    echo "正在下载GeoSite..."
    wget "${GeoSite_url}" -O ./clash/GeoSite.dat 
}


download_config(){
    # config.yaml
    if [ -z "${Subcript_url}" ]; then
        echo "订阅链接为空，跳过"
        return
    fi
    echo "正在下载config.yaml..."
    wget "${Subcript_url}" -O ./clash/config.yaml 
}

pack(){
    echo "开始打包..."

    if [ -d ./release ]; then
        rm -rf ./release
    fi
    mkdir ./release

    zip -r MFM.zip . -x "pack.sh" "files.config" "release/*" ".git/*" ".gitignore"
    mv MFM.zip ./release/MFM.zip
    md5sum ./release/MFM.zip > ./release/MFM.zip.md5

    echo "打包完成"
}

while getopts "abgcp" opt; do
    case $opt in
        a)
            download_binaries
            download_geoX
            download_config
            pack
            ;;
        b)
            download_binaries
            ;;
        g)
            download_geoX
            ;;
        c)
            download_config
            ;;
        p)
            pack
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            ;;
    esac
done