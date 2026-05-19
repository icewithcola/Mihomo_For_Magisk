#!/system/bin/sh
. /data/clash/clash.config
scripts=`realpath $0`
scripts_dir=`dirname ${scripts}`
LOG_TAG="sub"
. ${scripts_dir}/clash.log

subItem=""
confPath="/data/clash/config.yaml"
tempPath="/data/clash/config.new.yaml"
Clash_bin_path="/data/adb/modules/Mihomo_For_Magisk/system/bin/clash"

updateSub(){
    log_say "更新订阅."
    # 验证是否设置了订阅链接
    if [ -z "${Subcript_url}" ]; then
        log_error "订阅链接为空, 考虑关闭本功能?"
        return 1
    fi
    # 下载
    subItem=$(curl --cacert /etc/security/cacerts/cacert.pem -sL  "${Subcript_url}")
    if [ -z "${subItem}" ]; then
        log_error "订阅链接无法获取到数据, 请检查链接是否正确."
        return 1
    fi
    echo "${subItem}" > ${tempPath}

    # 使用Clash验证
    testResult=$(${Clash_bin_path} -t -f ${tempPath})
    if [[ $testResult == *"test failed"* ]]; then
        log_error "订阅链接无法通过 Clash 验证, 请检查链接是否正确."
        return 1
    fi
    # 替换
    mv -f ${tempPath} ${confPath}
    log_say "订阅下载成功."
}
