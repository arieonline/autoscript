# update

yum -y update
yum groupinstall "Development Tools" -y

# install wget and curl
yum -y install wget curl

# install
cd ..
wget https://www.softether-download.com/files/softether/v4.27-9668-beta-2018.05.29-tree/Linux/SoftEther_VPN_Server/64bit_-_Intel_x64_or_AMD64/softether-vpnserver-v4.27-9668-beta-2018.05.29-linux-x64-64bit.tar.gz
tar xzvf softether-vpnserver-v4.27-9668-beta-2018.05.29-linux-x64-64bit.tar.gz
cd vpnserver
clear
make
cd ..
#Moving files to /usr/local

mv vpnserver /usr/local
#Set the permissions

cd /usr/local/vpnserver
chmod 600 *
chmod 700 vpncmd
chmod 700 vpnserver

#Downloading the Scripts for init.d and set Permission
cd /root
wget -O /etc/init.d/vpnserver "https://raw.githubusercontent.com/0DinZ/CentOS-7-AutoScript/master/conf/softether.conf"
mkdir /var/lock/subsys
chmod 755 /etc/init.d/vpnserver && /etc/init.d/vpnserver start
chkconfig --add vpnserver

#End
echo -----------------------------------------------------
echo Install finish!
echo check this step to check are installer is working properly
echo 1. vpnserver and vpncmd is on /usr/local/vpnserver
echo 2. /etc/init.d/vpnserver start can executed
echo if vpnserver can start, congratulations!
echo ------------------------------------------------------
exit