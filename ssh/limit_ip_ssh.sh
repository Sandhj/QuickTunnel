#!/bin/bash

# Konfigurasi Bot Telegram
BOT_TOKEN="YOUR_BOT_TOKEN"
CHAT_ID="YOUR_CHAT_ID"

# Lokasi file konfigurasi client
CONFIG_FILE="/root/client_ssh.conf"

# Fungsi Kirim Notifikasi Telegram
send_telegram() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d text="$message" \
        -d parse_mode="html" > /dev/null
}

# Pastikan file config ada
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "❌ File konfigurasi tidak ditemukan: $CONFIG_FILE"
    exit 1
fi

# Ambil semua user SSH yang sedang login (dari who)
active_users=$(who | awk '{print $1, $5}' | sort)

# Simpan hasil dalam array untuk tiap user
declare -A user_ips

while IFS= read -r line; do
    if [[ "$line" =~ ^[a-zA-Z0-9_]+=[0-9]+$ ]]; then
        username=$(echo "$line" | cut -d'=' -f1)
        ip_limit=$(echo "$line" | cut -d'=' -f2)

        # Hitung jumlah IP aktif untuk user tersebut
        ip_count=0
        while IFS= read -r ip; do
            [[ -n "$ip" ]] && ((ip_count++))
        done < <(echo "$active_users" | awk '$1 == "'"$username"'" {print $2}' | sort -u)

        # Cek apakah melebihi limit
        if [[ "$ip_count" -gt "$ip_limit" ]]; then
            local_message="❗ NOTIFIKASI MELEBIHI LIMIT IP\n"
            local_message+="User : <b>$username</b>\n"
            local_message+="Jumlah IP : $ip_count (Limit: $ip_limit)\n"
            local_message+="IP Aktif:\n"

            while IFS= read -r ip; do
                [[ -n "$ip" ]] && local_message+="- $ip\n"
            done < <(echo "$active_users" | awk '$1 == "'"$username"'" {print $2}' | sort -u)

            send_telegram "$local_message"
        fi
    fi
done < "$CONFIG_FILE"

echo "✅ Pemeriksaan selesai."
