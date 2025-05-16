#!/bin/bash

# Export OS
# Ambil PRETTY_NAME dari /etc/os-release
OS_PRETTY=$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
# Expor IP
IP=$(curl -s ifconfig.me)
# Export Jumlah Akun
vmess=$(( $(grep -c '##' /etc/xray/config.json 2>/dev/null) / 2 ))
vless=$(( $(grep -c '#?' /etc/xray/config.json 2>/dev/null) / 2 ))
trojan=$(( $(grep -c '#!' /etc/xray/config.json 2>/dev/null) / 2 ))

echo -e "┌──────────────────────────────────────┐"
echo -e "│       =   INFORMASI SERVER  =        │"
echo -e "└──────────────────────────────────────┘"
echo -e " OS SYSTEM           : $OS_PRETTY "
echo -e " ISP                 : "
echo -e " REGION              : "
echo -e " IP                  : $IP"
echo -e " DOMAIN              : "
echo -e " RAM                 : "
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
