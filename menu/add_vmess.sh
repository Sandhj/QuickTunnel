#!/bin/bash
read -p "Masukkan Username :" user


CONFIG_FILE="/etc/xray/config.json"

# Generate UUID otomatis
NEW_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]')

# Tambahkan Client Ke Config.json
NEW_ENTRY='{"id": "'"$NEW_UUID"'", "alterId": 0, "email": "'"$user"'", "expired": "'"$exp"'"},'

# Escape karakter khusus untuk digunakan dalam perintah sed
ESCAPED_ENTRY=$(echo "$NEW_ENTRY" | sed 's/[&/\]/\\&/g')

# Sisipkan setelah baris yang mengandung "// VMESS" atau "// VMESS-GRPC"
sed -i "/\/\/ VMESS$/a $ESCAPED_ENTRY" "$CONFIG_FILE"
sed -i "/\/\/ VMESS-GRPC$/a $ESCAPED_ENTRY" "$CONFIG_FILE"

echo "Selesai: Entry telah ditambahkan dengan UUID: $NEW_UUID"

Systemctl restart xray
