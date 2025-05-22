#!/bin/bash

# Simpan semua user valid ke array
mapfile -t users < <(getent passwd | awk -F: '$3 >= 1000 && $3 != 65534 {print $1}')

clear
echo "---------------------------------------"
echo "       .:: LIST SSH ACCOUNT ::.        "
echo "---------------------------------------"
printf "%-3s | %-17s\n" "No" "Username"
echo "---------------------------------------"

# Tampilkan daftar user
for i in "${!users[@]}"; do
    printf "%-3s | %-17s\n" "$((i+1))" "${users[i]}"
done

echo "---------------------------------------"
echo ""
read -p "Masukkan nomor user dari daftar: " num  
# Ambil username berdasarkan nomor
username="${users[num-1]}"

# Konfirmasi penghapusan
echo "Anda akan menghapus akun: $username"
read -p "Apakah Anda yakin? (y/n): " confirm

if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    userdel -r "$username" &>/dev/null
    if [ $? -eq 0 ]; then
        echo "Akun $username berhasil dihapus."
    else
        echo "Gagal menghapus akun $username."
    fi
else
    echo "Penghapusan dibatalkan."
fi
echo ""
read -p "Tekan Enter untuk keluar..."
