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

# 检测架构
if [ "${ARCH}" -ne "arm64" ]; then
    abort "仅支持arm64架构."
fi

# 检测是否已经安装过不一样的模块
if [ -d "${clash_data_dir}" ]; then
    ui_print "检测到已安装过的Clash,将您的配置文件迁移到新的目录."
    mv -f ${clash_data_dir} ${clash_data_dir}.old
fi

# 检测环境变量
if [ -z ${MODPATH} ]; then
    abort ""
fi
if [ -z ${clash_data_dir} ] ; then
    abort ""
fi
if [ -z ${ZIPFILE} ]; then
    abort ""
fi

check_package(){
    file_list="/binary/clash /binary/curl /clash/Country.mmdb /clash/GeoIP.dat /clash/GeoSite.dat"
    for file in ${file_list}; do
        if [ ! -f "${MODPATH}/${file}" ]; then
            abort "缺少${file}文件，请验证打包"
        fi
    done
}

if [ -z ${PACKCHECK} ]; then
    check_package
fi

mkdir -p ${MODPATH}/system/bin
mkdir -p ${clash_data_dir}
mkdir -p ${MODPATH}${ca_path}

unzip -o "${ZIPFILE}" -x 'META-INF/*' -d $MODPATH >&2




mkdir ${clash_data_dir}

mv ${MODPATH}/binary ${MODPATH}/system/bin
mv ${MODPATH}/cacert.pem ${MODPATH}${ca_path}
mv -n ${MODPATH}/clash-dashboard ${clash_data_dir}/
rm -rf ${MODPATH}/clash-dashboard
mv -f ${MODPATH}/clash/* ${clash_data_dir}/
rm -rf ${MODPATH}/clash
rm -rf ${MODPATH}/binary

if [ ! -f "${clash_data_dir}/packages.list" ] ; then
    touch ${clash_data_dir}/packages.list
fi

sleep 1


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
set_perm  ${clash_data_dir}/packages.list ${system_uid} ${system_gid} 0644
