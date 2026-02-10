import sys
import socket
import json
import urllib.request
import time
import os

# Warna untuk Output Python
CYAN = '\033[0;36m'
GREEN = '\033[0;32m'
RED = '\033[0;31m'
YELLOW = '\033[1;33m'
BLUE = '\033[1;34m'
NC = '\033[0m'

def get_ip_info():
    try:
        url = "http://ip-api.com/json/"
        response = urllib.request.urlopen(url)
        data = json.loads(response.read())
        
        if data['status'] == 'fail':
            print(f"{RED}[!] Gagal mengambil data IP.{NC}")
            return

        print(f"{BLUE}╭──────────────────────────────────────╮{NC}")
        print(f"{BLUE}│ {YELLOW}IP Address {NC}: {GREEN}{data.get('query')} {BLUE}│{NC}")
        print(f"{BLUE}│ {YELLOW}Negara     {NC}: {data.get('country')} ({data.get('countryCode')}) {BLUE}│{NC}")
        print(f"{BLUE}│ {YELLOW}Provinsi   {NC}: {data.get('regionName')} {BLUE}│{NC}")
        print(f"{BLUE}│ {YELLOW}Kota       {NC}: {data.get('city')} {BLUE}│{NC}")
        print(f"{BLUE}│ {YELLOW}ISP        {NC}: {data.get('isp')} {BLUE}│{NC}")
        print(f"{BLUE}│ {YELLOW}Timezone   {NC}: {data.get('timezone')} {BLUE}│{NC}")
        print(f"{BLUE}╰──────────────────────────────────────╯{NC}")
        print(f"\n{CYAN}[Maps]:{NC} https://www.google.com/maps/place/{data.get('lat')},{data.get('lon')}")

    except Exception as e:
        print(f"{RED}[Error]: {str(e)}{NC}")

def scan_ports(target):
    # Port umum yang sering dicek
    common_ports = [21, 22, 23, 25, 53, 80, 110, 443, 3306, 8080, 8000]
    
    print(f"{CYAN}Target IP: {socket.gethostbyname(target)}{NC}\n")
    
    open_ports = []
    try:
        for port in common_ports:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(0.5)
            result = sock.connect_ex((target, port))
            if result == 0:
                print(f"  Port {port}: {GREEN}OPEN ✅{NC}")
                open_ports.append(port)
            else:
                # Uncomment baris bawah jika ingin melihat port tertutup
                # print(f"  Port {port}: {RED}CLOSED ❌{NC}")
                pass
            sock.close()
            
        if not open_ports:
            print(f"\n{RED}[!] Tidak ada port umum yang terbuka.{NC}")
        else:
            print(f"\n{GREEN}[✓] Scan Selesai.{NC}")
            
    except socket.gaierror:
        print(f"{RED}[!] Hostname tidak ditemukan.{NC}")
    except Exception as e:
        print(f"{RED}[Error]: {str(e)}{NC}")

def visual_ping(host):
    # Simulasi visual ping sederhana
    import subprocess
    try:
        while True:
            # Menggunakan ping bawaan sistem tapi diambil angkanya saja
            p = subprocess.Popen(['ping', '-c', '1', '-W', '1', host], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
            out, err = p.communicate()
            
            if p.returncode == 0:
                # Parsing output ping untuk ambil ms (simple parsing)
                output = out.decode('utf-8')
                if "time=" in output:
                    ms = output.split("time=")[1].split(" ")[0]
                    ms_val = float(ms)
                    
                    # Warna berdasarkan kecepatan
                    color = GREEN
                    if ms_val > 100: color = YELLOW
                    if ms_val > 300: color = RED
                    
                    bar = "█" * int(ms_val / 10)
                    if len(bar) > 20: bar = "█" * 20 + "+"
                    
                    print(f"Ping: {color}{ms} ms {NC}| {bar}")
                else:
                    print(f"{GREEN}Connected (No latency info){NC}")
            else:
                print(f"{RED}Request Timeout / Down{NC}")
            
            time.sleep(1)
    except KeyboardInterrupt:
        print(f"\n{YELLOW}[!] Ping Stopped.{NC}")

# Main Controller
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 core_net.py [action] [args]")
        sys.exit(1)

    action = sys.argv[1]

    if action == "ip":
        get_ip_info()
    elif action == "scan":
        if len(sys.argv) < 3:
            print("Target required")
        else:
            scan_ports(sys.argv[2])
    elif action == "ping":
         if len(sys.argv) < 3:
            visual_ping("google.com")
         else:
            visual_ping(sys.argv[2])
