#!/bin/bash
clear
# Warna
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Daftar status
STATUSES=(
    "🔍 Checking for updates..."
    "📥 Downloading metadata..."
    "📦 Fetching package list..."
    "🔐 Verifying signatures..."
    "💾 Configuring packages..."
    "🧹 Cleaning up cache..."
)

# Fungsi untuk menampilkan bar progres
progress_bar() {
    local duration=60  # Total langkah
    local bar_length=30
    local i=0

    for ((i = 0; i <= $duration; i++)); do
        percent=$((i * 100 / duration))
        done=$(($percent * $bar_length / 100))
        empty=$(($bar_length - $done))

        bar=$(printf "%${done}s" | tr ' ' '█')
        bar2=$(printf "%${empty}s" | tr ' ' '░')

        # Ganti status setiap beberapa langkah
        if [[ $i -lt 10 ]]; then
            status="${YELLOW}${STATUSES[0]}${NC}"
        elif [[ $i -lt 20 ]]; then
            status="${YELLOW}${STATUSES[1]}${NC}"
        elif [[ $i -lt 30 ]]; then
            status="${YELLOW}${STATUSES[2]}${NC}"
        elif [[ $i -lt 40 ]]; then
            status="${YELLOW}${STATUSES[3]}${NC}"
        elif [[ $i -lt 50 ]]; then
            status="${YELLOW}${STATUSES[4]}${NC}"
        else
            status="${YELLOW}${STATUSES[5]}${NC}"
        fi

        echo -ne "\r${GREEN}[${bar}${bar2}]${NC} ${percent}% — $status"
        sleep 0.1
    done
}

# Jalankan animasi
echo -e "${BLUE}🚀 Starting system update...${NC}"
echo -e "${BLUE}Please Wait...!${NC}"
progress_bar

# ================== ================== ================== ==================

GITHUB="wget -q https://raw.githubusercontent.com/Sandhj/QuickTunnel/main"
${GITHUB}/install/install-menu.sh && bash install-menu.sh

# ================== ================== ================== ==================
loading_bar() {
    local duration=${1:-10}  # Durasi default 10 detik
    local bar_length=30      # Panjang bar
    local i progress bar percent

    for ((i = 0; i <= $duration; i++)); do
        progress=$((i * 100 / duration))
        bar=$(printf "█%.0s" $(seq 1 $((progress * bar_length / 100))))
        bar=${bar}$(printf "░%.0s" $(seq 1 $((bar_length - ${#bar})) ))
        echo -ne "\r[${bar}] ${progress}%"
        sleep 0.2
    done

    echo -e "\n✅ Succes Update script To Version $(cat /etc/xray/version)"
}

# Jalankan animasi bar loading
echo "🚀 Starting system update..."
loading_bar 50

echo "Tekan Enter Untuk Menuju Menu Utama(↩️)"
read -s
menu
