#!/bin/bash

echo "Pilih zona waktu Indonesia yang ingin Anda gunakan:"
echo "1. Asia/Jakarta (WIB)"
echo "2. Asia/Makassar (WITA)"
echo "3. Asia/Jayapura (WIT)"

read -p "Masukkan pilihan (1/2/3): " choice

case $choice in
    1)
        timezone="Asia/Jakarta"
        ;;
    2)
        timezone="Asia/Makassar"
        ;;
    3)
        timezone="Asia/Jayapura"
        ;;
    *)
        echo "Pilihan tidak valid."
        exit 1
        ;;
esac

# Backup symlink jika ada
if [ -f /etc/localtime ]; then
    sudo mv /etc/localtime /etc/localtime.bak
fi

# Set zona waktu baru
sudo ln -s /usr/share/zoneinfo/$timezone /etc/localtime

# Verifikasi
echo ""
echo "Zona waktu telah diatur ke: $timezone"
date
