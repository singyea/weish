#!/bin/bash

WEISH_CFG=${HOME}/.weish.cfg
CURL=curl
WEIBO_ACCOUNT='http://weibo.cn/account/'
function login_check_login()
{
	if [ ! -f $WEISH_CFG ] ;then 
		return 0
	fi

	WEISH_CFG_GSID=`cat ${WEISH_CFG}`
	${CURL} -D state.txt ${WEIBO_ACCOUNT}"?gsid="$WEISH_CFG_GSID > /dev/null 2>&1
	LOGIN_STATE=`cat state.txt  | sed -n '1p' | awk '{print $2}'`

	if [ "${LOGIN_STATE}" == "200" ]; then
		return 1
	else
		return 0
	fi
	
}


function login()
{
	login_check_login
	if [ "X$?X" == "X1X" ];then 
		echo OK
	else
		echo 'faild'
	fi
}
login
