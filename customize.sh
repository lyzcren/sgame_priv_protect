#!/sbin/sh
#####################
# Priv Protect Customization
#####################
SKIPUNZIP=1

local_string="北京"

# 删除旧版本配置
ui_print "- 正在删除旧版本配置."
rm -rf /data/priv

# prepare execute environment
ui_print "- 准备priv运行环境."
mkdir -p /data/priv
mkdir -p /data/priv/.system
mkdir -p /data/priv/config
touch /data/priv/.system/.process_num

# 写入模拟地区
echo "${local_string}" >/data/priv/config/local.config
# 检查当前地区.sh
cat >/data/priv/检查当前地区.sh <<EOF
  echo '当前模拟地区：'
  cat /data/priv/config/local.config
EOF
# 修改模拟地区.sh
cat >/data/priv/修改模拟地区.sh <<EOF
  echo "请输入你模拟的地区："
  read local_string
  if [ -n "${local_string}" ]; then
    echo "\${local_string}" >/data/priv/config/local.config
  if
EOF
# 写入 Kitsunebi.sh
cat >/data/priv/Kitsunebi.sh <<EOF
  rm -rf /data/priv/config/v2rayNG /data/priv/config/Kitsunebi /data/priv/config/clnc
  touch /data/priv/config/Kitsunebi
EOF
# 写入 v2rayNG.sh
cat >/data/priv/v2rayNG.sh <<EOF
  rm -rf /data/priv/config/v2rayNG /data/priv/config/Kitsunebi /data/priv/config/clnc
  touch /data/priv/config/v2rayNG
EOF
# 写入 clnc.sh
cat >/data/priv/clnc.sh <<EOF
  rm -rf /data/priv/config/v2rayNG /data/priv/config/Kitsunebi /data/priv/config/clnc
  touch /data/priv/config/clnc
EOF
# 默认 clnc 代理
if [[ ! -f "/data/priv/config/v2rayNG" && ! -f "/data/priv/config/Kitsunebi" && ! -f "/data/priv/config/clnc" ]]; then
  touch /data/priv/config/clnc
fi

unzip -o "${ZIPFILE}" 'priv/clnc_priv.conf' -d $MODPATH >&2
unzip -o "${ZIPFILE}" 'priv/config.ini' -d $MODPATH >&2
unzip -o "${ZIPFILE}" 'priv/start.sh' -d $MODPATH >&2
unzip -o "${ZIPFILE}" 'priv/stop.sh' -d $MODPATH >&2
unzip -o "${ZIPFILE}" 'priv/test.sh' -d $MODPATH >&2
unzip -o "${ZIPFILE}" 'priv/addon/*' -d $MODPATH >&2
unzip -o "${ZIPFILE}" 'priv/Core/*' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'service.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'uninstall.sh' -d $MODPATH >&2

