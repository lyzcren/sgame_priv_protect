#!/sbin/sh
#####################
# Priv Protect Customization
#####################
SKIPUNZIP=1

# prepare v2ray execute environment
ui_print "- 准备priv运行环境."
mkdir -p /data/priv
mkdir -p /data/priv/.system
mkdir -p /data/priv/config
touch /data/priv/.system/.process_num
if [[ ! -f "/data/priv/local.config" ]]; then
  touch /data/priv/local.config
fi
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

unzip -j -o "${ZIPFILE}" 'priv/scripts/*' -d $MODPATH/scripts >&2
unzip -j -o "${ZIPFILE}" 'service.sh' -d $MODPATH >&2
unzip -j -o "${ZIPFILE}" 'uninstall.sh' -d $MODPATH >&2

# generate module.prop
ui_print "- 生成 module.prop"
rm -rf $MODPATH/module.prop
touch $MODPATH/module.prop
echo "id=sgame_priv" >$MODPATH/module.prop
echo "name=王者特权防异常" >>$MODPATH/module.prop
echo -n "version=v0.3.0" >>$MODPATH/module.prop
echo ${latest_v2ray_version} >>$MODPATH/module.prop
echo "versionCode=20210708" >>$MODPATH/module.prop
echo "author=ywlin" >>$MODPATH/module.prop
echo "description=王者荣耀特权防异常模块（本模块不能代替代理类软件，不懂如何使用的请查看说明文档: https://github.com/lyzcren/sgame_priv_protect#readme ）" >>$MODPATH/module.prop

set_perm_recursive $MODPATH 0 0 0755 0644
set_perm $MODPATH/service.sh 0 0 0755
set_perm $MODPATH/uninstall.sh 0 0 0755
set_perm $MODPATH/scripts/start.sh 0 0 0755
