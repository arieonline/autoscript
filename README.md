Automatic Script Installer by Orang

==========

## Usage
### Centos 6 (OpenVZ VPS)
```
wget https://raw.github.com/arieonline/autoscript/master/centos6.sh
bash centos6.sh
```
Tested on
* CentOS 6 32 bit
* CentOS 6 64 bit
* OpenVZ only

### Centos 6 (KVM VPS)
```
wget https://raw.github.com/arieonline/autoscript/master/centos6-kvm.sh
bash centos6-kvm.sh
```
Tested on
* CentOS 6 32 bit
* CentOS 6 64 bit
* KVM only

### Debian 6 32bit
```
wget https://raw.github.com/arieonline/autoscript/master/debian6.sh
bash debian6.sh
```
Tested on
* Debian 6 32 bit
* Debian 6 64 bit
* OpenVZ only

### Debian 7 32bit
```
wget https://raw.github.com/arieonline/autoscript/master/debian7.sh
bash debian7.sh
```
Tested on
* Debian 7 32 bit
* Debian 7 64 bit
* OpenVZ only


## Description

### What's server included
* OpenSSH port 22, 143
* OpenVPN port 1194 tcp
* Dropbear port 109, 110, 443
* Squid port 8080 (limit to IP VPS)
* badvpn-udpgw port 7300

### What's features included
* Webmin http(s)://[ip]:10000/
* vnstat http://[ip]/vnstat/
* MRTG http://[ip]/mrtg/
* Timezone : Asia/Jakarta
* Fail2Ban : [on]
* IPv6     : [off]

### What's tools included
* axel
* bmon
* htop
* iftop
* mtr
* nethogs  

### What's script included
* screenfetch
* ps_mem.py (https://github.com/pixelb/ps_mem/)
* speedtest-cli (https://github.com/sivel/speedtest-cli)
* bench-network.sh
* user-login.sh
* user-limit.sh
* user-expire.sh

## Reference
* http://blog.jualssh.com/
* http://blog.jualssh.com/2014/01/centos6-automatic-script-installer/
* http://blog.jualssh.com/2014/01/debian6-sh-automatic-script-installer/
* http://blog.jualssh.com/2014/01/debian7-sh-automatic-script-installer/

Openvpn
wget https://raw.github.com/arieonline/autoscript/master/dimas.debian
bash dimas.debian
