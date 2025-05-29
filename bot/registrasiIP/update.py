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
TOKEN = '7894185172:AAG4zRBtErBtVzB_Ey-EHSantneoTqwdcU4'  # Ganti dengan token bot kamu
ADMIN_ID = 576495165  # Ganti dengan chat ID admin kamu

# Konfigurasi GitHub
GITHUB_TOKEN = "Github"  # ⚠️ Ganti dengan token GitHub kamu
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
                 balance INTEGER DEFAULT 0,
                 status TEXT DEFAULT 'Member',
                 status_expire TIMESTAMP)''')
    conn.commit()
    conn.close()

def get_user_data(chat_id):
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute("SELECT * FROM users WHERE chat_id=?", (chat_id,))
    user = c.fetchone()
    conn.close()
    return user

def add_or_update_user(chat_id, username, balance=0, status="Member", status_expire=None):
    now = datetime.now()
    if status_expire is None and status != "Member":
        status_expire = now + timedelta(days=30)
    elif status == "Member":
        status_expire = None
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute("INSERT OR IGNORE INTO users (chat_id, username, balance, status, status_expire) VALUES (?, ?, ?, ?, ?)",
              (chat_id, username, balance, status, status_expire))
    c.execute("UPDATE users SET username=?, balance=?, status=?, status_expire=? WHERE chat_id=?",
              (username, balance, status, status_expire, chat_id))
    conn.commit()
    conn.close()

def update_balance(chat_id, new_balance):
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute("UPDATE users SET balance=? WHERE chat_id=?", (new_balance, chat_id))
    conn.commit()
    conn.close()

def update_status(chat_id, new_status, duration_days=30):
    now = datetime.now()
    if new_status == "Member":
        expire = None
    else:
        expire = now + timedelta(days=duration_days)
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute("UPDATE users SET status=?, status_expire=? WHERE chat_id=?", (new_status, expire, chat_id))
    conn.commit()
    conn.close()

def reset_expired_status():
    now = datetime.now()
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute("UPDATE users SET status='Member', status_expire=NULL WHERE status != 'Member' AND status_expire <= ?", (now,))
    conn.commit()
    conn.close()
    print("[INFO] Semua status yang kadaluarsa telah direset ke Member.")

def get_all_users():
    conn = sqlite3.connect(DB_NAME)
    c = conn.cursor()
    c.execute("SELECT chat_id, username, balance, status, status_expire FROM users")
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
    chatid_db, uname, balance, status, expire = data

    # Reset status jika sudah lewat masa berlaku
    now = datetime.now()
    if expire and datetime.fromisoformat(expire) < now:
        update_status(chatid, "Member")
        data = get_user_data(chatid)
        _, _, balance, status, expire = data

    # Judul berdasarkan apakah user adalah admin
    if user_id == ADMIN_ID:
        title = "🟢 PANEL MEMBER (ADMIN) SCRIPT"
    else:
        title = "🟢 PANEL MEMBER SCRIPT"

    panel_text = f"{title}\n"
    panel_text += f"ChatID     : `{chatid}`\n"
    panel_text += f"Username   : @{uname}\n"
    panel_text += f"Status     : {status}\n"

    if status == "VIP":
        panel_text += f"Saldo      : Unlimited\n"
    else:
        panel_text += f"Saldo      : Rp {balance:,}\n"

    if status != "Member":
        try:
            expire_str = datetime.fromisoformat(expire).strftime("%Y-%m-%d %H:%M")
            panel_text += f"Masa Berlaku: {expire_str}\n"
        except:
            pass

    markup = types.InlineKeyboardMarkup(row_width=1)
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
            types.InlineKeyboardButton("Ubah Status", callback_data='admin_ubah_status'),
            types.InlineKeyboardButton("Perpanjang Status", callback_data='admin_perpanjang_status'),
            types.InlineKeyboardButton("Reset Status", callback_data='admin_reset_status'),
            types.InlineKeyboardButton("Lihat Semua User", callback_data='admin_lihat_semua')
        )
        bot.send_message(chat_id, "MENU ADMIN:\nPilih aksi:", reply_markup=markup)

    elif call.data == 'admin_ubah_status':
        msg = bot.send_message(chat_id, "Kirimkan chat ID dan status baru (Member/Reseller/VIP), contoh: 123456789 Reseller")
        bot.register_next_step_handler(msg, proses_admin_ubah_status)

    elif call.data == 'admin_perpanjang_status':
        msg = bot.send_message(chat_id, "Kirimkan chat ID dan jumlah hari untuk perpanjang, contoh: 123456789 30")
        bot.register_next_step_handler(msg, proses_admin_perpanjang_status)

    elif call.data == 'admin_reset_status':
        msg = bot.send_message(chat_id, "Kirimkan chat ID user yang ingin direset:")
        bot.register_next_step_handler(msg, proses_admin_reset_status)

    elif call.data == 'admin_lihat_semua':
        users = get_all_users()
        if not users:
            bot.send_message(chat_id, "Belum ada user yang terdaftar.")
            return
        list_users = ""
        for uid, uname, bal, stat, exp in users:
            exp_str = f"{datetime.fromisoformat(exp).strftime('%Y-%m-%d %H:%M')}" if exp else "-"
            list_users += f"`{uid}` | @{uname} | {stat} | {exp_str}\n"
        bot.send_message(chat_id, f"Daftar User:\n{list_users}", parse_mode="Markdown")

# === Proses Input ===
def proses_regis_ip(message):
    try:
        ip, days = message.text.strip().split()
        days = int(days)

        user_id = message.from_user.id
        user_data = get_user_data(user_id)
        current_balance = user_data[2]
        status = user_data[3]

        harga_per_hari = 333 if status == "Member" else 250 if status == "Reseller" else 0
        cost = days * harga_per_hari

        if status != "VIP" and current_balance < cost:
            bot.reply_to(message, f"Saldo tidak mencukupi. Diperlukan: Rp {cost:,}")
            tampilkan_panel(message.chat.id, user_id)
            return

        data = baca_permission()
        exp_date = (datetime.now() + timedelta(days=days)).strftime("%Y-%m-%d")
        data.append((ip, exp_date))

        if tulis_permission(data):
            if status != "VIP":
                new_balance = current_balance - cost
                update_balance(user_id, new_balance)
            bot.reply_to(message, f"IP `{ip}` berhasil ditambahkan hingga `{exp_date}`. Biaya: Rp {cost:,}", parse_mode="Markdown")
        tampilkan_panel(message.chat.id, user_id)
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

        user_id = message.from_user.id
        user_data = get_user_data(user_id)
        current_balance = user_data[2]
        status = user_data[3]

        harga_per_hari = 333 if status == "Member" else 250 if status == "Reseller" else 0
        cost = days * harga_per_hari

        if status != "VIP" and current_balance < cost:
            bot.reply_to(message, f"Saldo tidak mencukupi. Diperlukan: Rp {cost:,}")
            tampilkan_panel(message.chat.id, user_id)
            return

        data = baca_permission()
        found = False
        for i, (ip_file, date) in enumerate(data):
            if ip_file == ip:
                exp_date = (datetime.now() + timedelta(days=days)).strftime("%Y-%m-%d")
                data[i] = (ip, exp_date)
                found = True
                break
        if not found:
            bot.reply_to(message, "IP tidak ditemukan dalam daftar.")
            return

        if tulis_permission(data):
            if status != "VIP":
                new_balance = current_balance - cost
                update_balance(user_id, new_balance)
            bot.reply_to(message, f"Tanggal IP `{ip}` diperbarui hingga `{exp_date}`. Biaya: Rp {cost:,}", parse_mode="Markdown")
        tampilkan_panel(message.chat.id, user_id)
    except:
        bot.reply_to(message, "Format salah. Contoh: 192.168.1.10 30")

# === Fungsi Admin ===
def proses_admin_ubah_status(message):
    try:
        chat_id_str, new_status = message.text.strip().split()
        chat_id_user = int(chat_id_str)

        if new_status not in ['Member', 'Reseller', 'VIP']:
            bot.reply_to(message, "Status tidak valid. Harus Member, Reseller, atau VIP.")
            return

        duration = 30  # Default 30 hari
        update_status(chat_id_user, new_status, duration)
        bot.reply_to(message, f"Status user `{chat_id_user}` diubah menjadi `{new_status}`.", parse_mode="Markdown")
        tampilkan_panel(message.chat.id, message.from_user.id)
    except:
        bot.reply_to(message, "Format salah. Contoh: 123456789 Reseller")

def proses_admin_perpanjang_status(message):
    try:
        chat_id_str, days_str = message.text.strip().split()
        chat_id_user = int(chat_id_str)
        days = int(days_str)

        user = get_user_data(chat_id_user)
        if not user:
            bot.reply_to(message, "User tidak ditemukan.")
            return

        current_status = user[3]
        if current_status == 'Member':
            bot.reply_to(message, "Tidak bisa perpanjang status Member.")
            return

        current_expire = datetime.fromisoformat(user[4]) if user[4] else datetime.now()
        new_expire = current_expire + timedelta(days=days)
        update_status(chat_id_user, current_status, (new_expire - datetime.now()).days)

        bot.reply_to(message, f"Masa berlaku user `{chat_id_user}` diperpanjang hingga `{new_expire.strftime('%Y-%m-%d %H:%M')}`.", parse_mode="Markdown")
        tampilkan_panel(message.chat.id, message.from_user.id)
    except:
        bot.reply_to(message, "Format salah. Contoh: 123456789 30")

def proses_admin_reset_status(message):
    try:
        chat_id_user = int(message.text.strip())
        update_status(chat_id_user, "Member")
        bot.reply_to(message, f"Status user `{chat_id_user}` direset ke `Member`.", parse_mode="Markdown")
        tampilkan_panel(message.chat.id, message.from_user.id)
    except:
        bot.reply_to(message, "Format salah. Masukkan chat ID yang valid.")

# === Fungsi Backup Otomatis & Kirim ke Admin ===
BACKUP_FOLDER = "backup"

def kirim_backup_ke_admin():
    try:
        if not os.path.exists(BACKUP_FOLDER):
            os.makedirs(BACKUP_FOLDER)

        waktu_sekarang = datetime.now().strftime("%Y%m%d_%H%M%S")
        zip_name = f"{BACKUP_FOLDER}/backup_{waktu_sekarang}.zip"

        with zipfile.ZipFile(zip_name, 'w') as zipf:
            zipf.write(DB_NAME)

        with open(zip_name, 'rb') as f:
            bot.send_document(ADMIN_ID, f, caption=f"📦 Backup Otomatis: {os.path.basename(zip_name)}")

        print(f"[INFO] Backup berhasil dikirim: {zip_name}")

    except Exception as e:
        print(f"[ERROR] Gagal mengirim backup: {e}")

def jalankan_backup_otomatis():
    while True:
        kirim_backup_ke_admin()
        time.sleep(3 * 60 * 60)  # 3 Jam

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

# === Fungsi Daily Check Status Expired ===
def daily_status_check():
    while True:
        now = datetime.now()
        next_run = (now + timedelta(days=1)).replace(hour=0, minute=0, second=0, microsecond=0)
        time.sleep((next_run - now).total_seconds())

        reset_expired_status()
        print("[INFO] Cek harian selesai.")

threading.Thread(target=daily_status_check, daemon=True).start()

# === Jalankan Bot ===
print("Bot sedang berjalan...")
init_db()
bot.polling(none_stop=True)
