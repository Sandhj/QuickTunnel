#!/bin/bash
clear

# Definisi Warna
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Export Informasi Server
OS_PRETTY=$(grep -E '^PRETTY_NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
IP=$(curl -s ifconfig.me)
ISP=$(curl -s "http://ip-api.com/json/" | jq -r '.isp')
country=$(curl -s "http://ip-api.com/json/" | jq -r '.country')
domain=$(cat /etc/xray/domain)

# Export Jumlah Akun
vmess=$(( $(grep -c '##' /etc/xray/config.json 2>/dev/null) / 2 ))
vless=$(( $(grep -c '#?' /etc/xray/config.json 2>/dev/null) / 2 ))
trojan=$(( $(grep -c '#!' /etc/xray/config.json 2>/dev/null) / 2 ))
ssh="$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd | wc -l)"

echo -e "${BLUE}   ┌──────────────────────────────────────┐${NC}"
echo -e "${BLUE}   │       =   INFORMASI SERVER  =        │${NC}"
echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
echo -e "    OS SYSTEM           : ${YELLOW}$OS_PRETTY${NC}"
echo -e "    ISP                 : ${YELLOW}$ISP${NC}"
echo -e "    REGION              : ${YELLOW}$country${NC}"
echo -e "    IP                  : ${YELLOW}$IP${NC}"
echo -e "    DOMAIN              : ${YELLOW}$domain${NC}"
echo -e "${BLUE}   ┌──────────────────────────────────────┐${NC}"
echo -e "${BLUE}   │ SERVICE            | JUMLAH USER     │${NC}"
echo -e "${BLUE}   ├────────────────────┼─────────────────┤${NC}"
printf "   │ %-18s │ %15d │\n" "SSH" "$ssh"
printf "   │ %-18s │ %15d │\n" "VMess" "$vmess"
printf "   │ %-18s │ %15d │\n" "VLESS" "$vless"
printf "   │ %-18s │ %15d │\n" "TROJAN" "$trojan"
echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
echo -e "${YELLOW}   ┌──────────────────────────────────────┐${NC}"
echo -e "${YELLOW}   │            = MENU UTAMA =            │${NC}"
echo -e "${YELLOW}   └──────────────────────────────────────┘${NC}"
echo -e "     ${YELLOW}1. SSH MANAGER      5. BOT MANAGER   ${NC}"
echo -e "     ${YELLOW}2. VMESS MANAGER    6. CHANGE DOMAIN ${NC}"
echo -e "     ${YELLOW}3. VLESS MANAGER    7. RESTART SERV. ${NC}"
echo -e "     ${YELLOW}4. TROJAN MANAGER   8. MENU LAIN ${NC}"
echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
echo -e ""
read -p "Select Menu : " pilihan

# Memproses pilihan
case $pilihan in
    1)
        menu_ssh.sh
        ;;
    2)
        menu_vmess.sh
        ;;
    3)
        menu_vless.sh
        ;;
    4)
        menu_trojan.sh
        ;;
    5)
        menu_bot.sh
        ;;
    6)
        change_domain.sh
        ;;
    7)
        restart_service.sh
        ;;
    8)
        menu_lain.sh
        ;;
    *)
        menu.sh
        ;;
esac
