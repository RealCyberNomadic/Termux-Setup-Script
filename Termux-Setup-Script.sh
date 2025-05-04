#!/usr/bin/env bash

# =========[ Color Setup ]=========
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
WHITE='\033[1;37m'
CYAN='\033[1;36m'
BLUE='\033[1;34m'
NC='\033[0m'

# =========[ Check and Enable Termux Storage ]=========
check_termux_storage() {
  if [ ! -d "$HOME/storage" ]; then
    termux-setup-storage
  fi
}

# =========[ Display Main Menu ]=========
main_menu() {
  while true; do
    main_choice=$(dialog --clear --backtitle "Termux Setup Script" \
      --title "Main Menu" \
      --menu "Choose an option:" 20 60 10 \
      1 "Install Apt Packages + Plugins" \
      2 "Python Packages + Plugins" \
      3 "Full Installation + Plugins" \
      4 "Wipe All Packages (Danger!)" \
      5 "Radare2 Suite" \
      6 "Open (Themes)" \
      7 "Restore Termux Environment" \
      8 "Backup Termux Environment" \
      9 "Install Blutter" \
      10 "Exit Script" \
      3>&1 1>&2 2>&3)

    clear
    case "$main_choice" in
      1)
        echo -e "${CYAN}[+] Installing Apt Packages...${NC}"
        apt update && apt upgrade -y
        pkg update -y && pkg upgrade -y
        pkg install -y git curl wget nano vim python python3 ruby php nodejs golang clang zip unzip tar proot neofetch htop openssh nmap net-tools termux-api termux-tools
        ;;
      2)
        echo -e "${CYAN}[+] Installing Python Packages...${NC}"
        pkg update && pkg upgrade -y
        pkg install -y python ffmpeg git wget
        pip install --upgrade pip
        pip install rich requests spotipy yt_dlp ffmpeg-python mutagen
        ;;
      3)
        echo -e "${CYAN}[+] Performing Full Installation...${NC}"
        apt update && apt upgrade
        pkg update -y && pkg upgrade -y
        pkg install -y git curl wget nano vim python python3 ruby php nodejs golang clang zip unzip tar proot neofetch htop openssh nmap net-tools termux-api termux-tools
        pkg install -y python ffmpeg git wget
        pip install --upgrade pip
        pip install rich requests spotipy yt_dlp ffmpeg-python mutagen
        pkg install -y build-essential binutils
        git clone https://github.com/radareorg/radare2 && cd radare2 && sh sys/install.sh && cd ..
        r2pm update && r2pm -ci r2ghidra
        pip install r2pipe
        ;;
      4)
        echo -e "${RED}[!] WARNING: This will wipe your Termux environment!${NC}"
        echo -n "Type YES to confirm: "
        read -r confirm_wipe
        if [[ "$confirm_wipe" == "YES" ]]; then
          echo -e "${RED}Resetting Termux...${NC}"
          sleep 2
          rm -rf $HOME/* > /dev/null 2>&1
          rm -rf /data/data/com.termux/files/usr/* > /dev/null 2>&1
          rm -rf /data/data/com.termux/files/home/.* > /dev/null 2>&1
          rm -rf /sdcard/Android/data/com.termux/ > /dev/null 2>&1
          rm -rf ~/.bash_history ~/.termux ~/.bashrc ~/.profile ~/.zshrc ~/../usr ~/../home/* > /dev/null 2>&1
          echo -e "${GREEN}Wipe complete.${NC}"
          echo -e "${YELLOW}Please restart Termux to take effect.${NC}"
          exit 0
        else
          echo -e "${YELLOW}Cancelled.${NC}"
          sleep 1
        fi
        ;;
      5)
        echo -e "${CYAN}[+] Installing Radare2 Suite...${NC}"
        pkg update && pkg upgrade -y
        pkg install -y build-essential binutils wget git
        git clone https://github.com/radareorg/radare2 && cd radare2 && sh sys/install.sh && cd ..
        r2pm update && r2pm -ci r2ghidra
        pip install r2pipe
        ;;
      6)
        submenu
        ;;
      7)
        echo -e "${CYAN}[+] Restoring Termux Environment...${NC}"
        tar -zxf /sdcard/termux-backup.tar.gz -C /data/data/com.termux/files --recursive-unlink --preserve-permissions
        ;;
      8)
        echo -e "${CYAN}[+] Backing up Termux Environment...${NC}"
        tar -zcf /sdcard/termux-backup.tar.gz -C /data/data/com.termux/files ./home ./usr
        ;;
      9)
        echo -e "${CYAN}[+] Installing Blutter...${NC}"
        cd $HOME
        git clone https://github.com/dedshit/blutter-termux.git
        cd blutter-termux
        pip install requests pyelftools
        pkg install -y cmake ninja build-essential pkg-config libicu capstone fmt
        ;;
      10)
        echo -e "${GREEN}Exiting to Termux...${NC}"
        exit 0
        ;;
      *)
        echo -e "${RED}Invalid input. Please choose between 1 - 10.${NC}"
        sleep 2
        ;;
    esac
  done
}

# =========[ SubMenu: Theme Environments ]=========
submenu() {
  while true; do
    theme_choice=$(dialog --clear --backtitle "Theme Manager" \
      --title "Theme Options" \
      --menu "Select a theme action:" 20 60 10 \
      A "Engine Theme" \
      B "T-Header Theme" \
      C "Random Theme" \
      D "Zsh Theme (Powerlevel10k)" \
      E "AutoSuggestions + Highlighting Add-ons" \
      G "Return to Main Menu" \
      3>&1 1>&2 2>&3)

    clear
    case "$theme_choice" in
      A|a)
        echo -e "${CYAN}Installing Engine Theme...${NC}"
        pkg install git curl wget -y
        git clone https://github.com/imegeek/Theme-Engine
        cd Theme-Engine && chmod +x theme-engine && ./theme-engine && cd ..
        ;;
      B|b)
        echo -e "${CYAN}Installing T-Header Theme...${NC}"
        apt update && apt upgrade -y
        apt install git -y
        git clone https://github.com/remo7777/T-Header
        cd T-Header && bash t-header.sh && cd ..
        ;;
      C|c)
        echo -e "${CYAN}Installing Random Theme...${NC}"
        apt update && apt upgrade -y
        apt install wget git -y
        apt install --fix-broken -y
        git clone https://github.com/rooted-cyber/Random-Theme
        cd Random-* && bash install.sh && cd ..
        ;;
      D|d)
        echo -e "${CYAN}Installing Powerlevel10k Zsh Theme...${NC}"
        pkg install zsh git -y
        git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git ~/powerlevel10k
        echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
        cp ~/powerlevel10k/config/p10k-robbyrussell.zsh ~/.p10k.zsh 2>/dev/null
        ;;
      E|e)
        echo -e "${CYAN}Installing Zsh Add-ons...${NC}"
        sh -c "$(curl -fsSL https://github.com/Cabbagec/termux-ohmyzsh/raw/master/install.sh)"
        ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
        git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
        sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
        ;;
      G|g)
        return
        ;;
      *)
        echo -e "${RED}Invalid input. Please choose between A - G.${NC}"
        ;;
    esac
  done
}

# =========[ Start Script ]=========
check_termux_storage
main_menu