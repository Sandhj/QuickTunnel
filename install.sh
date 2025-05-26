#!/bin/bash
clear
# ==== Export Warna
green='\e[0;32m'
NC='\e[0m'

# ==== Export CREDITS
CREDITS="${green} ـــــــــــــــﮩ٨ـ QuickTunnel ${NC}" 

# ==== Export Link Github 
GITHUB="https://raw.githubusercontent.com/Sandhj/QuickTunnel/main/"

# Running Banner
TEXT="QuickTunnel ـــــــــــــــﮩ٨ـ | Preparing . . . "
for (( i=0; i<${#TEXT}; i++ ))
do
    echo -n -e "${green}${TEXT:$i:1}${NC}"
    sleep 0.1 #Delay Antar Huruf
done
clear


# ==== Setup Input Domain
echo -e "┌───────────────────────────────────────────────────┐"
echo -e "│  Setup Your Domain For This Script | ${green}QuickTunnel${NC}  │"
echo -e "└───────────────────────────────────────────────────┘"
echo ""
read -p "Type Your Domain : " domain

mkdir -p /etc/xray/limitip/
echo $domain >> /root/domain
echo $domain >> /etc/xray/domain

$CREDITS
# ==== Perbaharui System
apt update -y && apt upgrade -y

$CREDITS
# ==== Install SSH & Xray
wget -q ${GITHUB}install/install-ssh.sh && bash install-ssh.sh
wget -q ${GITHUB}install/install-xray.sh && bash install-xray.sh
$CREDITS
# ==== Install Menu
wget -q ${GITHUB}install/install-menu.sh && bash install-menu.sh
$CREDITS
# ==== Install Vnstat
wget -q ${GITHUB}install/install-vnstat.sh && bash install-vnstat.sh
# ==== Install Limit IP Xray
cd /etc/xray/limitip
wget -q ${GITHUB}tools/check-ip-limit.sh
wget -q ${GITHUB}tools/clients_limit.conf
cd
$CREDITS
# ==== Install Auto Backup
wget -q ${GITHUB}tools/auto_backup.sh && bash auto_backup.sh

# ==== Memasang Default Menu saat Boot
cat> /root/.profile << END
# ~/.profile: executed by Bourne-compatible login shells.

if [ "$BASH" ]; then
  if [ -f ~/.bashrc ]; then
    . ~/.bashrc
  fi
fi

mesg n || true
clear
menu
END
chmod 644 /root/.profile

# ===== Pasang Cronjob limitIP
CRON_JOB="*/5 * * * * /bin/bash /etc/xray/check-ip-limit.sh"
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -

# ============== END SCRIPT==================
clear
echo""
TEXTEND="Script Already Installed On Your System" 
for (( i=0; i<${#TEXT2}; i++ ))
do
    echo -n -e "${green}${TEXTEND:$i:1}${NC}"
    sleep 0.1 #Delay Antar Huruf
done
sleep 2

echo ""
echo -e "┌─────────────────────────────────────┐"
echo -e "│ .::  DETAIL SCRIPT QUICKTUNNEL ::.  │"
echo -e "└─────────────────────────────────────┘"
echo -e "√ SERVICE :"
echo -e "   SSH WEBSOCKET "
echo -e "   XRAY VMESS WS & GRPC"
echo -e "   XRAY VLESS WS & GRPC"
echo -e "   XRAY TROJAN WS & GRPC"
echo -e "√ PORT : "
echo -e "   DROPBEAR      : 22, 109, 5000"
echo -e "   WEBSOCKET     : 80"
echo -e "   EBSOCKET TLS  : 443"
echo -e "   GRPC          : 443"
echo -e "└─────────────────────────────────────┘"

echo "Tekan Enter Untuk Menuju Menu Utama(↩️)"
read -s
menu
