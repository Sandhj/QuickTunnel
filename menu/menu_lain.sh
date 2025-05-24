#!/bin/bash
clear
# Definisi Warna
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color
echo -e "${BLUE}   ┌──────────────────────────────────────┐${NC}"
echo -e "${BLUE}   |      .::   MENU TOOLS MANAGER  ::.   │${NC}"
echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
echo -e "      1. Update Script          "
echo -e "      2. Status Service         "
echo -e "      3. Restart Service        "
echo -e "      4. Change Domain          "
echo -e "      5. Update Domain          "
echo -e "      6. Banner SSH             "
echo -e "      7. Reboot Server          "
echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
echo -e ""
read -p "Select Menu (0 To Back Menu) : " pilihan
# Memproses pilihan
case $pilihan in
    1)
        install-menu.sh
        ;;
    2)
        status-service.sh
        ;;
    3)
        restart-service.sh
        ;;
    4)
        change-domain.sh
        ;;
    5)
        cert-domain.sh
        ;;
    6)
        nano /etc/issue.net
        ;;
    7)
        reboot
        ;;
    0)
        menu
        ;;
    *)
        menu_lain.sh
        ;;
esac
