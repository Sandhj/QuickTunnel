#!/bin/bash

# Export Link Github 
GITHUB="https://raw.githubusercontent.com/Sandhj/QuickTunnel/main/"

# Install autobackup l
wget -q ${GITHUB}tools/auto_backup.sh && bash auto_backup.sh

# Install LimitIP
wget -q ${GITHUB}tools/limit_ip.sh && bash limit_ip.sh
