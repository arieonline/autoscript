#!/bin/bash
# OpenVPN road warrior installer for Debian-based distros

# This script will only work on Debian-based systems. It isn't bulletproof but
# it will probably work if you simply want to setup a VPN on your Debian/Ubuntu
# VPS. It has been designed to be as unobtrusive and universal as possible.
kl
if [ $USER != 'root' ]; then
	echo "Sorry, you need to run this as root"
	exit
fi


if [ ! -e /dev/net/tun ]; then
    echo "TUN/TAP is not available"
    exit
fi

# Try to get our IP from the system and fallback to the Internet.
# I do this to make the script compatible with NATed servers (lowendspirit.com)
# and to avoid getting an IPv6.
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
	echo 'Selamat Datang di quick OpenVPN "Da[R]kCente[R]" installer'
	echo "Created by Dimas Yudha Permana"
	echo ""
	# OpenVPN setup and first user creation
	echo " saya perlu tahu alamat IPv4 yang ingin diinstall OpenVPN"
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
	echo "Sebutkan namamu untuk cert klien lOLZ juga Boleh"
	echo "Silakan, gunakan satu kata saja, tidak ada karakter khusus"
	read -p "Nama Client: " -e -i client CLIENT
	echo ""
	echo "Oke, itu semua saya butuhkan. Kami siap untuk setup OpenVPN server Anda sekarang"
	read -n1 -r -p "Tekan sembarang tombol untuk melanjutkan,,teken hidung sampe kiamat juga boleh ..."
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
