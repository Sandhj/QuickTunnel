#!/bin/bash
clear
# Definisi Warna
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color
echo -e "${BLUE}   ┌──────────────────────────────────────┐${NC}"
echo -e "${BLUE}   |      .::   MENU SSH MANAGER  ::.     │${NC}"
echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
echo -e "      1. Create New Account              "
echo -e "      2. Renew Account                   "
echo -e "      3. Delete Account                  "
echo -e "      4. List Account                    "
echo -e "      5. Cek Login                       "
echo -e "      6. Trial Account 60 Menit          "
echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
echo -e ""
read -p "Select Menu : " pilihan
# Memproses pilihan
case $pilihan in
    1)
        ./create_ssh.sh
        ;;
    2)
        ./renew_ssh.sh
        ;;
    3)
        ./delete_ssh.sh
        ;;
    4)
        ./list_ssh
        ;;
    5)
        ./cek_login_ssh
        ;;
    6)
        ./trial_ssh
        ;;
    *)
        ./menu_ssh
        ;;
esac
