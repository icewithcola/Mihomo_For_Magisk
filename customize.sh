SKIPUNZIP=1

status=""
architecture=""
system_gid="1000"
system_uid="1000"
clash_data_dir="/data/clash"
modules_dir="/data/adb/modules"
ca_path="/system/etc/security/cacerts"
mod_config="${clash_data_dir}/clash.config"
geoip_file_path="${clash_data_dir}/Country.mmdb"
target_arch="arm64"

check_env(){
    # 检测架构
    if [ "${ARCH}" -ne "${target_arch}" ]; then
        abort "不支持的架构"
    fi

    # 检测环境变量
    if [ -z ${MODPATH} ]; then
        abort "检测到环境变量问题，请检查Magisk"
    fi
    if [ -z ${clash_data_dir} ] ; then
        abort "检测到环境变量问题，请检查Magisk"
    fi
    if [ -z ${ZIPFILE} ]; then
        abort "检测到环境变量问题，请检查Magisk"
    fi
}

check_lastinstall(){
    # 检测是否已经安装过
    if [ -d "${clash_data_dir}" ]; then
        ui_print "检测到已安装过的Clash,将您的配置文件迁移到新的目录."
        if [ -d "${clash_data_dir}.old" ]; then
            rm -rf "${clash_data_dir}.old"
        fi
        mv -f ${clash_data_dir} ${clash_data_dir}.old
        set_perm_recursive ${clash_data_dir}.old ${system_uid} ${system_gid} 0755 0644 # 修复权限
    fi
}

release_file(){
    mkdir -p ${MODPATH}/system/bin
    mkdir -p ${clash_data_dir}
    mkdir -p ${MODPATH}${ca_path}

    mkdir -p ${clash_data_dir}/proxy_providers
    mkdir -p ${clash_data_dir}/rule_providers
    
    unzip -o "${ZIPFILE}" -x 'META-INF/*' -d $MODPATH >&2
    ui_print $(cat $MODPATH/version)
    mkdir ${clash_data_dir}

    mv ${MODPATH}/binary/* ${MODPATH}/system/bin
    mv ${MODPATH}/cacert.pem ${MODPATH}${ca_path}
    mv -n ${MODPATH}/clash-dashboard ${clash_data_dir}/
    rm -rf ${MODPATH}/clash-dashboard
    mv -f ${MODPATH}/clash/* ${clash_data_dir}/
    rm -rf ${MODPATH}/clash
    rm -rf ${MODPATH}/binary

    if [ ! -f "${clash_data_dir}/packages.list" ] ; then
        touch ${clash_data_dir}/packages.list
    fi
}

move_config(){
    if [ ! -s "${clash_data_dir}/config.yaml" ] && [ -s "${clash_data_dir}.old/config.yaml" ]; then
        echo "在旧的安装中找到可用的config.yaml等配置,将其迁移到新的目录."
        cp -f ${clash_data_dir}.old/config.yaml ${clash_data_dir}/config.yaml
        cp -f ${clash_data_dir}.old/clash.config ${clash_data_dir}/clash.config
        cp -f ${clash_data_dir}.old/proxy_providers/* ${clash_data_dir}/proxy_providers/
        cp -f ${clash_data_dir}.old/rule_providers/* ${clash_data_dir}/rule_providers/
    fi
}

config_compatible(){ # 所有兼容性修改都在这里
    # 1.4.0 分离 clash.config 内外逻辑
    config_file="${clash_data_dir}/clash.config"
    sed -i '/# 上面的是给你操作的，下面的不懂就别乱改/,$d' "$config_file" 2>/dev/null
    if [ -f "$config_file" ] && ! grep -q "\. /data/clash/clash.internal.config" "$file"; then
        sed -i '2i\. /data/clash/clash.internal.config' "$config_file"
    fi
}

setup_perm(){
    ui_print "- 开始设置环境权限."
    set_perm_recursive ${MODPATH} 0 0 0755 0644
    set_perm  ${MODPATH}/system/bin/setcap  0  0  0755
    set_perm  ${MODPATH}/system/bin/getcap  0  0  0755
    set_perm  ${MODPATH}/system/bin/getpcaps  0  0  0755
    set_perm  ${MODPATH}${ca_path}/cacert.pem 0 0 0644
    set_perm  ${MODPATH}/system/bin/curl 0 0 0755
    set_perm_recursive ${clash_data_dir} ${system_uid} ${system_gid} 0755 0644
    set_perm_recursive ${clash_data_dir}/scripts ${system_uid} ${system_gid} 0755 0755
    set_perm  ${MODPATH}/system/bin/clash  ${system_uid}  ${system_gid}  6755
    set_perm  ${clash_data_dir}/clash.config ${system_uid} ${system_gid} 0755
    set_perm  ${clash_data_dir}/clash.internal.config ${system_uid} ${system_gid} 0755
    set_perm  ${clash_data_dir}/packages.list ${system_uid} ${system_gid} 0644
}

setup_busybox(){
    if [ "${KSU}" ]; then
        ui_print "Setting up for KSU..."
        setup_busybox_internal "/data/adb/ksu/bin/busybox" 
        sed -i "s|KSU|KSU✅|g" "$MODPATH/module.prop"
    elif [ "${APATCH}" ]; then
        ui_print "Setting up for Apatch..."
        setup_busybox_internal "/data/adb/ap/bin/busybox" 
        sed -i "s|APatch|APatch✅|g" "$MODPATH/module.prop"

    else
        ui_print "Setting up for Magisk or unknown environment..."
        setup_busybox_internal "/data/adb/magisk/busybox" 
        sed -i "s|Magisk/|Magisk✅/|g" "$MODPATH/module.prop"
    fi
}

setup_busybox_internal() {
    if [ -z "$1" ]; then
        ui_print "$0 <busybox>"
        abort
    fi
    
    busybox_path="$1"
    ui_print "Busybox at $1"
    files="$MODPATH/service.sh $clash_data_dir/clash.internal.config"
    
    for file in $files; do
        if [ -f "$file" ]; then
            ui_print "Replacing in $file"
            sed -i "s|busybox_path=\"replace\"|busybox_path=\"$busybox_path\"|g" "$file"
        fi
    done
}


check_env
check_lastinstall
release_file
move_config
setup_busybox
config_compatible
setup_perm