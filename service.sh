until [ $(getprop init.svc.bootanim) = "stopped" ] ; do
    sleep 5
done

service_path=`realpath $0`
module_dir=`dirname ${service_path}`
data_dir="/data/clash"
scripts_dir="${data_dir}/scripts"
Clash_data_dir="/data/clash"
Clash_run_path="${Clash_data_dir}/run"
Clash_pid_file="${Clash_run_path}/clash.pid"

maybe_busybox="/data/adb/magisk/busybox /data/adb/ap/bin/busybox /data/adb/ksu/bin/busybox"
busybox_path=""
for path in $maybe_busybox; do
    if [ -x "$path" ]; then
        busybox_path="$path"
    fi
done

if [ -f ${Clash_pid_file} ] ; then
    rm -rf ${Clash_pid_file}
fi

rm -rf ${Clash_run_path}/run.logs
nohup ${busybox_path} crond -c ${Clash_run_path} > /dev/null 2>&1 &

${scripts_dir}/clash.service -s && ${scripts_dir}/clash.iptables -s

inotifyd ${scripts_dir}/clash.inotify ${module_dir} >> /dev/null &