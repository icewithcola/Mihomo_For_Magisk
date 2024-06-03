#!/system/bin/sh
. /data/clash/clash.config
scripts=`realpath $0`
scripts_dir=`dirname ${scripts}`
subItem=""
confPath="/data/clash/config.yaml"
tempPath="/data/clash/config.new.yaml"
Clash_bin_path="/data/adb/modules/Mihomo_For_Magisk/system/bin/clash"
CFM_logs_file="/data/clash/run/run.logs"

updateSub(){
    echo [`TZ=Asia/Shanghai date "+%H:%M:%S"`]"info: 更新订阅." >> ${CFM_logs_file}
    # 验证是否设置了订阅链接
    if [ -z "${Subcript_url}" ]; then
        echo [`TZ=Asia/Shanghai date "+%H:%M:%S"`]"error: 订阅链接为空，考虑关闭本功能？" >> ${CFM_logs_file}
        return 1
    fi
    # 下载
    subItem=$(curl --cacert /etc/security/cacerts/cacert.pem -sL  "${Subcript_url}")
    if [ -z "${subItem}" ]; then
        echo [`TZ=Asia/Shanghai date "+%H:%M:%S"`]"error: 订阅链接无法获取到数据，请检查链接是否正确." >> ${CFM_logs_file}
        return 1
    fi
    echo "${subItem}" > ${tempPath}

    # 使用Clash验证
    testResult=$(${Clash_bin_path} -t -f ${tempPath})
    if [[ $testResult == *"test failed"* ]]; then
        echo [`TZ=Asia/Shanghai date "+%H:%M:%S"`]"error: 订阅链接无法通过Clash验证，请检查链接是否正确." >> ${CFM_logs_file}
        return 1
    fi
    # 替换
    mv -f ${tempPath} ${confPath}
    echo [`TZ=Asia/Shanghai date "+%H:%M:%S"`]"info: 订阅更新成功." >> ${CFM_logs_file}
    # Also print to stdout
    echo [`TZ=Asia/Shanghai date "+%H:%M:%S"`]"info: 订阅更新成功." 
}

updateSub