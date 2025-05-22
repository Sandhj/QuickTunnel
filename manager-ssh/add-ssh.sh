#!/bin/bash

# Input dari pengguna
read -p "Masukkan username yang ingin dibuat: " Login
read -p "Masukkan password untuk user $Login: " Pass
read -p "Masukkan masa aktif akun dalam hari: " masaaktif

# Membuat user dengan masa aktif tertentu dan shell /bin/false
useradd -e $(date -d "$masaaktif days" +"%Y-%m-%d") -s /bin/false -M $Login

# Set password untuk user
echo -e "$Pass\n$Pass\n" | passwd $Login &> /dev/null

# Mendapatkan tanggal expired akun
exp=$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')

# Menampilkan informasi akun
echo ""
echo "Akun SSH telah berhasil dibuat!"
echo "-----------------------------"
echo "Username : $Login"
echo "Password : $Pass"
echo "Expired  : $exp"
echo "-----------------------------"
