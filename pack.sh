#! /bin/bash

set -e

. ./files.config


# 下载文件
download_binaries(){
    mkdir -p ./binary
    if [ -f ./version ]; then
        rm ./version
    fi
    touch ./version

    # mihomo
    echo "正在下载mihomo..."

    if [ "$pack_arch" == "arm64" ]; then
        arch=$mihomo_arch_arm64
    else
        if [ "$pack_arch" == "amd64" ]; then
            arch=$mihomo_arch_amd64
        else 
            echo "不支持的打包架构: ${pack_arch}"
            exit 1
        fi
    fi

    if [ "$mihomo_tag" == "latest" ]; then
        mihomo_tag=$(curl -sL "${mihomo_link}/latest/download/version.txt")
    fi
    mihomo_version=$(curl -sL "${mihomo_link}/download/${mihomo_tag}/version.txt")
    echo "mihomo版本: ${mihomo_version}" >> ./version
    wget -q --show-progress "${mihomo_link}/download/${mihomo_tag}/mihomo-${arch}-${mihomo_version}.gz" -O mihomo.gz 
    gunzip mihomo.gz
    mv "mihomo" ./binary/clash
    chmod 0755 ./binary/clash
    rm -f mihomo.gz

    # curl
    echo "正在下载curl..."
    wget -q --show-progress "${curl_link}/${curl_version}/curl-linux-${pack_arch}-${curl_version}.tar.xz" -O curl.tar.xz 
    tar -xvf curl.tar.xz
    mv curl ./binary/curl
    chmod 0755 ./binary/curl
    rm -f curl.tar.xz

    # 现在打包时下载最新的cacert.pem
    curl --etag-compare cacert-etag.txt --etag-save cacert-etag.txt --remote-name https://curl.se/ca/cacert.pem


    #修改customize.sh
    if [ "$pack_arch" == "amd64" ]; then
        sed -i "s/target_arch=.*/target_arch=\"x64\"/" ./customize.sh
    else
        sed -i "s/target_arch=.*/target_arch=\"$pack_arch\"/" ./customize.sh
    fi

}

download_geoX(){
    # GeoIP
    echo "正在下载GeoIP..."
    wget -q --show-progress "${GeoIP_dat_url}" -O ./clash/GeoIP.dat 

    # Country.mmdb
    echo "正在下载Country.mmdb..."
    wget -q --show-progress "${Country_mmdb_url}" -O ./clash/Country.mmdb 

    # GeoSite
    echo "正在下载GeoSite..."
    wget -q --show-progress "${GeoSite_url}" -O ./clash/GeoSite.dat 
}


download_config(){
    if [ -z "${Subcript_url}" ]; then
        echo "订阅链接为空，跳过"
    else
        echo "正在下载config.yaml..."
        wget -q --show-progress "${Subcript_url}" -O ./clash/config.yaml 
    fi

    # 需要安装python3
    if ! [ -x "$(command -v python3)" ]; then
        echo "请安装python3以自动下载Provider"
        return
    fi   
        mkdir -p ./clash/proxy_providers
        mkdir -p ./clash/rule_providers

    python3 ./download_providers.py "$(dirname "$0")/clash"
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
    wget -q --show-progress "${Corefile_dashboard}" -O ./clash-dashboard.zip 
    unzip -o ./clash-dashboard.zip -d ./clash-dashboard
    mv ./clash-dashboard/Yacd-meta-gh-pages ./clash-dashboard/dist
    rm -rf ./clash-dashboard/yacd-gh-pages
    rm -f ./clash-dashboard.zip
}


pack(){
    # 给module.prop加入版本号
    version=$(cat ./version)
    sed -i "s/mihomo版本:.*/$version/" ./module.prop

    echo "开始打包..."

    mkdir -p ./release

    filename="MFM-${pack_arch}-`cat ./version | awk -F ':' '{print $2}'`.zip"
    zip -r $filename . -x "pack.sh" "files.config" "download_providers.py" "release/*" ".git/*" ".gitignore" ".github/*" "cacert-etag.txt"
    mv -f $filename ./release/$filename
    md5sum ./release/$filename > ./release/$filename.md5

    echo "打包完成"
}

test_pack(){
    echo "正在测试mihomo链接是否可用..."
    if [ "$mihomo_tag" == "latest" ]; then
        mihomo_tag=$(curl -sL "${mihomo_link}/latest/download/version.txt")
    fi

    mihomo_version=$(curl -sL "${mihomo_link}/download/${mihomo_tag}/version.txt")
    if [[ `echo "${mihomo_version}" | grep "Not Found"` ]]; then
        echo "mihomo链接不可用"
        echo "测试链接 ${mihomo_link}/${mihomo_tag}/version.txt"
        exit 1
    else 
        echo "mihomo版本:${mihomo_version}"
    fi

}

ci_pack(){
    pack
    filename="MFM-${pack_arch}-`cat ./version | awk -F ':' '{print $2}'`.zip"
    mkdir -p release-$pack_arch
    
    unzip ./release/$filename -d release-$pack_arch
}

while getopts "abcdgpt" opt; do
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

        c) # for CI usage
            download_binaries
            download_geoX
            download_config
            download_dashboard
            ci_pack
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
        t)
            test_pack
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            ;;
    esac
done