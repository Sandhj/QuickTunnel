#!/bin/bash
clear
# Definisi Warna
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color
echo -e "${BLUE}   ┌──────────────────────────────────────┐${NC}"
echo -e "${BLUE}   |      .::   MENU TOOLS MANAGER  ::.   │${NC}"
echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
echo -e "      1. Cert Domain              "
echo -e "      2. Change Domain                  "
echo -e "      3. Vnstat                  "
echo -e "      4. Status Service                   "
echo -e "      5. Reboot Server          "
echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
echo -e ""
read -p "Select Menu (0 To Back Menu) : " pilihan
# Memproses pilihan
case $pilihan in
    1)
        cert-domain.sh
        ;;
    2)
        change-domain.sh
        ;;
    3)
        vnstat
        ;;
    4)
        status-service.sh
        ;;
    5)
        reboot
        ;;
    0)
        menu
        ;;
    *)
        menu_lain.sh
        ;;
esac
