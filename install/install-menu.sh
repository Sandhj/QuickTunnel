#!/bin/bash
# Hapus File Lama
rm -f /usr/bin/menu
rm -f /usr/bin/menu_bot.sh
rm -f /usr/bin/menu_lain.sh
rm -f /usr/bin/menu_ssh.sh
rm -f /usr/bin/menu_vmess.sh
rm -f /usr/bin/menu_vless.sh
rm -f /usr/bin/menu_trojan.sh
rm -f /usr/bin/add-vmess.sh
rm -f /usr/bin/delete-vmess.sh
rm -f /usr/bin/list-user-vmess.sh
rm -f /usr/bin/renew-vmess.sh
rm -f /usr/bin/trial-vmess.sh
rm -f /usr/bin/add-ssh.sh
rm -f /usr/bin/delete-ssh.sh
rm -f /usr/bin/list-user-ssh.sh
rm -f /usr/bin/renew-ssh.sh
rm -f /usr/bin/trial-ssh.sh
rm -f /usr/bin/add-vless.sh
rm -f /usr/bin/delete-vless.sh
rm -f /usr/bin/list-user-vless.sh
rm -f /usr/bin/renew-vless.sh
rm -f /usr/bin/trial-vless.sh
rm -f /usr/bin/add-trojan.sh
rm -f /usr/bin/delete-trojan.sh
rm -f /usr/bin/list-user-trojan.sh
rm -f /usr/bin/renew-trojan.sh
rm -f /usr/bin/trial-trojan.sh
rm -f /usr/bin/update-script.sh
rm -f /usr/bin/restar-service.sh
rm -f /usr/bin/change-domain.sh
rm -f /usr/bin/version

# Ambil File Baru
mkdir -p ~/menu
cd ~/menu || { echo "Gagal masuk ke direktori menu"; exit 1; }
URL="https://raw.githubusercontent.com/Sandhj/QuickTunnel/main/menu"
# Unduh semua file menu utama
wget -q "$URL/menu" && chmod +x menu
wget -q "$URL/menu_bot.sh" && chmod +x menu_bot.sh
wget -q "$URL/menu_lain.sh" && chmod +x menu_lain.sh
wget -q "$URL/menu_ssh.sh" && chmod +x menu_ssh.sh
wget -q "$URL/menu_vmess.sh" && chmod +x menu_vmess.sh
wget -q "$URL/menu_vless.sh" && chmod +x menu_vless.sh
wget -q "$URL/menu_trojan.sh" && chmod +x menu_trojan.sh

URL2="https://raw.githubusercontent.com/Sandhj/QuickTunnel/main"
# VMESS
wget -q "$URL2/manager-vmess/add-vmess.sh" && chmod +x add-vmess.sh
wget -q "$URL2/manager-vmess/delete-vmess.sh" && chmod +x delete-vmess.sh
wget -q "$URL2/manager-vmess/list-user-vmess.sh" && chmod +x list-user-vmess.sh
wget -q "$URL2/manager-vmess/renew-vmess.sh" && chmod +x renew-vmess.sh
wget -q "$URL2/manager-vmess/trial-vmess.sh" && chmod +x trial-vmess.sh

# SSH
wget -q "$URL2/manager-ssh/add-ssh.sh" && chmod +x add-ssh.sh
wget -q "$URL2/manager-ssh/delete-ssh.sh" && chmod +x delete-ssh.sh
wget -q "$URL2/manager-ssh/list-user-ssh.sh" && chmod +x list-user-ssh.sh
wget -q "$URL2/manager-ssh/renew-ssh.sh" && chmod +x renew-ssh.sh
wget -q "$URL2/manager-ssh/trial-ssh.sh" && chmod +x trial-ssh.sh

# VLESS
wget -q "$URL2/manager-vless/add-vless.sh" && chmod +x add-vless.sh
wget -q "$URL2/manager-vless/delete-vless.sh" && chmod +x delete-vless.sh
wget -q "$URL2/manager-vless/list-user-vless.sh" && chmod +x list-user-vless.sh
wget -q "$URL2/manager-vless/renew-vless.sh" && chmod +x renew-vless.sh
wget -q "$URL2/manager-vless/trial-vless.sh" && chmod +x trial-vless.sh

# TROJAN
wget -q "$URL2/manager-trojan/add-trojan.sh" && chmod +x add-trojan.sh
wget -q "$URL2/manager-trojan/delete-trojan.sh" && chmod +x delete-trojan.sh
wget -q "$URL2/manager-trojan/list-user-trojan.sh" && chmod +x list-user-trojan.sh
wget -q "$URL2/manager-trojan/renew-trojan.sh" && chmod +x renew-trojan.sh
wget -q "$URL2/manager-trojan/trial-trojan.sh" && chmod +x trial-trojan.sh

# Install Tools
URL3="https://raw.githubusercontent.com/Sandhj/QuickTunnel/main"

wget -q "$URL3/tools/update-script.sh" && chmod +x update-script.sh
wget -q "$URL3/tools/restar-service.sh" && chmod +x restar-service.sh
wget -q "$URL3/tools/change-domain.sh" && chmod +x change-domain.sh
wget -q "$URL3/version"

# Pindahkan semua file dari ~/menu ke /usr/bin/
sudo mv -f ~/menu/version /etc/xray/
sudo mv -f ~/menu/* /usr/bin/

# Hapus direktori menu setelah pemindahan
rm -rf ~/menu
