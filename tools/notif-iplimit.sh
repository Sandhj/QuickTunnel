#!/bin/bash

TOKEN=$(cat /root/token)
IDTELE=$(cat /root/idtele)

# Folder tujuan
FOLDER="/root/san/iplimit"

# Cek apakah user root
if [ "$(id -u)" != "0" ]; then
   echo "❌ Script harus dijalankan dengan root"
   exit 1
fi

echo "[*] Membuat folder $FOLDER..."
mkdir -p "$FOLDER"

# Buat file emails.txt
EMAIL_FILE="$FOLDER/emails.txt"
echo "[*] Membuat file daftar email..."
cat > "$EMAIL_FILE" <<EOL
client1@example.com 2
EOL

# Buat script utama
SCRIPT_FILE="$FOLDER/cek_email_limit.sh"
echo "[*] Membuat script utama..."
cat > "$SCRIPT_FILE" <<'EOF'
#!/bin/bash

# Konfigurasi
XRAY_LOG="/var/log/xray/access.log"
LINES_TO_CHECK=100
EMAIL_LIST="/root/email_lists/emails.txt"

# Konfigurasi Telegram (Silakan ganti dengan token dan chat_id kamu)
BOT_TOKEN="$TOKEN"  # Ganti dengan token bot kamu
CHAT_ID="$IDTELE"      # Ganti dengan chat ID kamu

echo "[*] Membaca \$LINES_TO_CHECK baris log terbaru..."
LOG_LINES=$(tail -n "\$LINES_TO_CHECK" "\$XRAY_LOG")

echo "[*] Memulai pemeriksaan aktivitas email..."

# Fungsi kirim notifikasi Telegram
kirim_telegram() {
    local PESAN="\$1"
    curl -s -X POST https://api.telegram.org/bot\$BOT_TOKEN/sendMessage \
        -d chat_id=\$CHAT_ID \
        -d text="\$PESAN" \
        -d parse_mode="markdown" > /dev/null
}

# Baca daftar email + limit
while IFS= read -r LINE || [[ -n "\$LINE" ]]
do
    # Skip baris kosong
    if [[ -z "\$LINE" ]]; then
        continue
    fi

    EMAIL=\$(echo "\$LINE" | awk '{print \$1}')
    LIMIT=\$(echo "\$LINE" | awk '{print \$2}')

    echo ""
    echo "[*] Memeriksa: \$EMAIL (Limit: \$LIMIT)"

    IPs=\$(echo "\$LOG_LINES" | grep -i "email: *\$EMAIL" | awk '{print \$4}' | cut -d: -f1 | sort | uniq)
    COUNT=\$(echo "\$IPs" | grep -v '^$' | wc -l)

    if (( COUNT == 0 )); then
        echo "❌ Tidak ada aktivitas ditemukan untuk email ini."
    else
        echo "✅ Ditemukan \$COUNT IP menggunakan akun ini:"
        echo "\$IPs"

        if (( COUNT > LIMIT )); then
            PESAN="⚠️ *ALERT: DETEKSI PENGGUNAAN BERLEBIHAN*\n\nEmail: \$EMAIL\nJumlah IP Aktif: \$COUNT\nLimit: \$LIMIT\n\nDaftar IP:\n\$IPs"
            echo "🔔 Melebihi limit! Mengirim notifikasi ke Telegram..."
            kirim_telegram "\$PESAN"
        fi
    fi

done < "\$EMAIL_LIST"

echo ""
echo "[✓] Pemeriksaan selesai."
EOF

# Beri izin eksekusi
chmod +x "$SCRIPT_FILE"

# Tambahkan cron job (jika belum ada)
CRON_JOB="0 * * * * $SCRIPT_FILE"
(crontab -l 2>/dev/null | grep -v "$SCRIPT_FILE") | crontab -
(crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
