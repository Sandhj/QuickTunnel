#!/bin/bash

# Export Informasi Server
OS_PRETTY=$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
IP=$(curl -s ifconfig.me)
ISP=$(curl -s "http://ip-api.com/json/" | jq -r '.isp')
country=$(curl -s "http://ip-api.com/json/" | jq -r '.country')
domain=(cat /etc/xray/domain)

# Export Jumlah Akun
vmess=$(( $(grep -c '##' /etc/xray/config.json 2>/dev/null) / 2 ))
vless=$(( $(grep -c '#?' /etc/xray/config.json 2>/dev/null) / 2 ))
trojan=$(( $(grep -c '#!' /etc/xray/config.json 2>/dev/null) / 2 ))

echo -e "┌──────────────────────────────────────┐"
echo -e "│       =   INFORMASI SERVER  =        │"
echo -e "└──────────────────────────────────────┘"
echo -e " OS SYSTEM           : $OS_PRETTY "
echo -e " ISP                 : $ISP"
echo -e " REGION              : $country"
echo -e " IP                  : $IP"
echo -e " DOMAIN              : $domian"
echo -e "┌──────────────────────────────────────┐"
echo -e "│ SERVICE            | JUMLAH USER     │"
echo -e "├────────────────────┼─────────────────┤"
printf "│ %-18s │ %15d │\n" "SSH" "$ssh"
printf "│ %-18s │ %15d │\n" "VMess" "$vmess"
printf "│ %-18s │ %15d │\n" "VLESS" "$vless"
printf "│ %-18s │ %15d │\n" "TROJAN" "$trojan"
echo -e "└──────────────────────────────────────┘"
echo -e "┌──────────────────────────────────────┐"
echo -e "│            = MENU UTAMA =            │"
echo -e "└──────────────────────────────────────┘"
echo -e "  1. SSH MANAGER      5. BOT MANAGER    "
echo -e "  2. VMESS MANAGER    6. CHANGE DOMAIN"
echo -e "  3. VLESS MANAGER    7. RESTART SERV.  "
echo -e "  4. TROJAN MANAGER   8. REBOOT SERVER  "
echo -e "└──────────────────────────────────────┘"
