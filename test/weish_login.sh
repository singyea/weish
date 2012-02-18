#!/bin/bash

CURL=curl

WEISH_CFG=${HOME}/.weish.cfg
WEIBO_LOGIN_PRE_PAGE="http://3g.sina.com.cn/prog/wapsite/sso/login.php?ns=1&backURL=http://weibo.cn/dpool/ttt/home.php?s2w=login&backTitle=新浪微博&vt=4"
WEIBO_LOGIN_SUBMIT_PAGE="http://3g.sina.com.cn/prog/wapsite/sso/login_submit.php"
WEIBO_ACCOUNT_PAGE='http://weibo.cn/account/'
WEIBO_URL="http://weibo.cn/?gsid="

function login_get_user_pass()
{
	printf "Username:"
	read username
	stty -echo
	printf "Password:"
	read password
	stty echo
}

function login_get_pre_page()
{
	${CURL} ${WEIBO_LOGIN_PRE_PAGE} -D cookie.txt 2>/dev/null >sina_login_pre_page.html
	WEIBO_PRE_LOGIN_RAND=`cat sina_login_pre_page.html| grep rand | sed 's/=/\n/g;s/&amp;/\n/g;' | sed -n '3p'`
	WEIBO_PRE_LOGIN_VK=`cat sina_login_pre_page.html | grep vk | sed 's/"/\n/g' | sed -n '6p'`
	WEIBO_PRE_LOGIN_PASSVK=`cat sina_login_pre_page.html | grep pass | sed 's/"/\n/g' | sed -n '4p'`
#	rm -fr sina_login_pre_page.html
}

function login_put_user_pass()
{
	WEIBO_LOGIN_POST_DATA="mobile="$username"&"${WEIBO_PRE_LOGIN_PASSVK}"="$password"&remember=on&backURL=http%3A%2F%2Fweibo.cn%2Fdpool%2Fttt%2Fhome.php%3Fs2w%3Dlogin&backTitle=%E6%96%B0%E6%B5%AA%E5%BE%AE%E5%8D%9A&backURL=http%3A%2F%2Fweibo.cn%2Fdpool%2Fttt%2Fhome.php%3Fs2w%3Dlogin&vk="${WEIBO_PRE_LOGIN_VK}"&submit=%E7%99%BB%E5%BD%95"

	${CURL}  -D login_state.txt --data ${WEIBO_LOGIN_POST_DATA} ${WEIBO_LOGIN_SUBMIT_PAGE}"?rand="${WEIBO_PRE_LOGIN_RAND}"&backURL=http://weibo.cn/dpool/ttt/home.php&backTitle=新浪微博&vt=4&ns=1"
}


function login_get_gsid()
{
	WEIBO_GSID=`cat login_state.txt | grep Location | sed 's/%26/\n/g;s/%3D/\n/g' | sed -n '2p'`
	echo  ${WEIBO_GSID} > ${WEISH_CFG}
}





function login_check_login()
{
	if [ ! -f $WEISH_CFG ] ;then 
		return 0
	fi

	WEISH_CFG_GSID=`cat ${WEISH_CFG}`
	${CURL} -D state.txt ${WEIBO_ACCOUNT_PAGE}"?gsid="$WEISH_CFG_GSID > /dev/null 2>&1
	LOGIN_STATE=`cat state.txt  | sed -n '1p' | awk '{print $2}'`

	if [ "${LOGIN_STATE}" == "200" ]; then
		WEIBO_GSID=${WEISH_CFG_GSID}
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
		login_get_user_pass
		login_get_pre_page
		login_put_user_pass
		login_get_gsid
	fi
}

function load_weibo()
{
	
	${CURL} $WEIBO_URL$WEIBO_GSID 2>/dev/null  | sed 's/>/>\n/g' | sed '1,102d'| sed ':a;N;s/\n/\t/;ba;'|sed 's/<div class=\"c\"/\r\n\r\n<div class=\"c\"/g' | sed -e :a -e 's/<[^>]*>//g;/</N;//ba' |  sed 's/[[:space:]]//g' | sed  's/&nbsp;//g' | sed '/$//g'
}

login
load_weibo
