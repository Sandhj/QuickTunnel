#!/bin/bash

# Konfigurasi
EMAIL="client2@example.com"            # Ganti dengan email user yang ingin diperiksa
XRAY_LOG="/var/log/xray/access.log"    # Sesuaikan path log Xray kamu
LINES_TO_CHECK=100                     # Jumlah baris log terbaru yang akan dicek

# File sementara untuk menyimpan daftar IP
TMP_FILE="/tmp/ip_check_temp.txt"

echo "[*] Memeriksa koneksi untuk email: $EMAIL"
echo "   ➤ Membaca $LINES_TO_CHECK baris log terbaru..."

# Ambil 100 baris log terbaru, filter berdasarkan email, lalu ekstrak IP dengan benar
tail -n "$LINES_TO_CHECK" "$XRAY_LOG" | \
    grep -i "email: *$EMAIL" | \
    awk '{print $4}' | cut -d: -f1 | sort | uniq > "$TMP_FILE"

# Hitung jumlah IP unik
COUNT=$(cat "$TMP_FILE" | grep -v '^$' | wc -l)

# Simpan daftar IP ke variabel
IPs=$(cat "$TMP_FILE")

# Tampilkan hasil
echo ""
if (( COUNT == 0 )); then
    echo "❌ Tidak ada koneksi ditemukan untuk email: $EMAIL"
else
    echo "✅ Ditemukan $COUNT IP aktif menggunakan akun ini:"
    echo "$IPs"
fi
