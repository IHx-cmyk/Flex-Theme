# ⚡ Flex-Theme Zsh Installer

**Flex-Theme** adalah script instalasi otomatis untuk mengubah tampilan terminal (Zsh) menjadi lebih modern, estetik, dan fungsional.  
Dilengkapi dengan banner bergaya Box (MyTermux Style), plugin manajemen yang stabil, dan custom user name.

---

## ✨ Fitur Utama
- **🎨 Custom Banner Name**  
  Masukkan nama kamu sendiri saat instalasi.
- **📦 Box Info Style**  
  Tampilan informasi sistem yang rapi dalam kotak.
- **🚀 Plugin Terpilih**  
  Hanya menyertakan plugin Zsh yang stabil dan cepat.
- **⚡ Fast**  
  Menggunakan Powerlevel10k dan optimasi config.
- **🛠️ Auto Fix**  
  Otomatis menangani error umum (seperti `zsh-exa` di arsitektur berbeda).
- **📂 Smart LS**  
  Otomatis menggunakan `eza` (modern ls) jika tersedia.

---

## 📸 Preview
```text
   _____  _                              
  |__   || |__   ___  __ _  _ __   _ __  
    | |  | '_ \ / __|/ _` || '_ \ | '_ \ 
    | |  | | | |\__ \ (_| || | | || | | |
    |_|  |_| |_||___/\__,_||_| |_||_| |_|

╭──────────────────────────────────────────────────╮
│ OS System  : Linux Android (aarch64)             │
│ Kernel     : 4.19.113                            │
│ User       : Ihsann                              │
│ Uptime     : 2 hours, 10 minutes                 │
│ Packages   : 420 (pkg)                           │
├──────────────────────────────────────────────────┤
│ Flex-Theme Loaded • 15 Plugins                   │
╰──────────────────────────────────────────────────╯
```


---

## 📥 Cara Install

Download atau clone repository ini
   ```bash
   git clone https://github.com/IHx-cmyk/Flex-Theme
   cd Flex-Theme
   ```
Berikan izin eksekusi:
   ```bash
   chmod +x install.sh
   ```
Jalankan installer:
   ```bash
./install.sh
```
Atau langsung:
   ```bash
bash install.sh
```
Ikuti instruksi di layar (masukkan nama custom kamu).

Restart terminal, atau jalankan:
```Bash
source ~/.zshrc
```
atau
   ```bash
zsh
```
## 🗑 Cara Uninstall
Jika ingin kembali ke tampilan default, jalankan:
   ```bash
bash remove.sh
```
---
## 🔌 Daftar Plugin
Script ini akan menginstall plugin berikut secara otomatis:
- zsh-syntax-highlighting
- zsh-autosuggestions
- zsh-completions
- zsh-history-substring-search
- zsh-z (Navigasi cepat)
- fzf-tab (Tab completion modern)

## 📝 Credits
Author : Ihsann

Theme  : Powerlevel10k by Romkatv

Shell  : Oh My Zsh
