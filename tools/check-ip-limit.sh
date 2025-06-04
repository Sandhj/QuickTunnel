#!/bin/bash

# Konfigurasi
LOG_FILE="/var/log/xray/access.log"            # Path access.log
CLIENT_CONFIG="clients_limit.conf"             # File konfigurasi client
SESSION_DURATION_MINUTES=5                     # Durasi sesi aktif dalam menit
TIME_WINDOW_MINUTES=60                         # Rentang waktu yang diperiksa (menit)

# Konfigurasi Telegram Bot
TELEGRAM_BOT_TOKEN="$(cat /etc/xray/token)"    # Token bot Telegram
TELEGRAM_CHAT_ID="$(cat /etc/xray/chatid)"     # Chat ID tujuan

# Fungsi untuk format pesan Telegram
format_telegram_message() {
    local user=$1
    local limit=$2
    local count=$3
    local ips=$4
    
    echo "🚨 <b>PELANGGARAN BATAS DEVICE</b> 🚨"
    echo "━━━━━━━━━━━━━━━━━━━━━━"
    echo "▪️ <b>User:</b> <code>$user</code>"
    echo "▪️ <b>Batas IP:</b> $limit"
    echo "▪️ <b>IP Aktif:</b> $count"
    echo "━━━━━━━━━━━━━━━━━━━━━━"
    echo "📌 <b>Daftar IP:</b>"
    echo "$ips" | awk '{print "• " $0}'
    echo "━━━━━━━━━━━━━━━━━━━━━━"
    echo "⚠️ <b>Status:</b> Melebihi batas!"
}

# Fungsi kirim notifikasi ke Telegram
send_telegram_alert() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        -d text="$message" \
        -d parse_mode="HTML" > /dev/null
}

# Fungsi cek IP aktif (hanya ambil IP setelah "from")
check_active_ips() {
    local user=$1
    local limit=$2
    
    # Cari log untuk user dalam rentang waktu tertentu
    local now=$(date +%s)
    local start_time=$(date -d "-${TIME_WINDOW_MINUTES} minutes" +%s)
    
    # Dapatkan IP unik yang aktif (hanya IP setelah "from")
    local active_ips=$(grep "$user" "$LOG_FILE" | awk -v start="$start_time" -v dur="$SESSION_DURATION_MINUTES" '
    {
        # Parse tanggal dari log
        log_date = $1 " " $2;
        cmd = "date -d \"" log_date "\" +%s 2>/dev/null";
        cmd | getline ts;
        close(cmd);
        
        # Cek jika dalam rentang waktu
        if (ts >= start) {
            # Ambil IP setelah "from"
            for (i=1; i<=NF; i++) {
                if ($i == "from") {
                    split($(i+1), a, ":");
                    print a[1], ts;
                    break;
                }
            }
        }
    }' | sort | awk -v now=$(date +%s) -v dur="$SESSION_DURATION_MINUTES" '
    {
        ip = $1;
        ts = $2;
        if (ts >= now - dur * 60) {
            print ip;
        }
    }' | sort | uniq)
    
    local ip_count=$(echo "$active_ips" | grep -v '^$' | wc -l)
    
    # Jika melebihi batas
    if [ "$ip_count" -gt "$limit" ]; then
        local formatted_ips=$(echo "$active_ips" | tr '\n' ' ' | sed 's/ $//')
        local message=$(format_telegram_message "$user" "$limit" "$ip_count" "$formatted_ips")
        send_telegram_alert "$message"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $user melebihi batas: $ip_count/$limit IP - $formatted_ips"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $user dalam batas: $ip_count/$limit IP"
    fi
}

# Fungsi utama
main() {
    echo "Memulai pengecekan batas device..."
    echo "Waktu pengecekan: $(date)"
    echo "Rentang waktu: $TIME_WINDOW_MINUTES menit terakhir"
    echo "Durasi sesi aktif: $SESSION_DURATION_MINUTES menit"
    echo "----------------------------------------"
    
    # Baca file konfigurasi
    while IFS='=' read -r user limit || [ -n "$user" ]; do
        # Skip komentar dan baris kosong
        [[ "$user" =~ ^# ]] || [ -z "$user" ] && continue
        
        echo "Memeriksa user: $user (batas: $limit IP)"
        check_active_ips "$user" "$limit"
        echo "----------------------------------------"
    done < "$CLIENT_CONFIG"
    
    echo "Pengecekan selesai pada: $(date)"
}

# Jalankan program utama
main
