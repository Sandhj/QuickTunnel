#!/bin/bash
clear

# Warna untuk output
green='\e[32m'
red='\e[31m'
NC='\e[0m'

echo -e "┌───────────────────────────────────────────────────┐"
echo -e "│  Setup New Domain For This Script | ${green}QuickTunnel${NC}   │"
echo -e "└───────────────────────────────────────────────────┘"
echo ""

# ==== Input Domain ====
read -p "Type Your Domain : " domain

if [[ -z "$domain" ]]; then
  echo -e "${red}Error: Domain tidak boleh kosong!${NC}"
  exit 1
fi

echo -e "${green}Domain yang dipilih: $domain${NC}"

# ==== Simpan domain baru ====
echo "$domain" > /etc/xray/domain

# ==== Hapus cert lama ====
rm -f /etc/xray/xray.crt /etc/xray/xray.key

# ==== Stop Nginx ====
systemctl stop nginx
echo -e "${green}Nginx telah dihentikan.${NC}"

# ==== Setup acme.sh ====
mkdir -p /root/.acme.sh
curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh

# Set PATH agar acme.sh bisa diakses
export PATH=/root/.acme.sh:$PATH
source ~/.bashrc || source ~/.zshrc || true

# Upgrade & set default CA
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt

# ==== Minta sertifikat ====
echo -e "${green}Meminta sertifikat untuk domain: $domain${NC}"

# Coba mode test dulu (opsional), hapus "--test" jika ingin langsung produksi
/root/.acme.sh/acme.sh --issue -d "$domain" --standalone -k ec-256 --test

if [ $? -ne 0 ]; then
  echo -e "${red}Gagal mendapatkan sertifikat (bisa karena rate limit, port 80 terhalang, atau DNS belum pointing).${NC}"
  echo -e "Coba cek:\n1. Domain sudah pointing ke server\n2. Port 80 bebas\n3. Tunggu 24 jam jika sudah terkena rate limit"
  exit 1
fi

# ==== Instal sertifikat ====
echo -e "${green}Menginstal sertifikat...${NC}"
/root/.acme.sh/acme.sh --installcert -d "$domain" \
--fullchainpath /etc/xray/xray.crt \
--keypath /etc/xray/xray.key \
--ecc

# Set permission
chmod 644 /etc/xray/xray.crt
chmod 600 /etc/xray/xray.key

# Restart Nginx
systemctl restart nginx
echo -e "${green}Nginx telah dimulai ulang.${NC}"

# Selesai
echo ""
echo -e "✅ Cert Domain Sukses!"
echo -e "Lokasi sertifikat:"
echo -e " - Fullchain: /etc/xray/xray.crt"
echo -e " - Private Key: /etc/xray/xray.key"

echo -e "\nTekan Enter Untuk Menuju Menu Utama(↩️)"
read -s
menu
