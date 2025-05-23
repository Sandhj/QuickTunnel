#!/bin/bash

URL="https://raw.githubusercontent.com/Sandhj/QuickTunnel/main/menu"

sudo wget -q -O /usr/bin/menu.sh "$URL/menu.sh" && sudo chmod +x /usr/bin/menu.sh
sudo wget -q -O /usr/bin/menu_bot.sh "$URL/menu_bot.sh" && sudo chmod +x /usr/bin/menu_bot.sh
sudo wget -q -O /usr/bin/menu_lain.sh "$URL/menu_lain.sh" && sudo chmod +x /usr/bin/menu_lain.sh
sudo wget -q -O /usr/bin/menu_ssh.sh "$URL/menu_ssh.sh" && sudo chmod +x /usr/bin/menu_ssh.sh
sudo wget -q -O /usr/bin/menu_vmess.sh "$URL/menu_vmess.sh" && sudo chmod +x /usr/bin/menu_vmess.sh
sudo wget -q -O /usr/bin/menu_vless.sh "$URL/menu_vless.sh" && sudo chmod +x /usr/bin/menu_vless.sh
sudo wget -q -O /usr/bin/menu_trojan.sh "$URL/menu_trojan.sh" && sudo chmod +x /usr/bin/menu_trojan.sh


URL2="https://raw.githubusercontent.com/Sandhj/QuickTunnel/main"

# VMESS
sudo wget -q -O /usr/bin/add-vmess.sh "$URL2/manager-vmess/add-vmess.sh" && sudo chmod +x /usr/bin/add-vmess.sh
sudo wget -q -O /usr/bin/delete-vmess.sh "$URL2/manager-vmess/delete-vmess.sh" && sudo chmod +x /usr/bin/delete-vmess.sh
sudo wget -q -O /usr/bin/list-user-vmess.sh "$URL2/manager-vmess/list-user-vmess.sh" && sudo chmod +x /usr/bin/list-user-vmess.sh
sudo wget -q -O /usr/bin/renew-vmess.sh "$URL2/manager-vmess/renew-vmess.sh" && sudo chmod +x /usr/bin/renew-vmess.sh

# SSH
sudo wget -q -O /usr/bin/add-ssh.sh "$URL2/manager-ssh/add-ssh.sh" && sudo chmod +x /usr/bin/add-ssh.sh
sudo wget -q -O /usr/bin/delete-ssh.sh "$URL2/manager-ssh/delete-ssh.sh" && sudo chmod +x /usr/bin/delete-ssh.sh
sudo wget -q -O /usr/bin/list-user-ssh.sh "$URL2/manager-ssh/list-user-ssh.sh" && sudo chmod +x /usr/bin/list-user-ssh.sh
sudo wget -q -O /usr/bin/renew-ssh.sh "$URL2/manager-ssh/renew-ssh.sh" && sudo chmod +x /usr/bin/renew-ssh.sh

# VLESS
sudo wget -q -O /usr/bin/add-vless.sh "$URL2/manager-vless/add-vless.sh" && sudo chmod +x /usr/bin/add-vless.sh
sudo wget -q -O /usr/bin/delete-vless.sh "$URL2/manager-vless/delete-vless.sh" && sudo chmod +x /usr/bin/delete-vless.sh
sudo wget -q -O /usr/bin/list-user-vless.sh "$URL2/manager-vless/list-user-vless.sh" && sudo chmod +x /usr/bin/list-user-vless.sh
sudo wget -q -O /usr/bin/renew-vless.sh "$URL2/manager-vless/renew-vless.sh" && sudo chmod +x /usr/bin/renew-vless.sh

# TROJAN
sudo wget -q -O /usr/bin/add-trojan.sh "$URL2/manager-trojan/add-trojan.sh" && sudo chmod +x /usr/bin/add-trojan.sh
sudo wget -q -O /usr/bin/delete-trojan.sh "$URL2/manager-trojan/delete-trojan.sh" && sudo chmod +x /usr/bin/delete-trojan.sh
sudo wget -q -O /usr/bin/list-user-trojan.sh "$URL2/manager-trojan/list-user-trojan.sh" && sudo chmod +x /usr/bin/list-user-trojan.sh
sudo wget -q -O /usr/bin/renew-trojan.sh "$URL2/manager-trojan/renew-trojan.sh" && sudo chmod +x /usr/bin/renew-trojan.sh
