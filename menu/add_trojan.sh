#!/bin/bash

read -p "Masukkan Username :" user
read -p "Masukkan jumlah hari: " jumlah_hari

# Memastikan input adalah angka positif
if ! [[ "$jumlah_hari" =~ ^[0-9]+$ ]]; then
  echo "Input harus berupa angka positif."
  exit 1
fi

CONFIG_FILE="/etc/xray/config.json"
NEW_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]')
tanggal_sekarang=$(date +"%Y-%m-%d")
exp=$(date -d "$tanggal_sekarang + $jumlah_hari days" +"%Y-%m-%d")
NEW_ENTRY='{"password": "'"$NEW_UUID"'", "email": "'"$user"'"},'
COMMENT_LINE="#! $user $exp"
ESCAPED_ENTRY=$(echo "$COMMENT_LINE\n$NEW_ENTRY" | sed 's/[&/\]/\\&/g')

# Sisipkan setelah baris yang mengandung "// VMESS" atau "// VMESS-GRPC"
sed -i "/\/\/ TROJAN$/a $COMMENT_LINE\n$NEW_ENTRY" "$CONFIG_FILE"
sed -i "/\/\/ TROJAN-GRPC$/a $COMMENT_LINE\n$NEW_ENTRY" "$CONFIG_FILE"

systemctl restart xray
