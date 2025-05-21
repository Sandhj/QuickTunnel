#!/bin/bash

# Export File tujuan
FILE="/etc/xray/config.json"

# === Vmess Expired
grep -n '##' "$FILE" | while IFS=: read -r line_num comment; do
    # Ambil kata ke-3 sebagai tanggal
    expiry_date=$(echo "$comment" | awk '{print $3}')
    
    # Validasi apakah tanggal sesuai format YYYY-MM-DD
    if [[ "$expiry_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        # Bandingkan tanggal dengan hari ini
        today=$(date +%F)
        if [[ "$expiry_date" < "$today" ]]; then
            echo "Tanggal expired ditemukan di baris $line_num: $comment"
            echo "Menghapus baris $line_num dan $((line_num + 1))..."

            # Hapus baris tersebut dan baris berikutnya secara aman
            sed -i "${line_num}d" "$FILE"
            sed -i "${line_num}d" "$FILE"
        fi
    else
        echo "Format tanggal tidak valid pada baris $line_num: $comment"
    fi
done

# === Vless Expired
grep -n '#?' "$FILE" | while IFS=: read -r line_num comment; do
    # Ambil kata ke-3 sebagai tanggal
    expiry_date=$(echo "$comment" | awk '{print $3}')
    
    # Validasi apakah tanggal sesuai format YYYY-MM-DD
    if [[ "$expiry_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        # Bandingkan tanggal dengan hari ini
        today=$(date +%F)
        if [[ "$expiry_date" < "$today" ]]; then
            echo "Tanggal expired ditemukan di baris $line_num: $comment"
            echo "Menghapus baris $line_num dan $((line_num + 1))..."

            # Hapus baris tersebut dan baris berikutnya secara aman
            sed -i "${line_num}d" "$FILE"
            sed -i "${line_num}d" "$FILE"
        fi
    else
        echo "Format tanggal tidak valid pada baris $line_num: $comment"
    fi
done

# === Trojan Expired
grep -n '#!' "$FILE" | while IFS=: read -r line_num comment; do
    # Ambil kata ke-3 sebagai tanggal
    expiry_date=$(echo "$comment" | awk '{print $3}')
    
    # Validasi apakah tanggal sesuai format YYYY-MM-DD
    if [[ "$expiry_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        # Bandingkan tanggal dengan hari ini
        today=$(date +%F)
        if [[ "$expiry_date" < "$today" ]]; then
            echo "Tanggal expired ditemukan di baris $line_num: $comment"
            echo "Menghapus baris $line_num dan $((line_num + 1))..."

            # Hapus baris tersebut dan baris berikutnya secara aman
            sed -i "${line_num}d" "$FILE"
            sed -i "${line_num}d" "$FILE"
        fi
    else
        echo "Format tanggal tidak valid pada baris $line_num: $comment"
    fi
done

systemctl restart xray

# ==== Expired SSH
hariini=`date +%d-%m-%Y`
cat /etc/shadow | cut -d: -f1,8 | sed /:$/d > /tmp/expirelist.txt
totalaccounts=`cat /tmp/expirelist.txt | wc -l`
for((i=1; i<=$totalaccounts; i++ ))
do
tuserval=`head -n $i /tmp/expirelist.txt | tail -n 1`
username=`echo $tuserval | cut -f1 -d:`
userexp=`echo $tuserval | cut -f2 -d:`
userexpireinseconds=$(( $userexp * 86400 ))
tglexp=`date -d @$userexpireinseconds`             
tgl=`echo $tglexp |awk -F" " '{print $3}'`
while [ ${#tgl} -lt 2 ]
do
tgl="0"$tgl
done
while [ ${#username} -lt 15 ]
do
username=$username" " 
done
bulantahun=`echo $tglexp |awk -F" " '{print $2,$6}'`
todaystime=`date +%s`
if [ $userexpireinseconds -ge $todaystime ] ;
then
:
else
userdel --force $username
fi
done
