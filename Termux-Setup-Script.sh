#!/usr/bin/env bash
SCRIPT_VERSION="2.0.5"  # Update this each time you push a new version on GitHub

check_updates() {
  SCRIPT_URL="https://raw.githubusercontent.com/RealCyberNomadic/Termux-Setup-Script/main/Termux-Setup-Script.sh"

  if ! command -v curl &> /dev/null; then
    echo "[!] curl not found. Installing..."
    pkg install -y curl
  fi

  echo "[+] Fetching remote script..."
  remote_content=$(curl -s "$SCRIPT_URL" || echo "")
  
  if [ -z "$remote_content" ]; then
    echo "[!] Failed to fetch remote script. Check your internet connection."
    return 1
  else
    echo "[+] Remote script fetched. Length: ${#remote_content} bytes"
  fi

  remote_version=$(echo "$remote_content" | grep -m 1 "SCRIPT_VERSION=" | cut -d '"' -f 2)
  
  if [ -z "$remote_version" ]; then
    echo "[!] Could not determine remote version."
    echo "Remote content snippet:"
    echo "${remote_content:0:200}"
    return 1
  else
    echo "[+] Remote version found: $remote_version"
  fi

  echo "[*] Local version: $SCRIPT_VERSION"
  
  # Compare versions for updates
  if [ "$remote_version" != "$SCRIPT_VERSION" ]; then
    echo "[*] New version detected ($remote_version). Updating..."
    if curl -s "$SCRIPT_URL" > "$0.tmp"; then
      mv "$0.tmp" "$0"
      chmod +x "$0"
      echo "[✓] Update successful. Restarting script..."
      exec bash "$0"  # Restart the script after update
    else
      echo "[!] Update failed. Continuing with the old version."
      rm -f "$0.tmp"
      return 1
    fi
  else
    echo "[✓] You have the latest version ($SCRIPT_VERSION)."
    return 0
  fi
}

# =========[ Original Functions ]=========
motd_prompt() {
  while true; do
    choice=$(dialog --title "MOTD Settings" --menu "Choose an action:" 15 60 3 \
      1 "Change ASCII Color" \
      2 "Change MOTD Color" \
      3 "Return to Main Menu" 3>&1 1>&2 2>&3)

    case $choice in
      1|2)
        # Color selection menu with exactly the requested colors
        color_choice=$(dialog --title "Select Color" --menu "Choose a color:" 15 60 7 \
          1 "Bright Blue" \
          2 "Bright Red" \
          3 "Bright Yellow" \
          4 "Orange" \
          5 "Bright Green" \
          6 "Cyan" \
          7 "White" 3>&1 1>&2 2>&3)

        case $color_choice in
          1) color='\033[1;34m' ;;     # Bright Blue
          2) color='\033[1;31m' ;;     # Bright Red
          3) color='\033[1;33m' ;;     # Bright Yellow
          4) color='\033[38;5;208m' ;; # Orange (256-color)
          5) color='\033[1;32m' ;;     # Bright Green
          6) color='\033[0;36m' ;;     # Cyan (normal)
          7) color='\033[0;37m' ;;     # White (normal)
          *) color='\033[0m' ;;        # Default
        esac

        if [ "$choice" -eq 1 ]; then
          # Option 1: Replace with colored ASCII
          echo -e "${color}$(cat << 'EOF'
████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗
╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝
   ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝ 
   ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗ 
   ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗
   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝
EOF
)\033[0m" > $PREFIX/etc/motd
          echo "[+] MOTD replaced with colored ASCII art."
        else
          # Option 2: Color existing MOTD
          if [ -f "$PREFIX/etc/motd" ]; then
            motd_content=$(cat $PREFIX/etc/motd)
            echo -e "${color}${motd_content}\033[0m" > $PREFIX/etc/motd
            echo "[+] MOTD color changed."
          else
            echo "[!] No MOTD found to color."
          fi
        fi
        ;;
      3)
        # Return to Main Menu
        return
        ;;
    esac
  done
}

check_termux_storage() {
  if [ ! -d "$HOME/storage" ]; then
    termux-setup-storage
  fi
}

