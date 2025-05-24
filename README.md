# QuickTunnel – Script Tunneling SSH & XRAY untuk Debian 12
## 📌 Deskripsi

**QuickTunnel** adalah script otomatisasi ringan yang dirancang untuk mempermudah pemasangan layanan tunneling menggunakan protokol SSH dan XRay. Script ini mendukung teknologi tunneling modern seperti **WebSocket**, **VMESS**, **VLESS**, dan **Trojan**, menjadikannya ideal bagi pengguna yang membutuhkan solusi proxy berkinerja tinggi dengan konfigurasi minimal.

Cocok digunakan untuk membuat koneksi aman, melewati firewall, atau mengelola jaringan pribadi — semua dalam satu proses instalasi yang sederhana dan cepat.

---

## ✅ Fitur Utama

- 🔧 Instalasi sepenuhnya otomatis
- 🐧 Dioptimalkan untuk [![OS](https://img.shields.io/badge/Sistem_Operasi-Debian_12-blue)](https://www.debian.org/distrib/)
- 🌐 Mendukung:
  - **SSH over WebSocket**
  - **XRay** dengan dukungan:
    - VMESS
    - VLESS
    - Trojan
- 🛡️ Siap menggunakan TLS untuk enkripsi trafik
- 🌍 Kompatibel dengan CDN (Cloudflare)
- 📦 Pemasangan ringan dan modular
- 📋 Termasuk reverse proxy Nginx

---

## 🚀 Cara Instalasi

Untuk menginstal **QuickTunnel**, cukup jalankan perintah berikut sebagai root:

```bash
bash <(curl -s https://raw.githubusercontent.com/Sandhj/QuickTunnel/main/install.sh)
