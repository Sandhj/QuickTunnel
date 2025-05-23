#!/bin/bash
# Direktori tempat file berada
DIR="/usr/bin"

# Daftar file yang akan dihapus
FILES=(
    "menu"
    "menu_bot.sh"
    "menu_lain.sh"
    "menu_ssh.sh"
    "menu_vmess.sh"
    "menu_vless.sh"
    "menu_trojan.sh"
    "add-vmess.sh"
    "delete-vmess.sh"
    "list-user-vmess.sh"
    "renew-vmess.sh"
    "trial-vmess.sh"
    "add-ssh.sh"
    "delete-ssh.sh"
    "list-user-ssh.sh"
    "renew-ssh.sh"
    "trial-ssh.sh"
    "add-vless.sh"
    "delete-vless.sh"
    "list-user-vless.sh"
    "renew-vless.sh"
    "trial-vless.sh"
    "add-trojan.sh"
    "delete-trojan.sh"
    "list-user-trojan.sh"
    "renew-trojan.sh"
    "trial-trojan.sh"
)

# Loop dan hapus setiap file, arahkan output ke /dev/null untuk menyembunyikannya
for FILE in "${FILES[@]}"; do
    if [ -f "$DIR/$FILE" ]; then
        echo "[INFO] Menghapus: $DIR/$FILE"
        sudo rm -f "$DIR/$FILE" > /dev/null 2>&1
    else
        echo "Tidak ada yang perlu di hapus"
    fi
done


# Buat dan masuk ke direktori "menu"
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

# Pindahkan semua file dari ~/menu ke /usr/bin/
sudo mv -f ~/menu/* /usr/bin/

# Hapus direktori menu setelah pemindahan
rm -rf ~/menu
