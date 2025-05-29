import telebot
from telebot import types
from datetime import datetime, timedelta
import sqlite3
import requests
import base64
import json
import zipfile
import os
import threading
import time

# === Konfigurasi ===
TOKEN = '7613051160:AAEnIVbNM4uaH1NvXN5Cct_iyjF7wvvcBAI'  # Ganti dengan token bot kamu
ADMIN_ID = 576495165  # Ganti dengan chat ID kamu

# Konfigurasi GitHub
GITHUB_TOKEN = "GITHUB_TOKEN_MU"  # ⚠️ Ganti dengan token GitHub kamu
REPO_OWNER = "Sandhj"
REPO_NAME = "QuickTunnel"
FILE_PATH = "permission"
BRANCH = "main"

bot = telebot.TeleBot(TOKEN)

# === Koneksi ke Database SQLite ===
DB_NAME = 'user_balance.db'

def init_db():
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS users (
                 chat_id INTEGER PRIMARY KEY,
                 username TEXT,
                 balance INTEGER DEFAULT 0)''')  # Saldo default 0
    conn.commit()
    conn.close()

def get_user_data(chat_id):
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute("SELECT * FROM users WHERE chat_id=?", (chat_id,))
    user = c.fetchone()
    conn.close()
    return user

def add_or_update_user(chat_id, username, balance=0):
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute("INSERT OR IGNORE INTO users (chat_id, username, balance) VALUES (?, ?, ?)",
              (chat_id, username, balance))
    c.execute("UPDATE users SET username=? WHERE chat_id=?", (username, chat_id))
    conn.commit()
    conn.close()

def update_balance(chat_id, new_balance):
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute("UPDATE users SET balance=? WHERE chat_id=?", (new_balance, chat_id))
    conn.commit()
    conn.close()

def get_all_users():
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute("SELECT chat_id, username, balance FROM users")
    users = c.fetchall()
    conn.close()
    return users

# === Fungsi Baca File Permission dari GitHub ===
def baca_permission():
    url = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/contents/{FILE_PATH}"
    headers = {
        "Authorization": f"token {GITHUB_TOKEN}",
        "Accept": "application/vnd.github.v3+json"
    }
    res = requests.get(url, headers=headers)
    if res.status_code != 200:
        print("Error membaca file:", res.json())
        return []
    content = base64.b64decode(res.json()['content']).decode()
    lines = content.strip().splitlines()
    data = []
    for line in lines:
        if not line or line.startswith("#"):
            continue
        parts = line.split()
        ip = parts[0]
        date_str = parts[1]
        data.append((ip, date_str))
    return data

# === Fungsi Tulis File Permission ke GitHub ===
def tulis_permission(data):
    url = f"https://api.github.com/repos/{REPO_OWNER}/{REPO_NAME}/contents/{FILE_PATH}"
    headers = {
        "Authorization": f"token {GITHUB_TOKEN}",
        "Accept": "application/vnd.github.v3+json"
    }

    # Ambil SHA file lama
    res = requests.get(url, headers=headers)
    sha = res.json().get('sha') if res.status_code == 200 else None

    # Format konten baru
    content = '\n'.join([f"{ip} {date}" for ip, date in data])
    payload = {
        "message": "Update permission via bot",
        "content": base64.b64encode(content.encode()).decode(),
        "branch": BRANCH
    }
    if sha:
        payload["sha"] = sha

    res = requests.put(url, headers=headers, data=json.dumps(payload))
    if res.status_code == 200:
        return True
    else:
        print("Error menulis file:", res.json())
        return False

# === Fungsi Tampilkan Panel Pengguna ===
def tampilkan_panel(chat_id, user_id):
    user = bot.get_chat(user_id)
    username = user.username or "-"
    chatid = user.id
    add_or_update_user(chatid, username)

    data = get_user_data(chatid)
    chatid_db, uname, balance = data

    # Judul berdasarkan apakah user adalah admin
    if user_id == ADMIN_ID:
        title = "🟢 PANEL ADMIN SCRIPT"
    else:
        title = "🟢 PANEL MEMBER SCRIPT"

    panel_text = f"{title}\n"
    panel_text += f"ChatID     : `{chatid}`\n"  # Format ChatID sebagai kode untuk mudah dicopy
    panel_text += f"Username   : @{uname}\n"
    panel_text += f"Saldo      : Rp {balance:,}\n\n"

    markup = types.InlineKeyboardMarkup(row_width=2)
    markup.add(
        types.InlineKeyboardButton("REGIS IP", callback_data='regis_ip'),
        types.InlineKeyboardButton("CHANGE IP", callback_data='change_ip'),
        types.InlineKeyboardButton("RENEW IP", callback_data='renew_ip')
    )
    if user_id == ADMIN_ID:
        markup.add(types.InlineKeyboardButton("ADMIN", callback_data='admin_menu'))

    bot.send_message(chat_id, panel_text, reply_markup=markup, parse_mode="Markdown")

# === Handler untuk /start ===
@bot.message_handler(commands=['start'])
def send_welcome(message):
    tampilkan_panel(message.chat.id, message.from_user.id)

# === Callback Query Handler ===
@bot.callback_query_handler(func=lambda call: True)
def handle_query(call):
    chat_id = call.message.chat.id
    user_id = call.from_user.id

    if call.data == 'regis_ip':
        msg = bot.send_message(chat_id, "Kirimkan IP dan jumlah hari (contoh: 192.168.1.10 30):")
        bot.register_next_step_handler(msg, proses_regis_ip)

    elif call.data == 'change_ip':
        msg = bot.send_message(chat_id, "Kirimkan IP Lama dan IP Baru (contoh: 192.168.1.10 192.168.1.11):")
        bot.register_next_step_handler(msg, proses_change_ip)

    elif call.data == 'renew_ip':
        msg = bot.send_message(chat_id, "Kirimkan IP dan jumlah hari untuk perpanjang (contoh: 192.168.1.10 30):")
        bot.register_next_step_handler(msg, proses_renew_ip)

    elif call.data == 'admin_menu':
        if chat_id != ADMIN_ID:
            bot.answer_callback_query(call.id, "Akses ditolak! Anda bukan admin.", show_alert=True)
            return
        markup = types.InlineKeyboardMarkup()
        markup.add(
            types.InlineKeyboardButton("Tambah Saldo", callback_data='admin_tambah_saldo'),
            types.InlineKeyboardButton("Hapus User", callback_data='admin_hapus_user')
        )
        markup.add(
            types.InlineKeyboardButton("List User", callback_data='admin_lihat_semua')
        )
        bot.send_message(chat_id, "🖥️ MENU ADMIN CONTROL :", reply_markup=markup)

    elif call.data == 'admin_tambah_saldo':
        msg = bot.send_message(chat_id, "Kirimkan chat ID dan jumlah saldo (contoh: 123456789 50000):")
        bot.register_next_step_handler(msg, proses_admin_tambah_saldo)

    elif call.data == 'admin_hapus_user':
        msg = bot.send_message(chat_id, "Kirimkan chat ID user yang ingin dihapus:")
        bot.register_next_step_handler(msg, proses_admin_hapus_user)

    elif call.data == 'admin_lihat_semua':
        users = get_all_users()
        if not users:
            bot.send_message(chat_id, "Belum ada user yang terdaftar.")
            return
        list_users = "\n".join([f"`{uid}` | @{uname} | Rp {bal:,}" for uid, uname, bal in users])
        bot.send_message(chat_id, f"Daftar User:\n{list_users}", parse_mode="Markdown")

# === Proses Input ===
def proses_regis_ip(message):
    try:
        ip, days = message.text.strip().split()
        days = int(days)
        cost = days * 333
        exp_date = (datetime.now() + timedelta(days=days)).strftime("%Y-%m-%d")

        user_id = message.from_user.id
        user_data = get_user_data(user_id)
        current_balance = user_data[2]

        if current_balance < cost:
            bot.reply_to(message, f"Saldo tidak mencukupi. Diperlukan: Rp {cost:,}")
            tampilkan_panel(message.chat.id, user_id)
            return

        data = baca_permission()
        data.append((ip, exp_date))
        if tulis_permission(data):
            new_balance = current_balance - cost
            update_balance(user_id, new_balance)
            bot.reply_to(
                message,
                f"✅ Registrasi IP Succes\n"
                f"Cost : Rp {cost:,}\n\n"
                f"Link Install :\n"
                f"`bash <(curl -s https://raw.githubusercontent.com/Sandhj/QuickTunnel/main/install.sh)`",
                parse_mode="Markdown"
            )
    except:
        bot.reply_to(message, "Format salah. Contoh: 192.168.1.10 30")

def proses_change_ip(message):
    try:
        old_ip, new_ip = message.text.strip().split()
        data = baca_permission()
        found = False
        for i, (ip, date) in enumerate(data):
            if ip == old_ip:
                data[i] = (new_ip, date)
                found = True
                break
        if not found:
            bot.reply_to(message, "IP lama tidak ditemukan.")
            return
        if tulis_permission(data):
            bot.reply_to(message, f"IP `{old_ip}` berhasil diganti menjadi `{new_ip}`.", parse_mode="Markdown")
        tampilkan_panel(message.chat.id, message.from_user.id)
    except:
        bot.reply_to(message, "Format salah. Contoh: 192.168.1.10 192.168.1.11")

def proses_renew_ip(message):
    try:
        ip, days = message.text.strip().split()
        days = int(days)
        cost = days * 333
        exp_date = (datetime.now() + timedelta(days=days)).strftime("%Y-%m-%d")

        user_id = message.from_user.id
        user_data = get_user_data(user_id)
        current_balance = user_data[2]

        if current_balance < cost:
            bot.reply_to(message, f"Saldo tidak mencukupi. Diperlukan: Rp {cost:,}")
            tampilkan_panel(message.chat.id, user_id)
            return

        data = baca_permission()
        found = False
        for i, (ip_file, date) in enumerate(data):
            if ip_file == ip:
                data[i] = (ip, exp_date)
                found = True
                break
        if not found:
            bot.reply_to(message, "IP tidak ditemukan dalam daftar.")
            return
        if tulis_permission(data):
            new_balance = current_balance - cost
            update_balance(user_id, new_balance)
            bot.reply_to(message, f"Tanggal IP `{ip}` diperbarui hingga `{exp_date}`. Biaya: Rp {cost:,}", parse_mode="Markdown")
        tampilkan_panel(message.chat.id, user_id)
    except:
        bot.reply_to(message, "Format salah. Contoh: 192.168.1.10 30")

# === Fungsi Admin ===
def proses_admin_tambah_saldo(message):
    try:
        chat_id_str, amount_str = message.text.strip().split()
        chat_id_user = int(chat_id_str)
        amount = int(amount_str)

        user = get_user_data(chat_id_user)
        if not user:
            bot.reply_to(message, "User tidak ditemukan.")
            return

        new_balance = user[2] + amount
        update_balance(chat_id_user, new_balance)
        bot.reply_to(message, f"Saldo user `{chat_id_user}` ditambahkan sebesar Rp {amount:,}.", parse_mode="Markdown")
        tampilkan_panel(message.chat.id, message.from_user.id)
    except:
        bot.reply_to(message, "Format salah. Contoh: 123456789 50000")

def proses_admin_hapus_user(message):
    try:
        chat_id_user = int(message.text.strip())
        conn = sqlite3.connect(DB_NAME)
        c = conn.cursor()
        c.execute("DELETE FROM users WHERE chat_id=?", (chat_id_user,))
        conn.commit()
        conn.close()
        bot.reply_to(message, f"User `{chat_id_user}` berhasil dihapus dari database.", parse_mode="Markdown")
        tampilkan_panel(message.chat.id, message.from_user.id)
    except:
        bot.reply_to(message, "Format salah. Masukkan chat ID yang valid.")

# === Fungsi Backup Otomatis & Kirim ke Admin ===
BACKUP_FOLDER = "backup"

def kirim_backup_ke_admin():
    try:
        # Buat folder backup jika belum ada
        if not os.path.exists(BACKUP_FOLDER):
            os.makedirs(BACKUP_FOLDER)

        waktu_sekarang = datetime.now().strftime("%Y%m%d_%H%M%S")
        zip_name = f"{BACKUP_FOLDER}/backup_{waktu_sekarang}.zip"

        with zipfile.ZipFile(zip_name, 'w') as zipf:
            zipf.write(DB_NAME)

        # Kirim file ZIP ke admin
        with open(zip_name, 'rb') as f:
            bot.send_document(ADMIN_ID, f, caption=f"📦 Backup Otomatis: {os.path.basename(zip_name)}")

        print(f"[INFO] Backup berhasil dikirim: {zip_name}")

    except Exception as e:
        print(f"[ERROR] Gagal mengirim backup: {e}")

def jalankan_backup_otomatis():
    while True:
        kirim_backup_ke_admin()
        time.sleep(3 * 60 * 60)  # 3 jam

# Jalankan backup secara latar belakang
threading.Thread(target=jalankan_backup_otomatis, daemon=True).start()

# === Fungsi Restore dari Upload ZIP ===
@bot.message_handler(content_types=['document'])
def handle_restore(message):
    if message.from_user.id != ADMIN_ID:
        bot.reply_to(message, "Anda tidak memiliki akses untuk restore.")
        return

    try:
        file_id = message.document.file_id
        file_info = bot.get_file(file_id)
        downloaded_file = bot.download_file(file_info.file_path)

        zip_path = "temp_backup.zip"
        with open(zip_path, 'wb') as f:
            f.write(downloaded_file)

        with zipfile.ZipFile(zip_path, 'r') as zipf:
            zipf.extractall(".")

        os.remove(zip_path)
        bot.reply_to(message, "Database berhasil direstore dari backup.", parse_mode="Markdown")
    except Exception as e:
        bot.reply_to(message, f"Gagal melakukan restore: {e}")

# === Jalankan Bot ===
print("Bot sedang berjalan...")
init_db()

# Mulai bot
bot.polling(none_stop=True)
