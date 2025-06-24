#!/bin/bash

# Export File tujuan
FILE="/etc/xray/config.json"

# === Xray Expired
# Check if file exists
if [ ! -f "$FILE" ]; then
    echo "File not found: $FILE"
    exit 1
fi

# Search for all patterns: ##, #?, #!
grep -n -E '##|#\?|#!' "$FILE" | while IFS=: read -r line_num comment; do
    # Extract the 3rd word as date
    expiry_date=$(echo "$comment" | awk '{print $3}')
    
    # Validate if date matches YYYY-MM-DD format
    if [[ "$expiry_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        # Compare date with today
        today=$(date +%F)
        if [[ "$expiry_date" < "$today" ]]; then
            echo "Expired date found at line $line_num: $comment"
            echo "Deleting line $line_num and $((line_num + 1))..."

            # Safely delete the line and the next line
            sed -i "${line_num}d" "$FILE"
            sed -i "${line_num}d" "$FILE"
        fi
    else
        echo "Invalid date format at line $line_num: $comment"
    fi
done

systemctl restart xray

# ==== Expired SSH
hapus_user_kadaluarsa() {
    echo "Memeriksa dan menghapus akun yang sudah kadaluarsa..."
    for user in $(cut -f1 -d: /etc/passwd); do
        expire_date=$(chage -l "$user" 2>/dev/null | grep "Account expires" | awk -F": " '{print $2}')
        if [[ "$expire_date" != "never" && "$expire_date" != "" ]]; then
            # Konversi tanggal expired dan tanggal hari ini ke format detik sejak epoch
            expire_seconds=$(date -d "$expire_date" +%s 2>/dev/null)
            today_seconds=$(date +%s)

            if [[ "$expire_seconds" -lt "$today_seconds" ]]; then
                echo "Akun $user telah kadaluarsa. Menghapus..."
                userdel -r "$user" &>/dev/null
            fi
        fi
    done
}
hapus_user_kadaluarsa
