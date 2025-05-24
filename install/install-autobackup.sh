#!/bin/bash

# Setup Data Bot
read -p "NAMA SERVER : " name_server
read -p "BOT TOKEN   : " token
read -p "CHAT ID     : " chatid

echo $name_server >> /etc/xray/name_server
echo $token >> /etc/xray/token
echo $chatid >> /etc/xray/chatid

systemctl restart auto
