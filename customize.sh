#!/sbin/sh
#####################
# Priv Protect Customization
#####################
SKIPUNZIP=1

local_string="北京"

# prepare v2ray execute environment
ui_print "- 准备priv运行环境."
mkdir -p /data/priv
mkdir -p /data/priv/.system
mkdir -p /data/priv/config
touch /data/priv/.system/.process_num
# if [[ ! -f "/data/priv/local.config" ]]; then
#   touch /data/priv/local.config
# fi
echo "${local_string}" >/data/priv/local.config
if [[ ! -f "/data/priv/config/.freeze_self" && ! -f "/data/priv/config/freeze_self" ]]; then
  touch /data/priv/config/.freeze_self
fi
if [[ ! -f "/data/priv/config/.freeze_proxy_app" && ! -f "/data/priv/config/freeze_proxy_app" ]]; then
  touch /data/priv/config/.freeze_proxy_app
fi
if [[ ! -f "/data/priv/config/.v2rayNG" && ! -f "/data/priv/config/v2rayNG" ]]; then
  touch /data/priv/config/.v2rayNG
fi
if [[ ! -f "/data/priv/config/.Kitsunebi" && ! -f "/data/priv/config/Kitsunebi" ]]; then
  touch /data/priv/config/.Kitsunebi
fi
if [[ ! -f "/data/priv/config/.clnc" && ! -f "/data/priv/config/clnc" ]]; then
  touch /data/priv/config/clnc
fi

unzip -o "${ZIPFILE}" 'priv/clnc_priv.conf' -d $MODPATH >&2
unzip -o "${ZIPFILE}" 'priv/config.ini' -d $MODPATH >&2
unzip -o "${ZIPFILE}" 'priv/start.sh' -d $MODPATH >&2
unzip -o "${ZIPFILE}" 'priv/stop.sh' -d $MODPATH >&2
unzip -o "${ZIPFILE}" 'priv/test.sh' -d $MODPATH >&2
unzip -o "${ZIPFILE}" 'priv/Core/*' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'service.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'uninstall.sh' -d $MODPATH >&2

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

# generate module.prop
ui_print "- 生成 module.prop"
rm -rf $MODPATH/module.prop
touch $MODPATH/module.prop
echo "id=sgame_priv" >$MODPATH/module.prop
echo "name=王者特权防异常" >>$MODPATH/module.prop
echo -n "version=v0.6.0" >>$MODPATH/module.prop
echo ${latest_v2ray_version} >>$MODPATH/module.prop
echo "versionCode=20210901" >>$MODPATH/module.prop
echo "author=ywlin" >>$MODPATH/module.prop
echo "description=王者荣耀特权防异常模块（北京），一键刷入无需配置。（源码地址: https://github.com/lyzcren/sgame_priv_protect#readme ）" >>$MODPATH/module.prop

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

ui_print "- 安装已完成，请在xposed框架中启用“lataclysm”、“对话框取消beta版”模块"
ui_print "- 如果你使用的是 LSPosed，请在模块作用域中勾选“王者荣耀”"
