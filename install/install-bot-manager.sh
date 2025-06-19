#!/bin/bash

# Minta input dari pengguna
read -p "Masukkan Token : " NEW_TOKEN
read -p "Masukkan ChatID : " NEW_CHAT_ID 
read -p "Masukkan Perintah Menu ( Contoh : menu ): "NEW_COMMAND

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

sed -i "s/TOKEN = 'token_tele'/TOKEN = '$NEW_TOKEN'/" /opt/botmanager/menu.py
sed -i "s/AUTHORIZED_CHAT_ID = chat_id/AUTHORIZED_CHAT_ID = $NEW_CHAT_ID/" /opt/botmanager/menu.py
sed -i "s/\['NAMA_SERVER'\]/\['$NEW_COMMAND'\]/" /opt/botmanager/menu.py

echo " ✅ Autobackup Berhasil di Pasang. . .!"

echo "Tekan Enter Untuk Menuju Menu Utama(↩️)"
read -s
menu
