#!/bin/bash

# Warna
CYAN='\033[0;36m'
BLUE='\033[1;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Clear layar
clear

# Banner Installer Flex-Theme
echo -e "${MAGENTA}╔══════════════════════════════════════════════╗${NC}"
echo -e "${MAGENTA}║  ${CYAN}         ⚡ F L E X - T H E M E ⚡          ${MAGENTA}║${NC}"
echo -e "${MAGENTA}║  ${YELLOW}   Ultimate Zsh Setup by Flex-Project     ${MAGENTA}║${NC}"
echo -e "${MAGENTA}╚══════════════════════════════════════════════╝${NC}"
echo ""

# 1. Pertanyaan Custom Name
echo -e "${CYAN}[?] Siapa nama yang ingin ditampilkan di terminal?${NC}"
read -p "    (Default: FlexUser): " CUSTOM_NAME
CUSTOM_NAME=${CUSTOM_NAME:-FlexUser}

echo ""
echo -e "${YELLOW}[*] Mempersiapkan environment untuk: ${GREEN}$CUSTOM_NAME${NC}"

# 2. Install Dependencies (Figlet & Eza)
echo -e "${YELLOW}[*] Mengecek dependencies (figlet & eza)...${NC}"
if command -v pkg &> /dev/null; then
    pkg install figlet eza -y &> /dev/null
    echo -e "${GREEN}    [✓] Paket termux terinstall.${NC}"
elif command -v apt &> /dev/null; then
    sudo apt install figlet -y &> /dev/null
    # Eza biasanya perlu repo khusus di ubuntu, kita skip force install biar ga error
    echo -e "${GREEN}    [✓] Figlet terinstall.${NC}"
fi

# 3. Install Oh My Zsh (Jika belum ada)
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${YELLOW}[*] Menginstall Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    echo -e "${GREEN}[✓] Oh My Zsh sudah terpasang.${NC}"
fi

# 4. Install Powerlevel10k
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    echo -e "${YELLOW}[*] Menginstall Powerlevel10k...${NC}"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" &> /dev/null
fi

# 5. Install Plugin (Hanya yang stabil)
PLUGIN_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
echo -e "${YELLOW}[*] Menginstall Plugin Pilihan...${NC}"

declare -A PLUGINS=(
    ["zsh-syntax-highlighting"]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
    ["zsh-autosuggestions"]="https://github.com/zsh-users/zsh-autosuggestions.git"
    ["zsh-completions"]="https://github.com/zsh-users/zsh-completions.git"
    ["zsh-history-substring-search"]="https://github.com/zsh-users/zsh-history-substring-search.git"
    ["zsh-z"]="https://github.com/agkozak/zsh-z.git"
    ["fzf-tab"]="https://github.com/Aloxaf/fzf-tab.git"
)

for name in "${!PLUGINS[@]}"; do
    url="${PLUGINS[$name]}"
    if [ ! -d "$PLUGIN_DIR/$name" ]; then
        echo -e "    Installing $name..."
        git clone --depth=1 "$url" "$PLUGIN_DIR/$name" &> /dev/null
    else
        echo -e "    [✓] $name sudah ada."
    fi
done

# 6. Membuat .zshrc Baru (The Flex-Theme Core)
echo -e "${YELLOW}[*] Membuat konfigurasi .zshrc...${NC}"

cat > ~/.zshrc << EOF
# ============================================
# ⚡ FLEX-THEME CONFIGURATION
# User: $CUSTOM_NAME
# Generated: $(date)
# ============================================

export ZSH="\$HOME/.oh-my-zsh"
export FLEX_NAME="$CUSTOM_NAME"
export LANG=en_US.UTF-8
export EDITOR='nano'

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# ============================================
# PLUGINS
# ============================================
plugins=(
    git
    git-auto-fetch
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-completions
    zsh-history-substring-search
    zsh-z
    sudo
    extract
    web-search
    colored-man-pages
    history
    command-not-found
    fzf-tab
    docker
    npm
    python
)

source \$ZSH/oh-my-zsh.sh

