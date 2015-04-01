#!/bin/bash

# go to root
cd

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

# install wget and curl
apt-get update;apt-get -y install wget curl;

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config
service ssh restart

# set repo
wget -O /etc/apt/sources.list "https://raw.github.com/arieonline/autoscript/master/conf/sources.list.debian7"
wget "http://www.dotdeb.org/dotdeb.gpg"
cat dotdeb.gpg | apt-key add -;rm dotdeb.gpg

# remove unused
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;

# update
apt-get update; apt-get -y upgrade;

# install webserver
apt-get -y install nginx php5-fpm php5-cli

# install essential package
apt-get -y install bmon iftop htop nmap axel nano iptables traceroute sysv-rc-conf dnsutils bc nethogs openvpn vnstat less screen psmisc apt-file whois ptunnel ngrep mtr git zsh mrtg snmp snmpd snmp-mibs-downloader unzip unrar rsyslog debsums rkhunter
apt-get -y install build-essential

# disable exim
service exim4 stop
sysv-rc-conf exim4 off

# update apt-file
apt-file update

# setting vnstat
vnstat -u -i venet0
service vnstat restart

# install screenfetch
cd
wget https://github.com/KittyKatt/screenFetch/raw/master/screenfetch-dev
mv screenfetch-dev /usr/bin/screenfetch
chmod +x /usr/bin/screenfetch
echo "clear" >> .profile
echo "screenfetch" >> .profile

# install webserver
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.github.com/arieonline/autoscript/master/conf/nginx.conf"
mkdir -p /home/vps/public_html
echo "<pre>Setup by DYP | Da[R]kCente[R] | @aDYP | 7946F434</pre>" > /home/vps/public_html/index.html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
wget -O /etc/nginx/conf.d/vps.conf "https://raw.github.com/arieonline/autoscript/master/conf/vps.conf"
sed -i 's/listen = \/var\/run\/php5-fpm.sock/listen = 127.0.0.1:9000/g' /etc/php5/fpm/pool.d/www.conf
service php5-fpm restart
service nginx restart

# install openvpn
IP=$(ifconfig | grep 'inet addr:' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d: -f2 | awk '{ print $1}' | head -1)
if [ "$IP" = "" ]; then
        IP=$(wget -qO- ipv4.icanhazip.com)
fi

if [ -e /etc/openvpn/server.conf ]; then
	while :
	do
	clear
		echo "Looks like OpenVPN is already installed"
		echo "What do you want to do?"
		echo ""
		echo "1) Remove OpenVPN"
		echo "2) Exit"
		echo ""
		read -p "Select an option [1-4]:" option
		case $option in
			1) 
			apt-get remove --purge -y openvpn
			rm -rf /etc/openvpn
			rm -rf /usr/share/doc/openvpn
			sed -i '/--dport 53 -j REDIRECT --to-port 1194/d' /etc/rc.local
			sed -i '/iptables -t nat -A POSTROUTING -s 10.8.0.0/d' /etc/rc.local
			echo ""
			echo "OpenVPN removed!"
			exit
			;;
			2) exit;;
		esac
	done
