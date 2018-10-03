# setting repo

## RHEL/CentOS 7 64-Bit ##

wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm

wget https://rpms.remirepo.net/enterprise/remi-release-7.rpm
rpm -ivh remi-release-7.rpm

# update

yum -y update

# install wget curl nano

yum -y install wget curl
yum -y install nano

# install screenfetch
cd
wget https://github.com/KittyKatt/screenFetch/raw/master/screenfetch-dev
mv screenfetch-dev /usr/bin/screenfetch
chmod +x /usr/bin/screenfetch
echo "clear" >> .bash_profile
echo "screenfetch" >> .bash_profile

# info
clear
echo "Setup By 0DinZ" | tee log-install.txt
echo "===============================================" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "Done" | tee -a log-install.txt
