#自带核心默认为linux arm64，大部分安卓机可以运行
#其他系统无法运行则需要重新下载核心


#是否下载体积更小的upx压缩版本，部分系统不支持(1开启)
downloadUPX='1'

#免流Host
mlHost='dm.toutiao.com'








aotuGetAbi() {
	abi=`uname -m`
	if echo "$abi"|grep -Eq 'i686|i386'; then
		abi="386"
	elif echo "$abi"|grep -Eq 'armv7|armv6'; then
		abi="arm"
	elif echo "$abi"|grep -Eq 'armv8|aarch64'; then
		abi="arm64"
	elif echo "$abi"|grep -q 'mips64'; then
		shContent=`cat "$SHELL"`
		[ "${shContent:5:1}" = `echo $echo_e_arg "\x01"` ] && abi='mips64le' || abi='mips64'
	elif echo "$machine"|grep -q 'mips'; then
		shContent=`cat "$SHELL"`
		[ "${shContent:5:1}" = `echo $echo_e_arg "\x01"` ] && abi='mipsle' || abi='mips'
	else
		abi="amd64"
	fi
}

setDownloadTool() {
	export http_proxy='119.29.186.53:80'
	if type curl; then
		download_tool='curl -o'
	elif type wget; then
		download_tool="wget -O"
	else
		return 1
	fi &>/dev/null
}

installDownloadTool() {
	for PM in apt-get yum pacman pkg dnf; do
		type $PM && break
	done &>/dev/null
	$PM -y install wget curl 2>/dev/null
}

downloadCore() {
	host="$1"
	coreName="$2"
	helpFlag="$3"
	[ "$downloadUPX" = '1' ] && upxDir='upx'
	echo "$coreName($abi)下载中..."
	rm new$coreName 2>/dev/null
	$download_tool new$coreName --header 'Cute: pros.cutebi.flashproxy.cn' http://$host/$coreName/$upxDir/linux_$abi
	chmod 777 new$coreName
	if ./new$coreName -h 2>/dev/null | grep -q "$helpFlag"; then
		mv -f new$coreName $coreName
	fi &
	sleep 2
	if [ -f "/proc/$!/cwd/CuteBi" ]; then
		kill -9 $! 2>&-
		echo "$coreName($abi)下载或启动失败"
		echo "尝试下载非upx压缩的版本"
		downloadUPX='0'
		downloadCore "$host" "$coreName" "$helpFlag"
	elif [ -f "new$coreName" ]; then
		echo "$coreName($abi)下载或启动失败"
	else
		echo "$coreName($abi)下载成功"
	fi
}

cd "${0%/*}"
aotuGetAbi
if ! setDownloadTool; then
	installDownloadTool
	setDownloadTool || exec echo "系统必须有curl或者wget命令才可以下载！"
fi
if [ -n "$1" -a -n "$2" -a -n "$3" ]; then
	downloadCore "$1" "$2" "$3"
else
	downloadCore "$mlHost" clnc 'clnc'
fi
