#!/bin/bash

# Gunakan associative array untuk menyimpan username yang sudah muncul
declare -A seen_users

echo "User              | Expired Date"
echo "------------------|--------------"

# Baca setiap baris yang mengandung '##' dari file config.json
grep '##' /etc/xray/config.json | while read -r line; do
    # Ekstrak username dan expired date
    user=$(echo "$line" | awk '{print $2}')
    expired=$(echo "$line" | awk '{print $3}')

    # Cek apakah user sudah pernah ditampilkan
    if [[ -z "${seen_users[$user]}" ]]; then
        seen_users[$user]=1  # Tandai bahwa user ini sudah ditampilkan
        printf "%-17s | %-12s\n" "$user" "$expired"
    fi
done
