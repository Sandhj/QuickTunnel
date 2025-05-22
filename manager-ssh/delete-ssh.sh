#!/bin/bash

# Fungsi menampilkan header dan daftar user
show_user_list() {
    clear
    echo "---------------------------------------"
    echo "       .:: LIST SSH ACCOUNT ::.        "
    echo "---------------------------------------"
    printf "%-3s | %-17s | %-12s\n" "No" "Username" "Expired"
    echo "---------------------------------------"

    no=1

    # Gunakan proses yang aman agar variabel tetap ada di luar loop
    temp_file=$(mktemp)
    getent passwd | while IFS=: read -r username pass uid gid gecos home shell; do
        if [[ "$uid" -ge 1000 && "$uid" -ne 65534 ]]; then
            exp=$(chage -l "$username" 2>/dev/null | grep "Account expires" | awk -F": " '{print $2}')
            if [ ! -z "$exp" ]; then
                echo "$no:$username" >> "$temp_file"
                printf "%-3s | %-17s | %-12s\n" "$no" "$username" "$exp"
                no=$((no + 1))
            fi
        fi
    done

    echo "---------------------------------------"

    # Simpan mapping nomor ke username dari file sementara
    max_user=0
    declare -gA users_map
    while IFS=':' read -r num usr; do
        users_map[$num]="$usr"
        max_user="$num"
    done < "$temp_file"

    rm "$temp_file"
}

# Fungsi menghapus user berdasarkan nomor dari daftar
delete_user_by_number() {
    while true; do
        read -p "Masukkan nomor user dari daftar: " selected_no

        # Validasi apakah input adalah angka
        if [[ -z "$selected_no" || ! "$selected_no" =~ ^[0-9]+$ ]]; then
            echo "Input tidak valid! Harap masukkan angka."
            continue
        elif (( selected_no < 1 || selected_no > max_user )); then
            echo "Nomor tidak ada dalam daftar! Harap coba lagi."
            continue
        else
            break
        fi
    done

    del_user="${users_map[$selected_no]}"

    echo ""
    echo "Anda akan menghapus akun: $del_user"
    read -p "Apakah Anda yakin? (y/n): " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        userdel -r "$del_user" &>/dev/null
        if [ $? -eq 0 ]; then
            echo "Akun $del_user berhasil dihapus."
        else
            echo "Gagal menghapus akun $del_user."
        fi
    else
        echo "Penghapusan dibatalkan."
    fi
}

# Jalankan fungsi
show_user_list
echo ""
delete_user_by_number

echo ""
read -p "Tekan Enter untuk keluar..."
