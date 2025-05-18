#!/bin/bash
# Proxy For WS - Fix for Debian 12
# Mod By SAN (Fix by AI)
# ==========================================

# Warna
RED='\033[0;31m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHT='\033[0;37m'

clear
echo -e "${GREEN}Installing SSH Websocket by SAN${NC}" | lolcat
echo -e "${ORANGE}Progress...${NC}" | lolcat
sleep 3
cd

# Install Python3 jika belum ada
if ! command -v python3 &> /dev/null; then
    echo -e "${YELLOW}Installing Python3...${NC}"
    apt update && apt install -y python3
fi

# Download file-file yang dibutuhkan
echo -e "${BLUE}Downloading WebSocket binaries...${NC}"

wget -O /usr/local/bin/ws-dropbear https://raw.githubusercontent.com/Paper890/mysc/main/websocket/ws-dropbear
wget -O /usr/local/bin/ws-stunnel https://raw.githubusercontent.com/Paper890/mysc/main/websocket/ws-stunnel

chmod +x /usr/local/bin/ws-dropbear
chmod +x /usr/local/bin/ws-stunnel

# Service ws-dropbear
echo -e "${BLUE}Setting up ws-dropbear service...${NC}"
wget -O /etc/systemd/system/ws-dropbear.service https://raw.githubusercontent.com/Paper890/mysc/main/websocket/service-wsdropbear
chmod 644 /etc/systemd/system/ws-dropbear.service

# Service ws-stunnel
echo -e "${BLUE}Setting up ws-stunnel service...${NC}"
wget -O /etc/systemd/system/ws-stunnel.service https://raw.githubusercontent.com/Paper890/mysc/main/websocket/ws-stunnel.service
chmod 644 /etc/systemd/system/ws-stunnel.service

# Reload systemd
systemctl daemon-reload

# Enable dan start services
for service in ws-dropbear ws-stunnel; do
    systemctl enable $service >/dev/null 2>&1
    systemctl restart $service
    echo -e "${GREEN}[ok] Restarted $service${NC}"
done

# Instalasi WS Non TLS
echo -e "${GREEN}Installing SSH Websocket None TLS by SAN${NC}" | lolcat
echo -e "${ORANGE}Progress...${NC}" | lolcat
sleep 3

# Install dependensi python jika belum
if ! command -v python &> /dev/null; then
    echo -e "${YELLOW}Installing Python symlink...${NC}"
    apt install -y python-is-python3
fi

# Getting Proxy Template
echo -e "${BLUE}Downloading ws-nontls.py...${NC}"
wget -q -O /usr/local/bin/ws-nontls https://raw.githubusercontent.com/Paper890/mysc/main/websocket/ws-nontls.py
chmod +x /usr/local/bin/ws-nontls

# Installing Service
echo -e "${BLUE}Creating ws-nontls service...${NC}"
cat > /etc/systemd/system/ws-nontls.service << EOF
[Unit]
Description=Python Proxy Mod By Arh-Project
Documentation=https://t.me/r1f4n_1122
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/python3 -O /usr/local/bin/ws-nontls 8880
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Reload, enable, dan restart
systemctl daemon-reload
systemctl enable ws-nontls >/dev/null 2>&1
systemctl restart ws-nontls
echo -e "${GREEN}[ok] Restarted ws-nontls${NC}"

echo -e "${GREEN}✅ Installation Completed!${NC}"
