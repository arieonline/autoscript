Automatic Script Installer by Orang

==========

## Usage

### CentOS 7 64 bit (OpenVZ VPS)
```
SSH Dropbear Squid Setup

wget https://raw.githubusercontent.com/0DinZ/CentOS-7-AutoScript/master/centos7.sh
bash centos7.sh
```

```
SoftEther Script

wget https://raw.githubusercontent.com/0DinZ/CentOS-7-AutoScript/master/centos7softether.sh
bash centos7softether.sh

 # After install
 
cd /usr/local/vpnserver
./vpncmd (Press 1, enter localhost:5555, empty hub)
ServerPasswordSet (set your password)
Done (Please setup Using SE-VPN Server Manager (Tools))

# Note FirewallD may block your connection

systemctl disable firewalld
systemctl stop firewalld
```
Tested on
* CentOS 7 64 bit
* OpenVZ only

## Description

### What's server included
* OpenSSH port 22
* Dropbear port 143
* Squid port 8080 (limit to IP VPS)
* SoftEther VPN (Please Setup Manually)

### What's features included
* Webmin http(s)://[ip]:10000/
* vnstat http://[ip]/vnstat/
* MRTG http://[ip]/mrtg/
* Timezone : Asia/Kuala Lumpur
* Fail2Ban : [on]

### What's tools included
* axel
* bmon
* htop
* iftop
* mtr
* nethogs  

### What's script included
* screenfetch (https://github.com/KittyKatt/screenFetch)
* ps_mem.py (https://github.com/pixelb/ps_mem/)
* speedtest-cli (https://github.com/sivel/speedtest-cli)
* bench-network.sh

## Reference
* http://blog.jualssh.com/
* http://blog.jualssh.com/2014/01/centos6-automatic-script-installer/
* http://blog.jualssh.com/2014/01/debian6-sh-automatic-script-installer/
* http://blog.jualssh.com/2014/01/debian7-sh-automatic-script-installer/

