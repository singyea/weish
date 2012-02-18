#!/bin/bash

WEIBO_POST_TEMP="/tmp/temp_weish_post.txt"


function weibo_post()
{
echo "#不超过140字:" >${WEIBO_POST_TEMP}
echo " ">>${WEIBO_POST_TEMP}
vi +2 ${WEIBO_POST_TEMP}
cat ${WEIBO_POST_TEMP} | grep -v ^#
echo " ">>${WEIBO_POST_TEMP}
}

if [ "$1" == "post" ]; then
	weibo_post
fi
