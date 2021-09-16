#!/system/bin/sh

MODDIR=${0%/*}
ip_site="https://forge.speedtest.cn/api/location/info"
process_num_file="/data/priv/.system/.process_num"
local_config="/data/priv/local.config"
local_string="$(cat ${local_config})"
proc_name="com.tencent.tmgp.sgame"
kit_file="/data/priv/config/Kitsunebi"
v2ray_file="/data/priv/config/v2rayNG"
clnc_file="/data/priv/config/clnc"
freeze_proxy_app="/data/priv/config/freeze_proxy_app"
freeze_self="/data/priv/config/freeze_self"
# process_num_log_file="/data/priv/.system/.process_num_log"

validate_ip() {
  # 查询 IP
  find_ip="$(echo -e $(curl -s -m 10 ${ip_site}) | grep ${local_string})"
  if [ -n "${find_ip}" ]; then
    return 1
  fi
  return 0
}

start_proxy() {
  if [ -f "${clnc_file}" ]; then
    ${MODDIR}/CuteBi start >/dev/null 2>&1
    return 1
  elif [ -f "${kit_file}" ]; then
    pm enable fun.kitsunebi.kitsunebi4android >/dev/null 2>&1
    am start fun.kitsunebi.kitsunebi4android/.ui.StartVpnActivity >/dev/null 2>&1
    return 1
  elif [ -f "${v2ray_file}" ]; then
    pm enable com.v2ray.ang >/dev/null 2>&1
    am start "intent:#Intent;launchFlags=0x1000c000;component=com.v2ray.ang/.ui.ScSwitchActivity;end" >/dev/null 2>&1
    #am start com.v2ray.ang/.ui.ScSwitchActivity
    return 1
  fi

  return 0
}

handle_sgame_start() {
  local_string="$(cat ${local_config})"
  if [ ! -n "${local_string}" ]; then
    return 0
  fi
  # 验证IP，IP通过则不开启代理
  validate_ip
  ip_valid=$?
  if [ $ip_valid -eq 1 ]; then
    return 0
  fi
  # 开启代理
  start_proxy
  success_start_proxy=$?
  if [ $success_start_proxy -gt 0 ]; then
    sleep 8
  fi
  validate_ip
  ip_valid=$?
  if [ ! $ip_valid -eq 1 ]; then
    am force-stop com.tencent.tmgp.sgame
  fi
}

handle_sgame_stop() {
  freeze_proxy
  freeze_self
  delete_sgame_pref_file
}

freeze_proxy() {
  if [[ -f "${clnc_file}" ]]; then
    ${MODDIR}/CuteBi stop >/dev/null 2>&1
  elif [[ -f "$freeze_proxy_app" && -f "${kit_file}" ]]; then
    pm disable fun.kitsunebi.kitsunebi4android >/dev/null 2>&1
  elif [[ -f "$freeze_proxy_app" && -f "${v2ray_file}" ]]; then
    pm disable com.v2ray.ang >/dev/null 2>&1
  fi
}

freeze_self() {
  if [[ -f "$freeze_self" ]]; then
    pm disable com.tencent.tmgp.sgame >/dev/null 2>&1
  fi
}

delete_sgame_pref_file() {
  rm -rf /data/data/com.tencent.tmgp.sgame/shared_prefs/.xg.vip.settings.xml.xml
  rm -rf /data/data/com.tencent.tmgp.sgame/shared_prefs/device_id.vip.xml
  rm -rf /data/data/com.tencent.tmgp.sgame/shared_prefs/igame_priority_sdk_pref_temp_info.xml
  rm -rf /data/data/com.tencent.tmgp.sgame/shared_prefs/igame_priority_sdk_pref_wzry_info.xml
  rm -rf /data/data/com.tencent.tmgp.sgame/shared_prefs/tgpa.xml
}

start_service() {
  # 查询应用状态
  while true; do
    pre_process_num="$(cat ${process_num_file})"
    # 查询进程数
    process_num="$(ps -ef | grep -w ${proc_name} | grep -v grep | wc -l)"
    echo "${process_num}" >${process_num_file}
    # # 测试数据写入文件
    # if [ ${process_num} -gt ${pre_process_num} ]; then
    #   echo $(date '+%Y-%m-%d %H:%M:%S') ":" ${pre_process_num} "/" ${process_num} >>"${process_num_log_file}"
    # fi

    if [[ ${process_num} -gt ${pre_process_num} && ${pre_process_num} -lt 4 ]]; then
      handle_sgame_start
    elif [[ ${process_num} -lt ${pre_process_num} && ${process_num} -le 2 ]]; then
      handle_sgame_stop
    fi
    if [ ${process_num} -le 2 ]; then
      sleep 1
    else
      sleep 5
    fi
  done
}

echo '0' >${process_num_file}
echo 开始运行
start_service
