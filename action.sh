config="/data/clash/run/config.yaml"
controller=$(grep "external-controller:" ${config} | awk '{print $2}' | tr -d ' ')

am start -a android.intent.action.VIEW -d "http://${controller}/ui"
