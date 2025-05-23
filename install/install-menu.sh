#!/bin/bash

URL="https://raw.githubusercontent.com/Sandhj/QuickTunnel/main/menu"

sudo wget -q -O /usr/bin/menu.sh "$URL/menu.sh" && sudo chmod +x /usr/bin/menu.sh
sudo wget -q -O /usr/bin/menu_bot.sh "$URL/menu_bot.sh" && sudo chmod +x /usr/bin/menu_bot.sh
sudo wget -q -O /usr/bin/menu_lain.sh "$URL/menu_lain.sh" && sudo chmod +x /usr/bin/menu_lain.sh
sudo wget -q -O /usr/bin/menu_ssh.sh "$URL/menu_ssh.sh" && sudo chmod +x /usr/bin/menu_ssh.sh
sudo wget -q -O /usr/bin/menu_vmess.sh "$URL/menu_vmess.sh" && sudo chmod +x /usr/bin/menu_vmess.sh
sudo wget -q -O /usr/bin/menu_vless.sh "$URL/menu_vless.sh" && sudo chmod +x /usr/bin/menu_vless.sh
sudo wget -q -O /usr/bin/menu_trojan.sh "$URL/menu_trojan.sh" && sudo chmod +x /usr/bin/menu_trojan.sh
