#!/bin/bash

read -p "Masukkan Username : " user
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
NEW_ENTRY='{"id": "'"$NEW_UUID"'", "email": "'"$user"'"},'
COMMENT_LINE="#? $user $exp"
ESCAPED_ENTRY=$(echo "$COMMENT_LINE\n$NEW_ENTRY" | sed 's/[&/\]/\\&/g')

# Sisipkan setelah baris yang mengandung "// VMESS" atau "// VMESS-GRPC"
sed -i "/\/\/ VLESS$/a $COMMENT_LINE\n$NEW_ENTRY" "$CONFIG_FILE"
sed -i "/\/\/ VLESS-GRPC$/a $COMMENT_LINE\n$NEW_ENTRY" "$CONFIG_FILE"

# === Create Link Vmess
HOST=$(cat /etc/xray/domain)

# Buat remark
remark_tls="${user}-TLS"
remark_ws="${user}-WS"
remark_grpc="${user}-gRPC"

# --- Buat 3 jenis link ---
link_tls="vless://${NEW_UUID}@${HOST}:443?path=/vless&security=tls&encryption=none&type=ws#${remark_tls}"
link_ws="vless://${NEW_UUID}@${HOST}:80?path=/vless&security=none&encryption=none&type=ws#${remark_ws}"
link_grpc="vless://${NEW_UUID}@${HOST}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=/vless-grpc#${remark_grpc}"

clear
# Tampilkan hasil
echo "✅ Account VLess Berhasil Dibuat"
echo "Username: $user"
echo "Expired: $exp"
echo "-----------------------------------------------"
echo "UUID: $NEW_UUID"
echo "Host: $HOST"
echo "-----------------------------------------------"
echo "1. WebSocket + TLS (Port 443)"
echo "$link_tls"
echo
echo "2. WebSocket (tanpa TLS, Port 80)"
echo "$link_ws"
echo
echo "3. gRPC (Port 443)"
echo "$link_grpc"
echo "-----------------------------------------------"

systemctl restart xray
