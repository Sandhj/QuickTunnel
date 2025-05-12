#!/bin/bash
read -p "Masukkan Username :" user
read -p "Masukkan jumlah hari: " jumlah_hari

# Memastikan input adalah angka positif
if ! [[ "$jumlah_hari" =~ ^[0-9]+$ ]]; then
  echo "Input harus berupa angka positif."
  exit 1
fi

# Menghitung tanggal mendatang menggunakan date
tanggal_sekarang=$(date +"%Y-%m-%d")
exp=$(date -d "$tanggal_sekarang + $jumlah_hari days" +"%Y-%m-%d")

CONFIG_FILE="/etc/xray/config.json"

# Generate UUID otomatis
NEW_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]')

# Tambahkan Client Ke Config.json
NEW_ENTRY='{"id": "'"$NEW_UUID"'", "alterId": 0, "email": "'"$user"'", "expired": "'"$exp"'", "kode": "##"},'

# Escape karakter khusus untuk digunakan dalam perintah sed
ESCAPED_ENTRY=$(echo "$NEW_ENTRY" | sed 's/[&/\]/\\&/g')

# Sisipkan setelah baris yang mengandung "// VMESS" atau "// VMESS-GRPC"
sed -i "/\/\/ VMESS$/a $ESCAPED_ENTRY" "$CONFIG_FILE"
sed -i "/\/\/ VMESS-GRPC$/a $ESCAPED_ENTRY" "$CONFIG_FILE"

echo "Selesai: Entry telah ditambahkan dengan UUID: $NEW_UUID"

systemctl restart xray
