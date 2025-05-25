# ==== Link Github
GITHUB="wget -q https://raw.githubusercontent.com/Sandhj/QuickTunnel/main"

# ==== Buat Direktori dan masuk
mkdir -p update
cd update

# VMESS
${GITHUB}/manager-ssh/trial-ssh.sh
${GITHUB}/manager-ssh/renew-ssh.sh
${GITHUB}/manager-ssh/list-user-ssh.sh
${GITHUB}/manager-ssh/add-ssh.sh
${GITHUB}/manager-ssh/delete-ssh.sh

# VLESS
${GITHUB}/manager-trojan/trial-trojan.sh
${GITHUB}/manager-trojan/renew-trojan.sh
${GITHUB}/manager-trojan/list-user-trojan.sh
${GITHUB}/manager-trojan/delete-trojan.sh
${GITHUB}/manager-trojan/add-trojan.sh
