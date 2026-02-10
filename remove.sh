#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

clear
echo -e "${RED}╔══════════════════════════════════════════════╗${NC}"
echo -e "${RED}║           🗑️  FLEX-THEME REMOVER            ║${NC}"
echo -e "${RED}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Ini akan menghapus konfigurasi Flex-Theme dan Plugin Custom.${NC}"
read -p "Apakah kamu yakin? (y/N): " confirm

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    echo ""
    echo -e "${YELLOW}[*] Menghapus plugin custom...${NC}"
    rm -rf "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    mkdir -p "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    
    echo -e "${YELLOW}[*] Mereset .zshrc ke default Oh My Zsh...${NC}"
    cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
    
    echo -e "${YELLOW}[*] Menghapus config powerlevel10k...${NC}"
    rm -f ~/.p10k.zsh
    
    echo ""
    echo -e "${GREEN}✅ Selesai. Terminal sudah bersih kembali ke default.${NC}"
    echo "Silakan restart terminal."
else
    echo "Dibatalkan."
fi
