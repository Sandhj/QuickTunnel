#!/bin/bash
CONFIG_FILE="/etc/xray/config.json"
today=$(date +%F)

cp "$CONFIG_FILE" "${CONFIG_FILE}.bak"

# Cari semua baris yang mengandung "expired": "YYYY-MM-DD"
grep -E '"expired":\s*"[0-9]{4}-[0-9]{2}-[0-9]{2}"' "$CONFIG_FILE" | while read -r line; do
  # Ekstrak tanggal expired
  expired_date=$(echo "$line" | sed -E 's/.*"([0-9]{4}-[0-9]{2}-[0-9]{2})".*/\1/')

  # Bandingkan tanggal
  if [[ "$expired_date" < "$today" ]]; then
    echo "Menghapus baris: $line"
    # Escape karakter khusus agar aman untuk dipakai di sed
    escaped_line=$(echo "$line" | sed 's/[&/\]/\\&/g')
    # Hapus baris dari file
    sed -i "\|$escaped_line|d" "$CONFIG_FILE"
  else
    echo "Tetap aktif: $expired_date"
  fi
done
