#!/bin/bash

# Tunneling Script for Debian 12 with Domain + Let's Encrypt
# Author: @TunnelingScript
# Supported: SSH, Dropbear, OpenVPN, Websocket, TLS, Badvpn

read -p "Masukkan domain kamu (contoh: example.com): " DOMAIN

if [ -z "$DOMAIN" ]; then
  echo "Domain tidak boleh kosong!"
  exit 1
fi

echo "Updating system..."
apt update && apt upgrade -y

echo "Installing required packages..."
apt install sudo wget curl unzip python3 python3-pip socat dropbear openvpn stunnel4 net-tools iptables-persistent certbot git build-essential cmake -y

# === CONFIGURE DROPBEAR ===
echo "Configuring Dropbear..."
sed -i 's/NO_START=0/NO_START=1/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=143/g' /etc/default/dropbear
systemctl restart dropbear
systemctl enable dropbear

# === SETUP OPENVPN ===
echo "Setting up OpenVPN..."
wget https://git.io/vpnsetup -O vpn-setup.sh && chmod +x vpn-setup.sh && ./vpn-setup.sh

# === SETUP WEBSOCKET FOR SSH ===
echo "Installing Websockify..."
pip3 install websockify

cat << EOF > /etc/systemd/system/ws-tunnel.service
[Unit]
Description=WebSocket Tunnel Service
After=network.target

[Service]
ExecStart=/usr/local/bin/websockify --web=/usr/share/websockify --cert=/etc/letsencrypt/live/$DOMAIN/fullchain.pem --key=/etc/letsencrypt/live/$DOMAIN/privkey.pem 8080 localhost:22
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable ws-tunnel
systemctl start ws-tunnel

# === REQUEST SSL CERTIFICATE FROM LET'S ENCRYPT ===
echo "Requesting SSL Certificate from Let's Encrypt..."
apt install nginx -y

cat << EOF > /etc/nginx/sites-available/websockify
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
EOF

rm /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/websockify /etc/nginx/sites-enabled/

systemctl restart nginx

certbot certonly --nginx -d $DOMAIN --non-interactive --agree-tos -m admin@$DOMAIN

systemctl stop nginx
systemctl disable nginx

# === SETUP STUNNEL (TLS FOR WEBSOCKET AND DROPBEAR) ===
echo "Setting up Stunnel for TLS..."

mkdir -p /etc/stunnel/
cat << EOF > /etc/stunnel/stunnel.conf
cert = /etc/letsencrypt/live/$DOMAIN/fullchain.pem
key = /etc/letsencrypt/live/$DOMAIN/privkey.pem
client = no
socket = a:SO_REUSEADDR=1

[websocket_tls]
accept = 443
connect = 127.0.0.1:8080
protocol = connect
protocolVersion = 2

[dropbear_tls]
accept = 80
connect = 127.0.0.1:143
protocol = connect
protocolVersion = 2
EOF

sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4

systemctl enable stunnel4
systemctl restart stunnel4

# === INSTALL BADVPN UDPGW ===
echo "Installing Badvpn UDPGW..."
cd /opt
git clone https://github.com/ambrop72/badvpn
cd badvpn
cmake -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1 .
make
cp udpgw/badvpn-udpgw /usr/local/bin/

cat << EOF > /etc/systemd/system/badvpn-udpgw.service
[Unit]
Description=BadVPN UDPGW Service
After=nss-lookup.target

[Service]
ExecStart=/usr/local/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 500
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable badvpn-udpgw
systemctl start badvpn-udpgw

# === ENABLE IP FORWARDING ===
echo "Enabling IP Forwarding..."
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
sysctl -p

# === FIREWALL MASQUERADE ===
echo "Setting up basic firewall rules..."
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables-save > /etc/iptables/rules.v4

echo "✅ Tunneling services have been successfully installed!"

echo "==============================="
echo "Service Ports:"
echo "SSH: 22"
echo "Dropbear: 143"
echo "Dropbear over TLS (Port 80): :80"
echo "WebSocket: :8080"
echo "WebSocket over TLS (HTTPS): :443"
echo "OpenVPN: 1194 (UDP), 443 (TCP)"
echo "Badvpn UDPGW (VC/Game): :7300"
echo "==============================="

echo "🎉 Domains & Certificates:"
echo "Your Domain: $DOMAIN"
echo "Certificate Path: /etc/letsencrypt/live/$DOMAIN/"
