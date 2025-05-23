#!/bin/bash
clear
# Definisi Warna
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color
echo -e "${BLUE}   ┌──────────────────────────────────────┐${NC}"
echo -e "${BLUE}   |      .::   MENU VMESS MANAGER  ::.   │${NC}"
echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
echo -e "      1. Create New Account              "
echo -e "      2. Renew Account                   "
echo -e "      3. Delete Account                  "
echo -e "      4. List Account                    "
echo -e "      5. Cek Login                       "
echo -e "      6. Trial Account 1 Hari          "
echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
echo -e ""
read -p "Select Menu (0 To Back Menu) : " pilihan
# Memproses pilihan
case $pilihan in
    1)
        ./add-vmess.sh
        ;;
    2)
        ./renew-vmess.sh
        ;;
    3)
        ./delete-vmess.sh
        ;;
    4)
        ./list-user-vmess
        ;;
    5)
        ./trial-vmess
        ;;
    0)
        ./menu.sh
        ;;
    *)
        ./menu_vmess
        ;;
esac
