#!/bin/bash

USER1=`ps aux | grep "\[priv\]" | sort -k 72 |wc -l`
USER2=`ps aux | grep "\[priv\]" | sort -k 72 |wc -l`
UP=`uptime`

echo $USER1
echo $USER2
echo $UP
echo "jualvpn.tk"