# Run addons
if [ "$(ls -A $MODPATH/priv/addon/*/install.sh 2>/dev/null)" ]; then
  ui_print " "
  ui_print "- 安装插件 -"
  for i in $MODPATH/priv/addon/*/install.sh; do
    ui_print "  正在安装 $(echo $i | sed -r "s|$MODPATH/priv/addon/(.*)/install.sh|\1|")..."
    . $i
  done
fi

ui_print ""
ui_print "    是否自动写入模拟信息？   "
ui_print "   音量+： 是     音量-： 否"
ui_print ""
if $VKSEL; then
  # 安装对话框取消模块
  if [ ! -n "$(pm list packages | grep com.mhook.dialog.beta)" ]; then
    ui_print "- 检测到未安装 对话框取消 模块"
    ui_print "- 解压 对话框取消 模块"
    unzip -j -o "${ZIPFILE}" 'priv/apk/dialog.apk' -d '/data/priv/apk' >&2
    ui_print "- 安装 对话框取消 模块"
    pm install /data/priv/apk/dialog.apk
    ui_print "- 清理 对话框取消 模块安装包"
    rm /data/priv/apk/dialog.apk
  else
    ui_print "- 检测到已安装 对话框取消 模块"
  fi

  # 安装 lataclysm 模块
  if [ ! -n "$(pm list packages | grep com.cataclysm.i)" ]; then
    ui_print "- 检测到未安装 lataclysm 模块"
    ui_print "- 解压 lataclysm 模块"
    unzip -j -o "${ZIPFILE}" 'priv/apk/lataclysm.apk' -d '/data/priv/apk' >&2
    ui_print "- 安装 lataclysm 模块"
    pm install /data/priv/apk/lataclysm.apk
    ui_print "- 清理 lataclysm 安装包"
    rm /data/priv/apk/lataclysm.apk
  else
    ui_print "- 检测到已安装 lataclysm 模块"
  fi

  # 写入模拟数据
  ui_print "- 启用对话框取消模块增强功能"
  unzip -j -o "${ZIPFILE}" 'priv/apk/digXposed.xml' -d '/data/data/com.mhook.dialog.beta/shared_prefs' >&2
  ui_print "- 写入WiFi模拟信息"
  unzip -j -o "${ZIPFILE}" 'priv/apk/com.tencent.tmgp.sgame.xml' -d '/data/data/com.mhook.dialog.beta/shared_prefs' >&2
  ui_print "- 写入定位模拟信息"
  if [ ! -f "/data/data/com.cataclysm.i/shared_prefs/com.cataclysm.i_preferences.xml" ]; then
    unzip -j -o "${ZIPFILE}" 'priv/apk/com.cataclysm.i_preferences.xml' -d '/data/data/com.cataclysm.i/shared_prefs' >&2
  else
    sed -i "s/<string name=\"keyp0\">.*<\/string>/<string name=\"keyp0\">com\.tencent\.tmgp\.sgame<\/string>/g;s/<string name=\"location0\">.*<\/string>/<string name=\"location0\">0<\/string>/;s/<string name=\"key20\">.*<\/string>/<string name=\"key20\">39.898217106627584,116.48663453546494,0,0,0,金牌-梦想加空间（北京大成国际社区）<\/string>/" /data/data/com.cataclysm.i/shared_prefs/com.cataclysm.i_preferences.xml
  fi
  # 需要修改 lataclysm 及 对话框取消模块 的配置文件夹信息，否则会导致软件无法正常修改数据
  chmod 777 /data/data/com.cataclysm.i/shared_prefs/
  chmod 777 /data/data/com.mhook.dialog.beta/shared_prefs/

  ui_print "- 模拟信息已写入，请在xposed框架中启用“lataclysm”、“对话框取消beta版”模块"
  ui_print "- 如果你使用的是 LSPosed，请在模块作用域中勾选“王者荣耀”"
else
  ui_print "- 不写入模拟信息   "
fi

# generate module.prop
ui_print "- 生成 module.prop"
rm -rf $MODPATH/module.prop
touch $MODPATH/module.prop
echo "id=sgame_priv" >$MODPATH/module.prop
echo "name=王者特权防异常（$local_string）" >>$MODPATH/module.prop
echo -n "version=v0.8.0" >>$MODPATH/module.prop
echo ${latest_v2ray_version} >>$MODPATH/module.prop
echo "versionCode=20210913" >>$MODPATH/module.prop
echo "author=ywlin" >>$MODPATH/module.prop
echo "description=王者荣耀特权防异常模块，一键刷入无需配置。（源码地址: https://github.com/lyzcren/sgame_priv_protect#readme ）" >>$MODPATH/module.prop

set_perm_recursive $MODPATH 0 0 0755 0644
set_perm $MODPATH/service.sh 0 0 0755
set_perm $MODPATH/uninstall.sh 0 0 0755
set_perm $MODPATH/priv/Core/watch.sh 0 0 0755
set_perm $MODPATH/priv/start.sh 0 0 0755
set_perm $MODPATH/priv/stop.sh 0 0 0755
set_perm $MODPATH/priv/test.sh 0 0 0755
set_perm $MODPATH/priv/Core/clnc 0 0 0755
set_perm $MODPATH/priv/Core/CuteBi 0 0 0755
set_perm $MODPATH/priv/Core/download_core 0 0 0755
set_perm $MODPATH/priv/Core/MLBox 0 0 0755
set_perm $MODPATH/priv/Core/busybox 0 0 0755
set_perm /data/priv/Kitsunebi.sh 0 0 0755
set_perm /data/priv/v2rayNG.sh 0 0 0755
set_perm /data/priv/clnc.sh 0 0 0755
set_perm /data/priv/检查当前地区.sh 0 0 0755

rm -rf $MODPATH/priv/addon/
ui_print "- 安装已完成"
