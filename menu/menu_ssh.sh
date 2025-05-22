#!/bin/bash
clear

# Definisi Warna
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}   ┌──────────────────────────────────────┐${NC}"
echo -e "${BLUE}   │       .::   MENU SSH MANAGER  ::.        │${NC}"
echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
echo -e "    1. Create New Account         "
echo -e "    2. Renew Account"
echo -e "    3. Delete Account       "
echo -e "    4. List Account                "
echo -e "    5. Cek Login          "
echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
echo -e ""
read -p "Select Menu : " pilihan

# Memproses pilihan
case $pilihan in
    1)
        ./menu_ssh
        ;;
    2)
        ./menu_vmess
        ;;
    3)
        ./menu_vless
        ;;
    4)
        ./menu_trojan
        ;;
    5)
        ./menu_bot
        ;;
    6)
        ./change_domain
        ;;
    7)
        ./restart_service
        ;;
    8)
        ./menu_lain
        ;;
    *)
        ./menu
        ;;
esac