else
	echo 'Selamat Datang di quick OpenVPN "road warrior" installer'
	echo "Modifikasi Oleh Abu naifa untuk opreker"
	echo ""
	# OpenVPN setup and first user creation
	echo "Pertama-tama saya perlu tahu alamat IPv4 yang ingin diinstall OpenVPN"
	echo "listening to."
	read -p "IP address: " -e -i $IP IP
	echo ""
	echo "Port untuk OpenVPN?"
	read -p "Port: " -e -i 1194 PORT
	echo ""
	echo "Apakah Anda ingin OpenVPN akan tersedia pada port 53 juga?"
	echo "Hal ini dapat berguna untuk menghubungkan ke restrictive networks"
	read -p "Listen port 53 [y/n]:" -e -i y ALTPORT
	echo ""
	echo "Sebutkan namamu untuk cert klien"
	echo "Silakan, gunakan satu kata saja, tidak ada karakter khusus"
	read -p "Nama Client: " -e -i client CLIENT
	echo ""
	echo "Oke, itu semua saya butuhkan. Kami siap untuk setup OpenVPN server Anda sekarang"
	read -n1 -r -p "Tekan sembarang tombol untuk melanjutkan ..."
	apt-get update
	apt-get install openvpn iptables openssl -y
	cp -R /usr/share/doc/openvpn/examples/easy-rsa/ /etc/openvpn
	# easy-rsa isn't available by default for Debian Jessie and newer
	if [ ! -d /etc/openvpn/easy-rsa/2.0/ ]; then
		wget --no-check-certificate -O ~/easy-rsa.tar.gz https://github.com/OpenVPN/easy-rsa/archive/2.2.2.tar.gz
		tar xzf ~/easy-rsa.tar.gz -C ~/
		mkdir -p /etc/openvpn/easy-rsa/2.0/
		cp ~/easy-rsa-2.2.2/easy-rsa/2.0/* /etc/openvpn/easy-rsa/2.0/
		rm -rf ~/easy-rsa-2.2.2
	fi
	cd /etc/openvpn/easy-rsa/2.0/
	# Let's fix one thing first...
	cp -u -p openssl-1.0.0.cnf openssl.cnf
	# Bad NSA - 1024 bits was the default for Debian Wheezy and older
	#sed -i 's|export KEY_SIZE=1024|export KEY_SIZE=2048|' /etc/openvpn/easy-rsa/2.0/vars
	# Create the PKI
	. /etc/openvpn/easy-rsa/2.0/vars
	. /etc/openvpn/easy-rsa/2.0/clean-all
	# The following lines are from build-ca. I don't use that script directly
	# because it's interactive and we don't want that. Yes, this could break
	# the installation script if build-ca changes in the future.
	export EASY_RSA="${EASY_RSA:-.}"
	"$EASY_RSA/pkitool" --initca $*
	# Same as the last time, we are going to run build-key-server
	export EASY_RSA="${EASY_RSA:-.}"
	"$EASY_RSA/pkitool" --server server
	# Now the client keys. We need to set KEY_CN or the stupid pkitool will cry
	export KEY_CN="$CLIENT"
	export EASY_RSA="${EASY_RSA:-.}"
	"$EASY_RSA/pkitool" $CLIENT
	# DH params
	. /etc/openvpn/easy-rsa/2.0/build-dh
	# Let's configure the server
cat > /etc/openvpn/server.conf <<-END
port 1194
proto tcp
dev tun
tun-mtu 1500
tun-mtu-extra 32
mssfix 1450
ca /etc/openvpn/ca.crt
cert /etc/openvpn/server.crt
key /etc/openvpn/server.key
dh /etc/openvpn/dh1024.pem
plugin /usr/lib/openvpn/openvpn-auth-pam.so /etc/pam.d/login
client-cert-not-required
username-as-common-name
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
push "route-method exe"
push "route-delay 2"
keepalive 5 30
cipher AES-128-CBC
comp-lzo
persist-key
persist-tun
status server-vpn.log
verb 3
END

	cd /etc/openvpn/easy-rsa/2.0/keys
	cp ca.crt ca.key dh1024.pem server.crt server.key /etc/openvpn
	sed -i "s/port 1194/port $PORT/" /etc/openvpn/server.conf
	# Listen at port 53 too if user wants that
	if [ $ALTPORT = 'y' ]; then
		iptables -t nat -A PREROUTING -p udp -d $IP --dport 53 -j REDIRECT --to-port 1194
		sed -i "/# By default this script does nothing./a\iptables -t nat -A PREROUTING -p udp -d $IP --dport 53 -j REDIRECT --to-port 1194" /etc/rc.local
	fi
	# Enable net.ipv4.ip_forward for the system
	sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf
	# Avoid an unneeded reboot
	echo 1 > /proc/sys/net/ipv4/ip_forward
	# Set iptables
	if [ $(ifconfig | cut -c 1-8 | sort | uniq -u | grep venet0 | grep -v venet0:) = "venet0" ];then
      		iptables -t nat -A POSTROUTING -o venet0 -j SNAT --to-source $IP
	else
      		iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to $IP
      		iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
	fi	
	sed -i "/# By default this script does nothing./a\ip10tables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to $IP" /etc/rc.local
	iptables-save
	# And finally, restart OpenVPN
	/etc/init.d/openvpn restart
	# Let's generate the client config
	mkdir ~/ovpn-$CLIENT
	# Try to detect a NATed connection and ask about it to potential LowEndSpirit
	# users
	EXTERNALIP=$(wget -qO- ipv4.icanhazip.com)
	if [ "$IP" != "$EXTERNALIP" ]; then
		echo ""
		echo "Looks like your server is behind a NAT!"
		echo ""
		echo "If your server is NATed (LowEndSpirit), I need to know the external IP"
		echo "If that's not the case, just ignore this and leave the next field blank"
		read -p "External IP: " -e USEREXTERNALIP
		if [ $USEREXTERNALIP != "" ]; then
			IP=$USEREXTERNALIP
		fi
	fi
	# IP/port set on the default client.conf so we can add further users
	# without asking for them

cat >> ~/ovpn-$CLIENT/$CLIENT.conf <<-END
client
proto tcp
persist-key
persist-tun
dev tun
pull
comp-lzo
ns-cert-type server
verb 3
mute 2
mute-replay-warnings
auth-user-pass
redirect-gateway def1
script-security 2
route-method exe
route-delay 2
remote $IP $PORT
cipher AES-128-CBC
ca [inline]
END
	
	cp /etc/openvpn/easy-rsa/2.0/keys/ca.crt ~/ovpn-$CLIENT

	cd ~/ovpn-$CLIENT
	
	cp $CLIENT.conf $CLIENT.ovpn

	
	echo "<ca>" >> $CLIENT.ovpn
	cat ca.crt >> $CLIENT.ovpn
	echo -e "</ca>\n" >> $CLIENT.ovpn
	
	tar -czf ../ovpn-$CLIENT.tar.gz $CLIENT.conf ca.crt $CLIENT.ovpn
	cd ~/
	rm -rf ovpn-$CLIENT
	echo ""
	echo "Selesai!"
	echo ""
	echo "Your client config is available at ~/ovpn-$CLIENT.tar.gz"
# install badvpn
wget -O /usr/bin/badvpn-udpgw "https://raw.github.com/arieonline/autoscript/master/conf/badvpn-udpgw"
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300

# install mrtg
wget -O /etc/snmp/snmpd.conf "https://raw.github.com/arieonline/autoscript/master/conf/snmpd.conf"
wget -O /root/mrtg-mem.sh "https://raw.github.com/arieonline/autoscript/master/conf/mrtg-mem.sh"
chmod +x /root/mrtg-mem.sh
cd /etc/snmp/
sed -i 's/TRAPDRUN=no/TRAPDRUN=yes/g' /etc/default/snmpd
service snmpd restart
snmpwalk -v 1 -c public localhost 1.3.6.1.4.1.2021.10.1.3.1
mkdir -p /home/vps/public_html/mrtg
cfgmaker --zero-speed 100000000 --global 'WorkDir: /home/vps/public_html/mrtg' --output /etc/mrtg.cfg public@localhost
curl "https://raw.github.com/arieonline/autoscript/master/conf/mrtg.conf" >> /etc/mrtg.cfg
sed -i 's/WorkDir: \/var\/www\/mrtg/# WorkDir: \/var\/www\/mrtg/g' /etc/mrtg.cfg
sed -i 's/# Options\[_\]: growright, bits/Options\[_\]: growright/g' /etc/mrtg.cfg
indexmaker --output=/home/vps/public_html/mrtg/index.html /etc/mrtg.cfg
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
if [ -x /usr/bin/mrtg ] && [ -r /etc/mrtg.cfg ]; then mkdir -p /var/log/mrtg ; env LANG=C /usr/bin/mrtg /etc/mrtg.cfg 2>&1 | tee -a /var/log/mrtg/mrtg.log ; fi
cd

# setting port ssh
sed -i '/Port 22/a Port 143' /etc/ssh/sshd_config
sed -i 's/Port 22/Port  22/g' /etc/ssh/sshd_config
service ssh restart

# install dropbear
apt-get -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=443/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 109 -p 110"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
service ssh restart
service dropbear restart

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
apt-get -y install fail2ban;service fail2ban restart

# install squid3
apt-get -y install aptitude curl

# Specify our IP Server
if [ "$IP" = "" ]; then
        IP=$(curl -s ifconfig.me)
fi

aptitude -y install squid3
rm -f /etc/squid3/squid.conf
wget -P /etc/squid3/ "https://raw.githubusercontent.com/narrundo/vishera/conf/squid.conf"
service squid3 restart

# sed -i 's/#cache_dir/cache_dir/g' /etc/squid3/squid.conf

sed -i "s/ipserver/$IP/g" /etc/squid3/squid.conf

# install webmin
cd
wget "http://prdownloads.sourceforge.net/webadmin/webmin_1.670_all.deb"
dpkg --install webmin_1.670_all.deb;
apt-get -y -f install;
rm /root/webmin_1.670_all.deb
service webmin restart
service vnstat restart

# downlaod script
cd
wget -O speedtest_cli.py "https://raw.github.com/sivel/speedtest-cli/master/speedtest_cli.py"
wget -O bench-network.sh "https://raw.github.com/arieonline/autoscript/master/conf/bench-network.sh"
wget -O ps_mem.py "https://raw.github.com/pixelb/ps_mem/master/ps_mem.py"
wget -O limit.sh "https://raw.github.com/arieonline/autoscript/master/conf/limit.sh"
curl http://script.jualssh.com/user-login.sh > user-login.sh
curl http://script.jualssh.com/user-expire.sh > user-expire.sh
curl http://script.jualssh.com/user-limit.sh > user-limit.sh
echo "0 0 * * * root /root/user-expire.sh" > /etc/cron.d/user-expire
sed -i '$ i\screen -AmdS limit /root/limit.sh' /etc/rc.local
chmod +x bench-network.sh
chmod +x speedtest_cli.py
chmod +x ps_mem.py
chmod +x user-login.sh
chmod +x user-expire.sh
chmod +x user-limit.sh
chmod +x limit.sh

# finalisasi
chown -R www-data:www-data /home/vps/public_html
service nginx start
service php-fpm start
service vnstat restart
service openvpn restart
service snmpd restart
service ssh restart
service dropbear restart
service fail2ban restart
service squid3 restart
service webmin restart

# info
clear
echo "Da[R]kCente[R] | @DYP | DYP | 24ea2a3b" | tee log-install.txt
echo "===============================================" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Service"  | tee -a log-install.txt
echo "-------"  | tee -a log-install.txt
echo "OpenVPN  : TCP 1194 (client config : http://$MYIP/client.tar)"  | tee -a log-install.txt
echo "OpenSSH  : 22, 143"  | tee -a log-install.txt
echo "Dropbear : 109, 110, 443"  | tee -a log-install.txt
echo "Squid3   : 8080 (limit to IP SSH)"  | tee -a log-install.txt
echo "badvpn   : badvpn-udpgw port 7300"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Tools"  | tee -a log-install.txt
echo "-----"  | tee -a log-install.txt
echo "axel"  | tee -a log-install.txt
echo "bmon"  | tee -a log-install.txt
echo "htop"  | tee -a log-install.txt
echo "iftop"  | tee -a log-install.txt
echo "mtr"  | tee -a log-install.txt
echo "nethogs"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Script"  | tee -a log-install.txt
echo "------"  | tee -a log-install.txt
echo "screenfetch"  | tee -a log-install.txt
echo "./ps_mem.py"  | tee -a log-install.txt
echo "./speedtest_cli.py --share"  | tee -a log-install.txt
echo "./bench-network.sh"  | tee -a log-install.txt
echo "./user-login.sh"  | tee -a log-install.txt
echo "./user-expire.sh"  | tee -a log-install.txt
echo "./user-limit.sh 2"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Account Default (utk SSH dan VPN)"  | tee -a log-install.txt
echo "---------------"  | tee -a log-install.txt
echo "User     : KangArie"  | tee -a log-install.txt
echo "Password : $PASS"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Fitur lain"  | tee -a log-install.txt
echo "----------"  | tee -a log-install.txt
echo "Webmin   : https://$MYIP:10000/"  | tee -a log-install.txt
echo "vnstat   : http://$MYIP/vnstat/"  | tee -a log-install.txt
echo "MRTG     : http://$MYIP/mrtg/"  | tee -a log-install.txt
echo "Timezone : Asia/Jakarta"  | tee -a log-install.txt
echo "Fail2Ban : [on]"  | tee -a log-install.txt
echo "IPv6     : [off]"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Log Installasi --> /root/log-install.txt"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "SILAHKAN REBOOT VPS ANDA !"  | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "==============================================="  | tee -a log-install.txt
