# ==== Link Github
GITHUB="wget -q https://raw.githubusercontent.com/Sandhj/QuickTunnel/main"

# ==== Buat Direktori dan masuk
mkdir -p update
cd update

# SSH
${GITHUB}/manager-ssh/trial-ssh.sh
${GITHUB}/manager-ssh/renew-ssh.sh
${GITHUB}/manager-ssh/list-user-ssh.sh
${GITHUB}/manager-ssh/add-ssh.sh
${GITHUB}/manager-ssh/delete-ssh.sh

# TROJAN
${GITHUB}/manager-trojan/trial-trojan.sh
${GITHUB}/manager-trojan/renew-trojan.sh
${GITHUB}/manager-trojan/list-user-trojan.sh
${GITHUB}/manager-trojan/delete-trojan.sh
${GITHUB}/manager-trojan/add-trojan.sh

# VLESS
${GITHUB}/manager-vless/trial-vless.sh
${GITHUB}/manager-vless/renew-vless.sh
${GITHUB}/manager-vless/ist-user-vless.sh
${GITHUB}/manager-vless/delete-vless.sh
${GITHUB}/manager-vless/add-vless.sh

# VMESS
${GITHUB}/manager-vmess/trial-vmess.sh
${GITHUB}/manager-vmess/renew-vmess.sh
${GITHUB}/manager-vmess/list-user-vmess.sh
${GITHUB}/manager-vmess/elete-vmess.sh
${GITHUB}/manager-vmess/add-vmess.sh

# MENU
${GITHUB}/menu/menu
${GITHUB}/menu/menu_ssh.sh
${GITHUB}/menu/menu_vmess.sh
${GITHUB}/menu/menu_vless.sh
${GITHUB}/menu/menu_trojan.sh
${GITHUB}/menu/menu_lain.sh
${GITHUB}/menu/menu_bot.sh

# TOOLS
${GITHUB}/tools/update-script.sh
${GITHUB}/tools/restart-service.sh
${GITHUB}/tools/expired.sh
${GITHUB}/tools/change-domain.sh

# ==== BERI ISIN AKSES DAN KELUAR 
chmod +x *
mv * /usr/bin/
cd


# ==== UPDATE INFORMASI VERSION 
cd /etc/xray/
${GITHUB}/version
cd

rm -rf update