# ============================================
# FLEX BANNER (MyTermux Style)
# ============================================
term-banner() {
    # Colors
    local C_RESET='\033[0m'
    local C_CYAN='\033[1;36m'
    local C_BLUE='\033[1;34m'
    local C_GREEN='\033[1;32m'
    local C_YELLOW='\033[1;33m'
    local C_MAGENTA='\033[1;35m'
    local C_WHITE='\033[1;37m'
    local C_GREY='\033[1;30m'

    # System Info
    local sys_os=\$(uname -o 2>/dev/null || uname -s)
    local sys_arch=\$(uname -m)
    local sys_kernel=\$(uname -r | cut -d'-' -f1)
    local sys_uptime=\$(uptime -p | sed 's/up //')
    local sys_pkg="Unknown"
    
    # Package count
    if command -v pkg &> /dev/null; then
        sys_pkg="\$(pkg list-installed 2>/dev/null | wc -l) (pkg)"
    elif command -v dpkg &> /dev/null; then
        sys_pkg="\$(dpkg --get-selections | wc -l) (dpkg)"
    fi

    echo ""
    # Name Art (Figlet if available)
    if command -v figlet &> /dev/null; then
        echo -e "\${C_CYAN}"
        figlet -f small "\$FLEX_NAME"
        echo -e "\${C_RESET}"
    else
        echo -e "\${C_CYAN}   ★  \$FLEX_NAME  ★ \${C_RESET}"
        echo ""
    fi

    # THE BOX
    echo -e "\${C_BLUE}╭──────────────────────────────────────────────────╮\${C_RESET}"
    printf "\${C_BLUE}│ \${C_YELLOW}%-10s \${C_WHITE}: \${C_GREEN}%-33s \${C_BLUE}│\n" "OS System" "\$sys_os (\$sys_arch)"
    printf "\${C_BLUE}│ \${C_YELLOW}%-10s \${C_WHITE}: \${C_GREEN}%-33s \${C_BLUE}│\n" "Kernel" "\$sys_kernel"
    printf "\${C_BLUE}│ \${C_YELLOW}%-10s \${C_WHITE}: \${C_GREEN}%-33s \${C_BLUE}│\n" "User" "\$USER"
    printf "\${C_BLUE}│ \${C_YELLOW}%-10s \${C_WHITE}: \${C_GREEN}%-33s \${C_BLUE}│\n" "Uptime" "\$sys_uptime"
    printf "\${C_BLUE}│ \${C_YELLOW}%-10s \${C_WHITE}: \${C_GREEN}%-33s \${C_BLUE}│\n" "Packages" "\$sys_pkg"
    echo -e "\${C_BLUE}├──────────────────────────────────────────────────┤\${C_RESET}"
    printf "\${C_BLUE}│ \${C_GREY}%-46s \${C_BLUE}│\n" "Flex-Theme Loaded • \${#plugins[@]} Plugins"
    echo -e "\${C_BLUE}╰──────────────────────────────────────────────────╯\${C_RESET}"
    echo ""
}

# ============================================
# ALIASES & CONFIG
# ============================================
alias tt='term-banner'
alias c='clear'
alias zshrc='nano ~/.zshrc'
alias reload='source ~/.zshrc'

# Smart LS
if command -v eza &>/dev/null; then
    alias ls='eza --icons --git --group-directories-first'
    alias ll='eza -la --icons --git --group-directories-first'
    alias l='eza -F --icons'
else
    alias ls='ls --color=auto'
    alias ll='ls -la --color=auto'
fi

# Configs
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt SHARE_HISTORY

# FZF
if command -v fzf &>/dev/null; then
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
    zstyle ':completion:*' menu select
    zstyle ':fzf-tab:*' fzf-command fzf
fi

# ============================================
# STARTUP
# ============================================
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if [[ -o interactive ]]; then
    term-banner
fi
EOF

# 7. Setup P10k Config (Default clean config)
if [ ! -f ~/.p10k.zsh ]; then
    echo -e "${YELLOW}[*] Membuat config p10k default...${NC}"
    # Kita buat dummy p10k agar tidak minta wizard di awal, user bisa configure nanti
    cat > ~/.p10k.zsh << 'P10K'
POWERLEVEL9K_MODE=nerdfont-complete
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(os_icon dir vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time)
POWERLEVEL9K_PROMPT_ADD_NEWLINE=true
P10K
fi

echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║           ✨ INSTALLATION COMPLETE ✨        ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}Info:${NC}"
echo -e "  • Nama Custom : $CUSTOM_NAME"
echo -e "  • Command     : Ketik 'tt' untuk melihat banner lagi."
echo -e "  • LS Command  : Menggunakan 'eza' (jika terinstall)."
echo ""
echo -e "${MAGENTA}Silakan restart terminal kamu atau ketik: zsh${NC}"
