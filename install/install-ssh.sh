#!/bin/bash
# Install SSH Websocket 
# Mod By San (Fix for Debian 12)
# ==================================================

# initializing var
export DEBIAN_FRONTEND=noninteractive
MYIP=$(wget -qO- https://ipinfo.io/ip);
NET=$(ip -o $ANU -4 route show to default | awk '{print $5}')
source /etc/os-release
ver=$VERSION_ID

#detail nama perusahaan
country=ID
state=INDONESIA
locality=JAWATENGAH
organization=Blogger
organizationalunit=Blogger
commonname=none
email=admin@sedang.my.id


# go to root
cd

# Edit file /etc/systemd/system/rc-local.service
cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

# nano /etc/rc.local
cat > /etc/rc.local <<-END
#!/bin/sh -e
# rc.local
# By default this script does nothing.
exit 0
END

# Ubah izin akses
chmod +x /etc/rc.local

# enable rc local
systemctl enable rc-local
systemctl start rc-local.service

# disable ipv6
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local

#update
apt update -y
apt upgrade -y
apt dist-upgrade -y
apt-get remove --purge ufw firewalld -y
apt-get remove --purge exim4 -y

#install jq
apt -y install jq

#install shc
apt -y install shc

# install wget and curl
apt install python3 -y
apt -y install wget curl

#figlet
apt-get install figlet -y
apt-get install ruby -y
gem install lolcat

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# set locale
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config

# install webserver
apt -y install nginx
cd
rm /etc/nginx/sites-enabled/default
rm /etc/nginx/sites-available/default
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/Paper890/mysc/main/ssh/nginx.conf"
rm /etc/nginx/conf.d/vps.conf
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/Paper890/mysc/main/ssh/vps.conf"
/etc/init.d/nginx restart

mkdir /etc/systemd/system/nginx.service.d
printf "[Service]\nExecStartPost=/bin/sleep 0.1\n" > /etc/systemd/system/nginx.service.d/override.conf
rm /etc/nginx/conf.d/default.conf
systemctl daemon-reload
service nginx restart
cd
mkdir -p /home/vps/public_html
wget -O /home/vps/public_html/index.html "https://raw.githubusercontent.com/Paper890/mysc/main/ssh/multiport"
wget -O /home/vps/public_html/.htaccess "https://raw.githubusercontent.com/Paper890/mysc/main/ssh/.htaccess"
mkdir -p /home/vps/public_html/ss-ws
mkdir -p /home/vps/public_html/clash-ws

# install badvpn
cd
apt install screen -y
wget -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/Paper890/mysc/main/ssh/newudpgw"
chmod +x /usr/bin/badvpn-udpgw

# Add services
for port in 7100 7200 7300 7400 7500 7600 7700 7800 7900; do
    echo "screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:$port --max-clients 500" >> /etc/rc.local
    screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:$port --max-clients 500
done

# setting port ssh
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 500' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 40000' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 51443' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 58080' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 200' /etc/ssh/sshd_config
sed -i 's/#Port 22/Port 22/g' /etc/ssh/sshd_config
/etc/init.d/ssh restart

echo "=== Install Dropbear ==="
apt -y install dropbear
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=143/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 50000 -p 109 -p 110 -p 69"/g' /etc/default/dropbear
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
/etc/init.d/ssh restart
/etc/init.d/dropbear restart

# install stunnel
apt install stunnel4 -y
cat > /etc/stunnel/stunnel.conf <<-END
cert = /etc/stunnel/stunnel.pem
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear]
accept = 222
connect = 127.0.0.1:22

[dropbear]
accept = 777
connect = 127.0.0.1:109

[ws-stunnel]
accept = 2096
connect = 700

[openvpn]
accept = 442
connect = 127.0.0.1:1194

END

# make a certificate
openssl genrsa -out key.pem 2048
openssl req -new -x509 -key key.pem -out cert.pem -days 1095 \
-subj "/C=$country/ST=$state/L=$locality/O=$organization/OU=$organizationalunit/CN=$commonname/emailAddress=$email"
cat key.pem cert.pem >> /etc/stunnel/stunnel.pem

# konfigurasi stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
/etc/init.d/stunnel4 restart

# install fail2ban
apt -y install fail2ban

# Instal DDOS Flate
if [ -d '/usr/local/ddos' ]; then
    echo "Previous version detected. Please uninstall first."
    exit 1
else
    mkdir -p /usr/local/ddos
fi

wget -q -O /usr/local/ddos/ddos.conf http://www.inetbase.com/scripts/ddos/ddos.conf
wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE
wget -q -O /usr/local/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list
wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1

# banner /etc/issue.net
wget -O /etc/issue.net "https://raw.githubusercontent.com/Paper890/mysc/main/issue.net"
chmod +x /etc/issue.net
echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/issue.net"@g' /etc/default/dropbear

# download script
cd /usr/bin
wget -O speedtest "https://raw.githubusercontent.com/FranataVPN/src/ipuk/ssh/speedtest_cli.py"
wget -O xp "https://raw.githubusercontent.com/Paper890/mysc/main/ssh/xp.sh"
wget -O auto-set "https://raw.githubusercontent.com/Paper890/mysc/main/xray/auto-set.sh"
chmod +x speedtest xp auto-set
cd

cat > /etc/cron.d/re_otm <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 7 * * * root /sbin/reboot
END

cat > /etc/cron.d/xp_otm <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
2 0 * * * root /usr/bin/xp
END

cat > /home/re_otm <<-END
7
END

service cron restart >/dev/null 2>&1
service cron reload >/dev/null 2>&1

# remove unnecessary files
apt autoclean -y >/dev/null 2>&1

if dpkg -s unscd >/dev/null 2>&1; then
    apt -y remove --purge unscd >/dev/null 2>&1
fi

# finishing
chown -R www-data:www-data /home/vps/public_html
sleep 1
echo "Restarting all services..."
/etc/init.d/nginx restart >/dev/null 2>&1
/etc/init.d/ssh restart >/dev/null 2>&1
/etc/init.d/dropbear restart >/dev/null 2>&1
/etc/init.d/fail2ban restart >/dev/null 2>&1
/etc/init.d/stunnel4 restart >/dev/null 2>&1

history -c
echo "unset HISTFILE" >> /etc/profile

rm -f /root/key.pem
rm -f /root/cert.pem
rm -f /root/ssh-vpn.sh
rm -f /root/bbr.sh

clear
echo ""
echo "✅ Installation Completed!"
echo "Your server is ready for use."
