#!/bin/bash

# Variabel
URL="https://raw.githubusercontent.com/Sandhj/QuickTunnel/main/bot/san.zip"
TARGET_DIR="/opt/botmanager"
ZIP_FILE="/tmp/san.zip"

# Membuat direktori target jika belum ada
echo "[+] Membuat direktori $TARGET_DIR jika belum ada..."
sudo mkdir -p "$TARGET_DIR"

# Download file zip
echo "[+] Mengunduh file ZIP..."
wget -q -O "$ZIP_FILE" "$URL"

# Ekstrak file zip ke direktori sementara
TMP_DIR="/tmp/san_extract"
mkdir -p "$TMP_DIR"
echo "[+] Mengekstrak file..."
unzip "$ZIP_FILE" -d "$TMP_DIR"

# Pindahkan menu.py
echo "[+] Memindahkan menu.py..."
sudo mv "$TMP_DIR/menu.py" "$TARGET_DIR/"

# Pindahkan isi folder lain
for folder in LAIN SSH VMESS VLESS TROJAN; do
    if [ -d "$TMP_DIR/$folder" ]; then
        echo "[+] Memindahkan isi folder $folder..."
        sudo mv "$TMP_DIR/$folder"/* "$TARGET_DIR/"
    else
        echo "[-] Folder $folder tidak ditemukan dalam arsip ZIP."
    fi
done

# Hapus file dan direktori sementara
rm -rf "$TMP_DIR" "$ZIP_FILE"

# Minta input dari pengguna
read -p "Masukkan token : " new_token
read -p "Masukkan chatID : " new_chatid
read -p "Perintah Identitas (contoh : server1) : " NEW_NAME

# Ganti nilai di file Python dengan perlindungan karakter khusus
sed -i 's/^bot_token\s*=\s*".*"/bot_token = "'"$new_token"'"/' /opt/autobackup/auto.py
sed -i 's/^chat_id\s*=\s*".*"/chat_id = "'"$new_chatid"'"/' /opt/autobackup/auto.py
sed -i "s/NAME_SERVER/${NEW_NAME}/" /opt/autobackup/auto.py

echo $new_token >> /etc/xray/token
echo $new_chatid >> /etc/xray/chatid

systemctl restart auto

echo " ✅ Autobackup Berhasil di Pasang. . .!"

echo "Tekan Enter Untuk Menuju Menu Utama(↩️)"
read -s
menu
