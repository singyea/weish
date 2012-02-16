#!/bin/bash

WEIBO_LOGIN_PAGE="http://weibo.cn/?gsid="
WEIBO_LOGIN_PAGE_SID=test

CURL=curl

${CURL} ${WEIBO_LOGIN_PAGE}${WEIBO_SID} 2>/dev/null  | sed 's/>/>\n/g' | sed '1,102d'| sed ':a;N;s/\n/\t/;ba;'|sed 's/<    div class=\"c\"/\r\n\r\n<div class=\"c\"/g' | sed -e :a -e 's/<[^>]*>//g;/</N;//ba' |  sed 's/[[:space:]]    //g' | sed  's/&nbsp;//g'

