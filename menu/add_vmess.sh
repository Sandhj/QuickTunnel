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
NEW_ENTRY='{"id": "'"$NEW_UUID"'", "alterId": 0, "email": "'"$user"'"},'
COMMENT_LINE="## $user $exp"
ESCAPED_ENTRY=$(echo "$COMMENT_LINE\n$NEW_ENTRY" | sed 's/[&/\]/\\&/g')

# Sisipkan setelah baris yang mengandung "// VMESS" atau "// VMESS-GRPC"
sed -i "/\/\/ VMESS$/a $COMMENT_LINE\n$NEW_ENTRY" "$CONFIG_FILE"
sed -i "/\/\/ VMESS-GRPC$/a $COMMENT_LINE\n$NEW_ENTRY" "$CONFIG_FILE"

# ==== Fungsi Create Link
UUID=$(cat /proc/sys/kernel/random/uuid)
HOST=$(cat /root/xray/domain)

# Fungsi buat JSON VMess
build_vmess() {
    local proto="$1"
    local json="$2"
    echo "$json" | jq -c . | base64 | tr -d '\n'
}

# --- Buat 3 jenis link ---
link_tls=$(build_vmess "TLS" '{
  "v": "2",
  "ps": "'"${user}-TLS"'",
  "add": "'"${HOST}"'",
  "port": "443",
  "id": "'"${UUID}"'",
  "aid": "0",
  "net": "ws",
  "type": "none",
  "host": "'"${HOST}"'",
  "path": "/vmess",
  "tls": "tls"
}')

link_ws=$(build_vmess "WS" '{
  "v": "2",
  "ps": "'"${user}-WS"'",
  "add": "'"${HOST}"'",
  "port": "80",
  "id": "'"${UUID}"'",
  "aid": "0",
  "net": "ws",
  "type": "none",
  "host": "'"${HOST}"'",
  "path": "/vmess",
  "tls": ""
}')

link_grpc=$(build_vmess "gRPC" '{
  "v": "2",
  "ps": "'"${user}-gRPC"'",
  "add": "'"${HOST}"'",
  "port": "443",
  "id": "'"${UUID}"'",
  "aid": "0",
  "net": "grpc",
  "type": "gun",
  "host": "'"${HOST}"'",
  "path": "/vmess-grpc",
  "tls": "tls"
}')

# Tampilkan hasil
echo "✅ VMess Account Berhasil Dibuat"
echo " Username: $USERNAME"
echo " Expired : $jumlah_hari"
echo "-----------------------------------------------"
echo "UUID: $UUID"
echo "Host: $HOST"
echo "-----------------------------------------------"
echo "1. WebSocket + TLS (Port 443)"
echo "vmess://$link_tls"
echo
echo "2. WebSocket (tanpa TLS, Port 80)"
echo "vmess://$link_ws"
echo
echo "3. gRPC (Port 443)"
echo "vmess://$link_grpc"
echo "-----------------------------------------------"

systemctl restart xray
