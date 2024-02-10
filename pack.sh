#! /bin/bash

set -e

. ./files.config


# 下载文件
download_binaries(){
    # mihomo
    echo "正在下载mihomo..."
    mihomo_version=$(curl -sL "${Corefile_mihomo}version.txt")
    echo "mihomo版本: ${mihomo_version}"
    wget "${Corefile_mihomo}mihomo-android-arm64-${mihomo_version}.gz" -O mihomo.gz 
    gunzip mihomo.gz
    mv "mihomo" ./binary/clash
    chmod 0755 ./binary/clash
    rm -f mihomo.gz

    # curl
    echo "正在下载curl..."
    wget "${Corefile_curl}" -O curl.tar.xz 
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
    if [ -z "${Subcript_url}" ]; then
        echo "订阅链接为空，跳过"
    else
        echo "正在下载config.yaml..."
        wget "${Subcript_url}" -O ./clash/config.yaml 
    fi

    providers=$(grep -A 2 "type: http" ./clash/config.yaml)
    if [[ -n "$providers" ]]; then
        IFS="--"
        declare -a provider_list=( $providers )
        for (( i=0 ; i < ${#provider_list[@]}; i++ )); do
            provider=${provider_list[$i]}
            if [[ -n "$provider" ]]; then
                url=$(echo "$provider" | grep -o 'url: "[^"]*"' | cut -d'"' -f2)
                path=$(echo "$provider" | grep -o 'path: [^ ]*' | cut -d' ' -f2-)
                wget $url -O "./clash/$path"
                echo "成功下载$path"
            fi
        done
    else
        echo "没有需要下载的providers"
    fi
}

download_dashboard(){
    if [ -z "${Corefile_dashboard}" ]; then
        echo "Dashboard链接为空，跳过"
        return
    fi

    if [ -d ./clash-dashboard ]; then
        rm -rf ./clash-dashboard
    fi

    echo "正在下载dashboard..."
    wget "${Corefile_dashboard}" -O ./clash-dashboard.zip 
    unzip -o ./clash-dashboard.zip -d ./clash-dashboard
    mv ./clash-dashboard/Yacd-meta-gh-pages ./clash-dashboard/dist
    rm -rf ./clash-dashboard/yacd-gh-pages
    rm -f ./clash-dashboard.zip
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

while getopts "abdcgp" opt; do
    case $opt in
        a)
            download_binaries
            download_geoX
            download_config
            download_dashboard
            pack
            ;;
        b)
            download_binaries
            ;;
        d)
            download_dashboard
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