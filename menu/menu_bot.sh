#!/bin/bash
clear
# Definisi Warna
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color
echo -e "${BLUE}   ┌──────────────────────────────────────┐${NC}"
echo -e "${BLUE}   |      .::   MENU BOT MANAGER  ::.     │${NC}"
echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
echo -e "      1. Instal Autobackup             "
echo -e "      2. Install Bot Manager Admin                 "
echo -e "${BLUE}   └──────────────────────────────────────┘${NC}"
echo -e ""
read -p "Select Menu (0 To Back Menu) : " pilihan
# Memproses pilihan
case $pilihan in
    1)
        wget -q https://raw.githubusercontent.com/GeKaStore/QuickTunnel/main/install/install-autobackup.sh && bash install-autobackup.sh
        ;;
    2)
        wget -q https://raw.githubusercontent.com/GeKaStore/QuickTunnel/main/install/install-bot-manager.sh && bash install-bot-manager.sh
        ;;
    0)
        menu
        ;;
    *)
        menu_bot.sh
        ;;
esac
