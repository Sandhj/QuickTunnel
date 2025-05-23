#!/bin/bash

BOT_TOKEN=(cat /root/token)
CHAT_ID=(cat /root/chatid)

cat <<EOL > /etc/xray/limitip.sh
#!/bin/bash

# Konfigurasi
LOG_FILE="/var/log/xray/access.log"            # Ganti dengan path access.log Anda
CLIENT_CONFIG="clients_limit.conf"
TIME_WINDOW_MINUTES=60                   # Cek dalam X menit terakhir
SESSION_DURATION_MINUTES=5               # Asumsikan tiap sesi aktif selama X menit

# Konfigurasi Telegram Bot
TELEGRAM_BOT_TOKEN="$BOT_TOKEN"  # Ganti dengan token bot Anda
TELEGRAM_CHAT_ID="$CHAT_ID"             # Ganti dengan chat ID tujuan

# Fungsi kirim notifikasi ke Telegram
send_telegram_alert() {
    local message="$1"
    curl -s -X POST https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage \
        -d chat_id=$TELEGRAM_CHAT_ID \
        -d text="$message" \
        -d parse_mode="html" > /dev/null
}

# Fungsi cek overlap IP aktif bersamaan
check_overlap() {
    local email="$1"

    grep "$email" "$LOG_FILE" | awk '
    {
        log_date = substr($0, 1, 19);
        cmd = "date -d \"" log_date "\" +%s";
        cmd | getline ts;
        close(cmd);
        ip = $4;
        split(ip, a, ":");
        print ts, a[1];
    }' | awk -v duration="${SESSION_DURATION_MINUTES}" '
    {
        timestamp[$1] = $2;
        times[i++] = $1;
    }
    END {
        max_overlap = 0;
        for (t in times) {
            current = times[t];
            delete unique;
            for (s in times) {
                if (times[s] >= current - duration*60 && times[s] <= current + duration*60) {
                    unique[$2] = 1;
                }
            }
            count = length(unique);
            if (count > max_overlap) {
                max_overlap = count;
            }
        }
        print max_overlap;
    }'
}

# Baca konfigurasi client dan lakukan pengecekan
while IFS='=' read -r email limit; do
    if [[ "$email" == \#* || -z "$email" ]]; then
        continue
    fi

    overlap=$(check_overlap "$email")

    if (( overlap > limit )); then
        msg="🔴 <b>Pelanggaran Batas Device</b>\n"
        msg+="Username: <code>$email</code>\n"
        msg+="Batas IP: $limit\n"
        msg+="IP Aktif Bersamaan: $overlap\n"
        msg+="Status: ⚠️ Melebihi batas!"

        echo "$msg"
        send_telegram_alert "$msg"
    else
        echo "✅ Email: $email | Batas: $limit IP | Jumlah: $overlap IP aktif bersamaan."
    fi

done < "$CLIENT_CONFIG"
EOL

cat <<EOL > /etc/xray/clients_limit.conf
example=1
EOL

# Cron job entry
CRON_JOB="*/5 * * * * /bin/bash /etc/xray/limitip.sh"

# Cek apakah cron job sudah ada
(crontab -l 2>/dev/null | grep -F "$CRON_JOB") >/dev/null 2>&1
