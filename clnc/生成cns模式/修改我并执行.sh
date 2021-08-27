#全局cns配置名(不用填.ini后缀)
cnsGlobalConfigs='cns配置1'

#国内cns配置名(国内IP走国内服务器，其他IP走全局配置)
cnsCHConfigs=''

#生成的文件名(不用填.conf后缀)
configName='clnc_cns'










cd "${0%/*}"
. ./makeConfFile
