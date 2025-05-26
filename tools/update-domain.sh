#!/bin/bash
clear 

# ==== Setup Input Domain
echo -e "${BLUE}┌───────────────────────────────────────────────────┐${NC}"
echo -e "${BLUE}│      .:: UPDATE CERTIFIED DOMAIN SERVER ::.       │${NC}"
echo -e "${BLUE}└───────────────────────────────────────────────────┘${NC}"
echo ""
read -p "Type Your Domain : " domain

rm -f /etc/xray/domain
echo $domain >> /etc/xray/domain

# ==== hapus cert lama
rm -f /etc/xray/xray.crt
rm -f /etc/xray/xray.key

# ==== Cert Domain Dengan Acme
systemctl stop nginx
curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc

systemctl restart nginx


echo " ✅ Cert Domain Sukses "
echo "Tekan Enter Untuk Menuju Menu Utama(↩️)"
read -s
menu
