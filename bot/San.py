import telebot
from telebot import types

# Token bot yang baru
TOKEN = '7894185172:AAG4zRBtErBtVzB_Ey-EHSantneoTqwdcU4'

# Inisialisasi bot
bot = telebot.TeleBot(TOKEN)

# Chat ID Admin
ADMIN_CHAT_ID = 576495165

# Simulasi informasi server
IP_VPS = "185.120.45.123"
DOMAIN_VPS = "/root/etc/xray/domain"
REGION_VPS = "Singapore"
ISP_VPS = "DigitalOcean"

# Fungsi notifikasi online saat bot dijalankan
def send_bot_online():
    try:
        bot.send_message(ADMIN_CHAT_ID, "Bot Online ✅")
    except Exception as e:
        print("Gagal mengirim pesan online:", e)

# Handler /start
@bot.message_handler(commands=['start'])
def send_welcome(message):
    chat_id = message.chat.id
    username = message.from_user.username
    if not username:
        username = "Tidak tersedia"

    # Contoh data dummy untuk jumlah akun
    ssh_count = "2 Akun"
    vmess_count = "3 Akun"
    vless_count = "1 Akun"
    trojan_count = "4 Akun"

    # Pesan welcome
    welcome_text = f"""🟢 WELCOME ADMIN
Username : @{username}
ChatID : {chat_id}

🖥️ INFORMASI SERVER 
IP      : {IP_VPS}
Host   : {DOMAIN_VPS}
Region : {REGION_VPS}
ISP    : {ISP_VPS}
-------------------------------
📱 INFORMASI AKUN 
SSH      : {ssh_count}
VMESS    : {vmess_count}
VLESS    : {vless_count}
TROJAN   : {trojan_count}
"""

    markup = types.InlineKeyboardMarkup(row_width=2)
    btn_ssh = types.InlineKeyboardButton("MENU SSH", callback_data='menu_ssh')
    btn_vmess = types.InlineKeyboardButton("MENU VMESS", callback_data='menu_vmess')
    btn_vless = types.InlineKeyboardButton("MENU VLESS", callback_data='menu_vless')
    btn_trojan = types.InlineKeyboardButton("MENU TROJAN", callback_data='menu_trojan')
    btn_system = types.InlineKeyboardButton("SYSTEM SERVICE", callback_data='system_service')
    btn_restart = types.InlineKeyboardButton("RESTART SERVICE", callback_data='restart_service')
    btn_reboot = types.InlineKeyboardButton("REBOOT SERVER", callback_data='reboot_server')

    markup.add(btn_ssh, btn_vmess, btn_vless, btn_trojan, btn_system, btn_restart, btn_reboot)

    bot.send_message(chat_id, welcome_text, reply_markup=markup)

# Handler callback query
@bot.callback_query_handler(func=lambda call: True)
def handle_callback_query(call):
    data = call.data

    if data == 'menu_ssh':
        bot.answer_callback_query(call.id, "SSH Menu Diklik!")
        bot.send_message(call.message.chat.id, "Anda memilih MENU SSH\nFitur belum tersedia. Coming soon!")

    elif data == 'menu_vmess':
        bot.answer_callback_query(call.id, "VMESS Menu Diklik!")
        bot.send_message(call.message.chat.id, "Anda memilih MENU VMESS\nFitur belum tersedia. Coming soon!")

    elif data == 'menu_vless':
        bot.answer_callback_query(call.id, "VLESS Menu Diklik!")
        bot.send_message(call.message.chat.id, "Anda memilih MENU VLESS\nFitur belum tersedia. Coming soon!")

    elif data == 'menu_trojan':
        bot.answer_callback_query(call.id, "TROJAN Menu Diklik!")
        bot.send_message(call.message.chat.id, "Anda memilih MENU TROJAN\nFitur belum tersedia. Coming soon!")

    elif data == 'system_service':
        bot.answer_callback_query(call.id, "SYSTEM SERVICE Diklik!")
        bot.send_message(call.message.chat.id, "Memeriksa status layanan...\n(Fitur akan diimplementasikan nanti)")

    elif data == 'restart_service':
        bot.answer_callback_query(call.id, "RESTART SERVICE Diklik!")
        bot.send_message(call.message.chat.id, "Restarting service...\n(Fitur akan diimplementasikan nanti)")

    elif data == 'reboot_server':
        bot.answer_callback_query(call.id, "REBOOT SERVER Diklik!")
        bot.send_message(call.message.chat.id, "⚠️ Server akan direboot!\n(Fitur akan diimplementasikan nanti)")

# Jalankan bot
if __name__ == '__main__':
    send_bot_online()
    print("Bot berjalan...")
    bot.polling(none_stop=True)
