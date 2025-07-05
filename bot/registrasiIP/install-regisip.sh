#!/bin/bash

# Hapus Direktori lama kalau ada
rm -rf /opt/regisip

# Buat direktori proyek
mkdir -p /opt/regisip
cd /opt/regisip

wget -q https://raw.githubusercontent.com/Sandhj/QuickTunnel/main/bot/registrasiIP/regis.py

echo " SILAHKAN INPUT GITHUB TOKEN KAMU :"
read -p " Token : " GITHUB

sed -i "s/GITHUB_TOKEN_MU/${GITHUB}/" /opt/regisip/regis.py


# Buat venv untuk Bot
apt install python3.12-venv -y
python3 -m venv bot
source bot/bin/activate

apt-get install -y python3-pip

# Instal modul Python yang diperlukan
pip3 install requests
pip3 install schedule
pip3 install pyTelegramBotAPI

cat <<EOL > run.sh
#!/bin/bash
source /opt/regisip/bot/bin/activate
python3 /opt/regisip/regis.py
EOL

wget -q https://raw.githubusercontent.com/Sandhj/QuickTunnel/main/bot/registrasiIP/regis.py

# Buat file service systemd
cat <<EOF > /etc/systemd/system/regisip.service
[Unit]
Description=Backup and Restore Bot Service
After=network.target

[Service]
ExecStart=/usr/bin/bash /opt/regisip/run.sh
WorkingDirectory=/opt/regisip
StandardOutput=inherit
StandardError=inherit
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd dan mulai service
systemctl daemon-reload
systemctl enable regisip
systemctl start regisip

deactivate 

cd
rm -rf /root/*
