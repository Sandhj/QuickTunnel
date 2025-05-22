#!/bin/bash
clear
echo "---------------------------------------"
echo "No. | User              | Expired Date"
echo "----|-------------------|--------------"

# Inisialisasi counter
no=1

# Baca semua user dari /etc/passwd
cut -d: -f1 /etc/passwd | while read user
do
    # Dapatkan UID user
    uid=$(id -u "$user" 2>/dev/null)

    # Filter hanya user biasa (UID >= 1000 dan bukan nobody/65534)
    if [[ "$uid" -ge 1000 && "$uid" -ne 65534 ]]; then
        # Ambil tanggal expired
        exp=$(sudo chage -l "$user" 2>/dev/null | grep "Account expires" | awk -F": " '{print $2}')
        
        # Jika ada informasi expired, tampilkan
        if [ ! -z "$exp" ]; then
            printf "%-3s | %-17s | %-12s\n" "$no" "$user" "$exp"
            no=$((no + 1))
        fi
    fi
done

echo "---------------------------------------"
