Clash_data_dir="/data/clash"
Clash_old="/data/clash.old"

rm_data() {
    if [ -z "${Clash_data_dir}" ]; then
        return
    fi
    rm -rf ${Clash_data_dir}

    if [ -z "${Clash_old}" ]; then
        return
    fi    
    rm -rf ${Clash_old}
}

rm_data