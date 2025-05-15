#!/bin/bash

clear
# ==== Export Warna
green='\e[0;32m'
NC='\e[0m'

# ==== Export CREDITS
CREDITS="${green} ـــــــــــــــﮩ٨ـ QuickTunnel ${NC}" 

# ==== Setup Input Domain
echo -e "┌───────────────────────────────────────────────────┐"
echo -e "│  Setup Your Domain For This Script | ${green}QuickTunnel${NC}  │"
echo -e "└───────────────────────────────────────────────────┘"
echo ""
read -p "Type Your Domain : " domain

echo $domain >> /root/domain


