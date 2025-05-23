#!/bin/bash

# Minta token bot dan chat ID dari pengguna
read -p "Nama Identitas Server: " name_server
read -p "Masukkan Token Bot Telegram Anda: " BOT_TOKEN
read -p "Masukkan Chat ID Telegram Anda: " CHAT_ID

cat <<EOL > /etc/xray/limitip.sh

EOL

cat <<EOL > /etc/xray/clients_limit.conf

EOL
