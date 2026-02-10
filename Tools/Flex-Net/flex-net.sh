#!/bin/bash

# ==========================================
# FLEX-NET: Simple Network Utility
# Author: Ihsann
# Language: Bash + Python
# ==========================================

# Warna
CYAN='\033[0;36m'
BLUE='\033[1;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Pastikan Python terinstall
if ! command -v python3 &> /dev/null; then
    echo "Python3 belum terinstall. Menginstall..."
    pkg install python -y
fi

# Fungsi Banner 
show_banner() {
    clear
    echo -e "${BLUE}╔══════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║  ${CYAN}           🌐 F L E X - N E T             ${BLUE}║${NC}"
    echo -e "${BLUE}║  ${YELLOW}       Network Tools by Flex-Project      ${BLUE}║${NC}"
    echo -e "${BLUE}╚══════════════════════════════════════════════╝${NC}"
    echo ""
}

# Menu Utama
while true; do
    show_banner
    echo -e "${CYAN}Pilih Menu:${NC}"
    echo -e "  ${GREEN}[1]${NC} Cek Info IP Saya (IP Info)"
    echo -e "  ${GREEN}[2]${NC} Port Scanner (Cek Port Terbuka)"
    echo -e "  ${GREEN}[3]${NC} Visual Ping (Cek Kestabilan)"
    echo -e "  ${RED}[0]${NC} Keluar"
    echo ""
    read -p "Masukkan pilihan [0-3]: " choice

    case $choice in
        1)
            echo ""
            echo -e "${YELLOW}[*] Mengambil data IP...${NC}"
            python3 net.py ip
            read -p "Tekan Enter untuk kembali..."
            ;;
        2)
            echo ""
            read -p "Masukkan Host/IP (contoh: google.com): " target
            echo -e "${YELLOW}[*] Scanning port umum pada $target...${NC}"
            python3 net.py scan "$target"
            read -p "Tekan Enter untuk kembali..."
            ;;
        3)
            echo ""
            read -p "Masukkan Host (default: google.com): " host
            host=${host:-google.com}
            echo -e "${YELLOW}[*] Pinging $host (Ctrl+C untuk stop)...${NC}"
            python3 net.py ping "$host"
            ;;
        0)
            echo -e "${GREEN}Terima kasih telah menggunakan Flex-Net!${NC}"
            exit 0
            ;;
        *)
            echo -e "${RED}Pilihan tidak valid!${NC}"
            sleep 1
            ;;
    esac
done