# =========[ Tool Suites ]=========
radare2_suite() {
  local choice
  if [ -d "$HOME/radare2" ]; then
    choice=$(dialog --title "Radare2 Suite" \
      --menu "Radare2 is installed. Choose an option:" 20 60 6 \
      1 "Install Radare2" \
      2 "Check for Updates" \
      3 "KeySigner (APK & Key Tool)" \
      4 "SigTool (Analyzer Pro)" \
      5 "Hbctool (Asm/Disasm)" \
      6 "Return to Main Menu" 3>&1 1>&2 2>&3)
  else
    choice=$(dialog --title "Radare2 Suite" \
      --menu "Radare2 not detected. Choose an option:" 10 50 1 \
      1 "Install Radare2" 3>&1 1>&2 2>&3)
  fi

  clear
  case "$choice" in
    1)
      echo "[+] Installing Radare2..."
      pkg install -y build-essential binutils git
      cd $HOME
      [ -d radare2 ] || git clone https://github.com/radareorg/radare2
      cd radare2 && git reset --hard && git pull && sh sys/install.sh
      r2pm update && r2pm -ci r2ghidra
      pip install r2pipe
      ;;
    2)
      echo "[+] Checking for Radare2 updates..."
      cd $HOME/radare2 && git pull && sh sys/install.sh
      [ -d $HOME/sigtool ] && cd $HOME/sigtool && git pull
      [ -d $HOME/keysigner ] && cd $HOME/keysigner && git pull
      ;;
    3)
      echo "[+] Installing KeySigner..."
      pkg install -y python openjdk-17 apksigner openssl-tool
      cd $HOME && git clone https://github.com/muhammadrizwan87/keysigner.git
      cd keysigner && pip install build && python -m build
      pip install --force-reinstall dist/*.whl
      ;;
    4)
      echo "[+] Installing SigTool..."
      pkg install -y python openjdk-17 aapt openssl-tool
      cd $HOME && git clone https://github.com/muhammadrizwan87/sigtool.git
      cd sigtool && pip install build && python -m build
      pip install --force-reinstall dist/*.whl
      ;;
    5)
      echo "[+] Installing hbctool..."
      cd $HOME
      wget -O hbctool-0.1.5-96-py3-none-any.whl https://github.com/Kirlif/HBC-Tool/releases/download/96/hbctool-0.1.5-96-py3-none-any.whl
      pip install --force-reinstall hbctool-0.1.5-96-py3-none-any.whl
      ;;
    6) return ;;
  esac
}

blutter_suite() {
  local choice
  if [ -d "$HOME/blutter-termux" ]; then
    choice=$(dialog --title "Blutter Suite" \
      --menu "Blutter is installed. Choose an option:" 15 50 4 \
      1 "Install Blutter" \
      2 "Check for Updates" \
      3 "Hermes (Decompile & Disasm)" \
      4 "Return to Main Menu" 3>&1 1>&2 2>&3)
  else
    choice=$(dialog --title "Blutter Suite" \
      --menu "Blutter not detected. Choose an option:" 10 50 1 \
      1 "Install Blutter" 3>&1 1>&2 2>&3)
  fi

  clear
  case "$choice" in
    1)
      echo "[+] Installing Blutter..."
      pkg install -y git cmake ninja build-essential pkg-config libicu capstone fmt python ffmpeg
      pip install requests pyelftools
      cd $HOME
      git clone https://github.com/dedshit/blutter-termux.git
      echo "[✓] Blutter installed. Run with: cd ~/blutter-termux && ./blutter"
      ;;
    2)
      echo "[+] Checking for Blutter updates..."
      cd $HOME/blutter-termux && git pull
      ;;
    3)
      echo "[+] Installing Hermes-Dec..."
      pkg install -y python pip clang
      cd $HOME && git clone https://github.com/P1sec/hermes-dec.git
      pip install --upgrade git+https://github.com/P1sec/hermes-dec.git
      ;;
    4) return ;;
  esac
}

# =========[ Theme Submenu ]=========
submenu() {
  while true; do
    theme_choice=$(dialog --clear --backtitle "Theme Manager" \
      --title "Theme Options" \
      --menu "Select a theme action:" 20 60 10 \
      A "Rxfetch Theme" \
      B "T-Header Theme" \
      C "Termux-OS Theme" \
      D "Powerlevel10k Theme" \
      E "Qurxin + Dependencies Theme" \
      F "AutoSuggestions + Highlighting Add-ons" \
      G "Return to Main Menu" 3>&1 1>&2 2>&3)

    clear
    case "$theme_choice" in
      A|a)
        echo "Installing myTermux Theme..."
        pkg install -y git bc
        cd $HOME && git clone --depth=1 https://github.com/mayTermux/myTermux.git
        cd myTermux && ./install.sh
        ;;
      B|b)
        echo "Installing T-Header Theme..."
        git clone https://github.com/remo7777/T-Header
        cd T-Header && bash t-header.sh
        ;;
      C|c)
        echo "Installing Termux-OS Theme..."
        git clone https://github.com/h4ck3r0/Termux-os
        cd Termux-os && bash os.sh
        ;;
      D|d)
        echo "Installing Powerlevel10k Zsh Theme..."
        pkg install zsh git -y
        git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git ~/powerlevel10k
        echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
        ;;
      E|e)
        echo "Installing Qurxin + Dependencies..."
        pkg update && pkg upgrade -y
        pkg install git python mpv figlet -y
        pip install lolcat
        git clone https://github.com/fikrado/qurxin
        cd qurxin || exit
        mkdir -p ~/.themes
        cp -r Qurxin* ~/.themes/
        figlet Qurxin | lolcat
        ;;
      F|f)
        echo "Installing Zsh Add-ons..."
        pkg install -y zsh git curl
        export ZSH="$HOME/.oh-my-zsh"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
        ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
        git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
        sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
        ;;
      G|g) return ;;
    esac
  done
}

# =========[ Main Menu ]=========
main_menu() {
  while true; do
    main_choice=$(dialog --clear --backtitle "Termux Setup Script v$SCRIPT_VERSION" \
      --title "Main Menu" \
      --menu "Choose an option:" 20 60 12 \
      0 "Themes" \
      1 "Blutter Suite" \
      2 "Radare2 Suite" \
      3 "Python Packages + Plugins" \
      4 "Backup Termux Environment" \
      5 "Restore Termux Environment" \
      6 "Wipe All Packages (Caution!)" \
      7 "Update Script" \
      8 "MOTD Settings" \
      9 "Exit Script" 3>&1 1>&2 2>&3)

    clear
    case "$main_choice" in
      0) submenu ;;
      1) blutter_suite ;;
      2) radare2_suite ;;
      3)
        echo -e "\e[1;33m[+] Installing packages...\e[0m"
        yes | pkg update -y && yes | pkg upgrade -y
        yes | pkg install -y git curl wget nano vim ruby php nodejs golang clang \
          zip unzip tar proot neofetch htop openssh nmap net-tools termux-api \
          termux-tools ffmpeg openjdk-17 tur-repo build-essential binutils
        pip install rich requests spotipy yt_dlp ffmpeg-python mutagen
        echo -e "\e[1;32m[✓] Installation complete!\e[0m"
        sleep 2
        ;;
      4)
        echo "[+] Backing up Termux..."
        tar -zcf /sdcard/termux-backup.tar.gz -C /data/data/com.termux/files ./home ./usr
        ;;
      5)
        echo "[+] Restoring Termux..."
        tar -zxf /sdcard/termux-backup.tar.gz -C /data/data/com.termux/files --recursive-unlink
        ;;
      6)
        echo "[!] WARNING: This will wipe your Termux environment!"
        read -rp "Type YES to confirm: " confirm_wipe
        if [[ "$confirm_wipe" == "YES" ]]; then
          echo "Resetting Termux..."
          rm -rf $HOME/* $HOME/.* /data/data/com.termux/files/usr/*
          exit 0
        else
          echo "Cancelled."
        fi
        ;;
      7) 
        echo "[*] Checking for script updates..."
        check_updates
        result=$?
        if [ "$result" -eq 2 ]; then
          echo "[*] Restarting script with updated version..."
          sleep 2
          exec bash "$0"
        else
          echo "[*] No update needed or update failed. Returning to main menu in 3 seconds..."
          sleep 3
        fi
        ;;
      8) motd_prompt ;;
      9)
        echo "Exiting..."
        exit 0
        ;;
      *) echo "Invalid option" ;;
    esac
  done
}

# =========[ Start Script ]=========
check_termux_storage
main_menu
