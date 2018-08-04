# update

yum -y update

# install wget curl nano

yum -y install wget curl
yum -y install nano

# initialisasi var
OS=`uname -p`;
MYIP=`curl -s ifconfig.me`;
MYIP2="s/xxxxxxxxx/$MYIP/g";

# setting repo

## RHEL/CentOS 7 64-Bit ##

wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm

wget https://rpms.remirepo.net/enterprise/remi-release-7.rpm
rpm -ivh remi-release-7.rpm

# remove unused

yum -y remove sendmail;
yum -y remove httpd;
yum -y remove cyrus-sasl

# install webserver
yum -y install nginx php-fpm php-cli
service nginx restart
service php-fpm restart
chkconfig nginx on
chkconfig php-fpm on

# install essential package
yum -y install rrdtool screen iftop htop nmap bc nethogs vnstat ngrep mtr git zsh mrtg unrar rsyslog rkhunter mrtg net-snmp net-snmp-utils expect nano bind-utils
yum -y groupinstall 'Development Tools'
yum -y install cmake

yum -y --enablerepo=rpmforge install axel sslh ptunnel unrar

# matiin exim
service exim stop
chkconfig exim off

# setting vnstat
vnstat -u -i venet0
echo "MAILTO=root" > /etc/cron.d/vnstat
echo "*/5 * * * * root /usr/sbin/vnstat.cron" >> /etc/cron.d/vnstat
sed -i 's/eth0/venet0/g' /etc/sysconfig/vnstat
service vnstat restart
chkconfig vnstat on

# install screenfetch
cd
wget https://github.com/KittyKatt/screenFetch/raw/master/screenfetch-dev
mv screenfetch-dev /usr/bin/screenfetch
chmod +x /usr/bin/screenfetch
echo "clear" >> .bash_profile
echo "screenfetch" >> .bash_profile

# install webserver
cd
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/0DinZ/CentOS-7-AutoScript/master/conf/nginx.conf"
sed -i 's/www-data/nginx/g' /etc/nginx/nginx.conf
mkdir -p /home/vps/public_html
echo "<pre>|Setup by 0DinZ | </pre>" > /home/vps/public_html/index.html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
rm /etc/nginx/conf.d/*
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/0DinZ/CentOS-7-AutoScript/master/conf/vps.conf"
sed -i 's/apache/nginx/g' /etc/php-fpm.d/www.conf
chmod -R +rx /home/vps
service php-fpm restart
service nginx restart

# install mrtg
cd /etc/snmp/
wget -O /etc/snmp/snmpd.conf "https://raw.githubusercontent.com/0DinZ/CentOS-7-AutoScript/master/conf/snmpd.conf"
wget -O /root/mrtg-mem.sh "https://raw.githubusercontent.com/0DinZ/CentOS-7-AutoScript/master/conf/mrtg-mem.sh"
chmod +x /root/mrtg-mem.sh
service snmpd restart
chkconfig snmpd on
snmpwalk -v 1 -c public localhost | tail
mkdir -p /home/vps/public_html/mrtg
cfgmaker --zero-speed 100000000 --global 'WorkDir: /home/vps/public_html/mrtg' --output /etc/mrtg/mrtg.cfg public@localhost
curl "https://raw.githubusercontent.com/0DinZ/CentOS-7-AutoScript/master/conf/mrtg.conf" >> /etc/mrtg/mrtg.cfg
sed -i 's/WorkDir: \/var\/www\/mrtg/# WorkDir: \/var\/www\/mrtg/g' /etc/mrtg/mrtg.cfg
sed -i 's/# Options\[_\]: growright, bits/Options\[_\]: growright/g' /etc/mrtg/mrtg.cfg
indexmaker --output=/home/vps/public_html/mrtg/index.html /etc/mrtg/mrtg.cfg
echo "0-59/5 * * * * root env LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg" > /etc/cron.d/mrtg
LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg
LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg
LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg
cd

# install Dropbear

yum -y install dropbear 
cat > /etc/sysconfig/dropbear <<END
NO_START=0
OPTIONS="-p 143 -W 1024000 -K 3600 -I 3600 "
DROPBEAR_BANNER=""
#DROPBEAR_RSAKEY="/etc/dropbear/dropbear_rsa_host_key"
#DROPBEAR_DSSKEY="/etc/dropbear/dropbear_dss_host_key"
DROPBEAR_RECEIVE_WINDOW=65536
END

chkconfig dropbear on
service dropbear start
service dropbear restart

# install squid
yum -y install squid
wget -O /etc/squid/squid.conf "https://raw.githubusercontent.com/0DinZ/CentOS-7-AutoScript/master/conf/squid-centos.conf"
sed -i $MYIP2 /etc/squid/squid.conf;
service squid restart
chkconfig squid on

# install vnstat gui
cd /home/vps/public_html/
wget http://www.sqweek.com/sqweek/files/vnstat_php_frontend-1.5.1.tar.gz
tar xf vnstat_php_frontend-1.5.1.tar.gz
rm vnstat_php_frontend-1.5.1.tar.gz
mv vnstat_php_frontend-1.5.1 vnstat
cd vnstat
sed -i 's/eth0/venet0/g' config.php
sed -i "s/\$iface_list = array('venet0', 'sixxs');/\$iface_list = array('venet0');/g" config.php
sed -i "s/\$language = 'nl';/\$language = 'en';/g" config.php
sed -i 's/Internal/Internet/g' config.php
sed -i '/SixXS IPv6/d' config.php
cd

# install fail2ban
yum -y install fail2ban
service fail2ban restart
chkconfig fail2ban on

# downlaod script
cd
wget -O speedtest_cli.py "https://raw.github.com/sivel/speedtest-cli/master/speedtest_cli.py"
wget -O bench-network.sh "https://raw.githubusercontent.com/0DinZ/CentOS-7-AutoScript/master/conf/bench-network.sh"
wget -O ps_mem.py "https://raw.github.com/pixelb/ps_mem/master/ps_mem.py"
chmod +x bench-network.sh
chmod +x speedtest_cli.py
chmod +x ps_mem.py

# cron
service crond start
chkconfig crond on

# set time GMT +8
ln -fs /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime

# finalisasi
chown -R nginx:nginx /home/vps/public_html
service nginx start
service php-fpm start
service vnstat restart
service snmpd restart
service sshd restart
service dropbear restart
service fail2ban restart
service squid restart
service webmin restart
service crond start

echo -----------------------------------------------------
echo Install finish!
echo Please Reboot Server
echo ------------------------------------------------------
exit