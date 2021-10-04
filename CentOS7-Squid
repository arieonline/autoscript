# initialisasi var
OS=`uname -p`;
MYIP=`curl -s ifconfig.me`;
MYIP2="s/xxxxxxxxx/$MYIP/g";
yum -y install squid
wget -O /etc/squid/squid.conf "https://raw.githubusercontent.com/0DinZ/CentOS-7-AutoScript/master/conf/squid-centos.conf"
sed -i $MYIP2 /etc/squid/squid.conf;
systemctl restart squid
systemctl enable squid

clear
echo "Setup By 0DinZ" | tee log-install.txt
echo "===============================================" | tee -a log-install.txt
echo "Squid3   : 8080 (limit to IP SSH)"  | tee -a log-install.txt
echo "==============================================="  | tee -a log-install.txt
