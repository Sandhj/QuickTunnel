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
# ==== Link Github
GITHUB="wget -q https://raw.githubusercontent.com/Sandhj/QuickTunnel/main"

# ==== Buat Direktori dan masuk
mkdir -p update
cd update

# SSH
${GITHUB}/manager-ssh/trial-ssh.sh
${GITHUB}/manager-ssh/renew-ssh.sh
${GITHUB}/manager-ssh/list-user-ssh.sh
${GITHUB}/manager-ssh/add-ssh.sh
${GITHUB}/manager-ssh/delete-ssh.sh

# TROJAN
${GITHUB}/manager-trojan/trial-trojan.sh
${GITHUB}/manager-trojan/renew-trojan.sh
${GITHUB}/manager-trojan/list-user-trojan.sh
${GITHUB}/manager-trojan/delete-trojan.sh
${GITHUB}/manager-trojan/add-trojan.sh

# VLESS
${GITHUB}/manager-vless/trial-vless.sh
${GITHUB}/manager-vless/renew-vless.sh
${GITHUB}/manager-vless/ist-user-vless.sh
${GITHUB}/manager-vless/delete-vless.sh
${GITHUB}/manager-vless/add-vless.sh

# VMESS
${GITHUB}/manager-vmess/trial-vmess.sh
${GITHUB}/manager-vmess/renew-vmess.sh
${GITHUB}/manager-vmess/list-user-vmess.sh
${GITHUB}/manager-vmess/elete-vmess.sh
${GITHUB}/manager-vmess/add-vmess.sh

# MENU
${GITHUB}/menu/menu
${GITHUB}/menu/menu_ssh.sh
${GITHUB}/menu/menu_vmess.sh
${GITHUB}/menu/menu_vless.sh
${GITHUB}/menu/menu_trojan.sh
${GITHUB}/menu/menu_lain.sh
${GITHUB}/menu/menu_bot.sh

# TOOLS
${GITHUB}/tools/update-script.sh
${GITHUB}/tools/restart-service.sh
${GITHUB}/tools/expired.sh
${GITHUB}/tools/change-domain.sh

# ==== BERI ISIN AKSES DAN KELUAR 
chmod +x *
mv * /usr/bin/
cd


# ==== UPDATE INFORMASI VERSION 
cd /etc/xray/
${GITHUB}/version
cd

rm -rf update
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
