#!/usr/bin/env python3
import socket
import threading
import sys
import getopt
import select

# Konfigurasi Dasar
LISTENING_ADDR = '0.0.0.0'
LISTENING_PORT = 8880  # Default port jika tidak diberikan via argumen
PASS = ''  # Jika ingin tambah autentikasi

BUFLEN = 4096 * 4
TIMEOUT = 60
DEFAULT_HOST = '127.0.0.1:22'  # Target default, bisa diganti sesuai kebutuhan
RESPONSE = b'HTTP/1.1 101 Switching Protocol\r\nUpgrade: websocket\r\nConnection: Upgrade\r\nSec-WebSocket-Accept: foo\r\n\r\n'


class Server(threading.Thread):
    def __init__(self, host, port):
        super().__init__()
        self.running = False
        self.host = host
        self.port = port
        self.threads = []
        self.threads_lock = threading.Lock()
        self.log_lock = threading.Lock()

    def run(self):
        self.soc = socket.socket(socket.AF_INET)
        self.soc.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.soc.settimeout(2)
        try:
            self.soc.bind((self.host, int(self.port)))
            self.soc.listen(5)
            self.running = True
            print(f"[+] Listening on {self.host}:{self.port}")
            while self.running:
                try:
                    client, addr = self.soc.accept()
                    client.setblocking(True)
                    conn = ConnectionHandler(client, self, addr)
                    conn.start()
                    self.add_conn(conn)
                except socket.timeout:
                    continue
        finally:
            self.running = False
            self.soc.close()

    def print_log(self, log):
        with self.log_lock:
            print(log)

    def add_conn(self, conn):
        with self.threads_lock:
            if self.running:
                self.threads.append(conn)

    def remove_conn(self, conn):
        with self.threads_lock:
            if conn in self.threads:
                self.threads.remove(conn)

    def close(self):
        self.running = False
        with self.threads_lock:
            for conn in self.threads:
                conn.close()


class ConnectionHandler(threading.Thread):
    def __init__(self, client, server, addr):
        super().__init__()
        self.client = client
        self.server = server
        self.addr = addr
        self.client_closed = False
        self.target_closed = True
        self.client_buffer = b''
        self.log = f"Connection from {addr}"

    def close(self):
        try:
            if not self.client_closed:
                self.client.shutdown(socket.SHUT_RDWR)
                self.client.close()
            self.client_closed = True
        except:
            pass

        try:
            if not self.target_closed:
                self.target.shutdown(socket.SHUT_RDWR)
                self.target.close()
            self.target_closed = True
        except:
            pass

    def run(self):
        try:
            self.client_buffer = self.client.recv(BUFLEN)

            # Cari header X-Real-Host
            hostPort = self.find_header(self.client_buffer, b'X-Real-Host')
            if not hostPort:
                hostPort = DEFAULT_HOST.encode()

            split = self.find_header(self.client_buffer, b'X-Split')
            if split:
                self.client.recv(BUFLEN)

            passwd = self.find_header(self.client_buffer, b'X-Pass')

            if PASS and passwd != PASS.encode():
                self.client.send(b'HTTP/1.1 400 WrongPass!\r\n\r\n')
            elif hostPort.startswith(b'127.0.0.1') or hostPort.startswith(b'localhost'):
                self.method_connect(hostPort.decode())
            else:
                self.client.send(b'HTTP/1.1 403 Forbidden!\r\n\r\n')

        except Exception as e:
            self.server.print_log(f"{self.log} - Error: {e}")
        finally:
            self.close()
            self.server.remove_conn(self)

    def find_header(self, data, header):
        header_str = header + b': '
        idx = data.find(header_str)
        if idx == -1:
            return b''
        idx += len(header_str)
        end_idx = data.find(b'\r\n', idx)
        if end_idx == -1:
            return b''
        return data[idx:end_idx].strip()

    def connect_target(self, host):
        i = host.find(':')
        if i != -1:
            target_host = host[:i]
            target_port = int(host[i+1:])
        else:
            target_host = host
            target_port = 22  # Port default jika tidak disebutkan

        family, socktype, proto, _, address = socket.getaddrinfo(target_host, target_port)[0]
        self.target = socket.socket(family, socktype, proto)
        self.target.connect(address)
        self.target_closed = False

    def method_connect(self, path):
        self.log += f' - CONNECT {path}'
        self.server.print_log(self.log)

        try:
            self.connect_target(path)
            self.client.sendall(RESPONSE)
            self.do_connect()
        except Exception as e:
            print(f"[!] Connect failed: {e}")

    def do_connect(self):
        while True:
            r, w, e = select.select([self.client, self.target], [], [])
            if self.client in r:
                data = self.client.recv(BUFLEN)
                if not data:
                    break
                self.target.sendall(data)
            if self.target in r:
                data = self.target.recv(BUFLEN)
                if not data:
                    break
                self.client.sendall(data)


def usage():
    print("Usage: ws-stunnel.py -p <port>")
    print("       ws-stunnel.py -b <bind> -p <port>")
    print("Example: ws-stunnel.py -b 0.0.0.0 -p 8880")
    sys.exit(2)


def parse_args(argv):
    global LISTENING_ADDR, LISTENING_PORT
    try:
        opts, args = getopt.getopt(argv, "hb:p:", ["host=", "port="])
    except getopt.GetoptError:
        usage()
    for opt, arg in opts:
        if opt == '-h':
            usage()
        elif opt in ("-b", "--host"):
            LISTENING_ADDR = arg
        elif opt in ("-p", "--port"):
            LISTENING_PORT = int(arg)


if __name__ == '__main__':
    if len(sys.argv) <= 1:
        usage()
    parse_args(sys.argv[1:])
    main()