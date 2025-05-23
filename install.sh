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
TEXT="QuickTunnel ـــــــــــــــﮩ٨ـ | Preparing . . . | Thanks To San (Owner)"
for (( i=0; i<${#TEXT}; i++ ))
do
    echo -n -e "${green}${TEXT:$i:1}${NC}"
    sleep 0.1 #Delay Antar Huruf
done
echo""
TEXT2="Contac The Owner If You Have Anything Problem. Lets Start in 2 Second"
for (( i=0; i<${#TEXT2}; i++ ))
do
    echo -n -e "${green}${TEXT2:$i:1}${NC}"
    sleep 0.1 #Delay Antar Huruf
done
sleep 2
clear


# ==== Setup Input Domain
echo -e "┌───────────────────────────────────────────────────┐"
echo -e "│  Setup Your Domain For This Script | ${green}QuickTunnel${NC}  │"
echo -e "└───────────────────────────────────────────────────┘"
echo ""
read -p "Type Your Domain : " domain

echo $domain >> /root/domain

# ==== Perbaharui System
apt update -y && apt upgrade -y

# ==== Install SSH & Xray
wget -q ${GITHUB}install/install-ssh.sh && bash install-ssh.sh
wget -q ${GITHUB}install/install-xray.sh && bash install-xray.sh

# ==== Install Menu
wget -q ${GITHUB}install/install-menu.sh && bash install-xray.sh

# ==== Install Vnstat
wget -q ${GITHUB}install/install-vnstat.sh && bash install-vnstat.sh
