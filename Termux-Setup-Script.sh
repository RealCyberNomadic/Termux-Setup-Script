#!/usr/bin/env bash

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
      --menu "Choose an option:" 20 60 12 \
      1 "Install Packages + Plugins" \
      2 "Full Installation + Plugins" \
      3 "Wipe All Packages (Danger!)" \
      4 "Radare2 Suite" \
      5 "Termiux Themes" \
      6 "Restore Termux Environment" \
      7 "Backup Termux Environment" \
      8 "Blutter Suite" \
      9 "Exit Script" \
      3>&1 1>&2 2>&3)

    clear
    case "$main_choice" in
      1)
        echo "[+] Installing Packages..."
        pkg update -y && pkg upgrade -y
        pkg install -y git curl wget nano vim python python3 ruby php nodejs golang clang zip unzip tar proot neofetch htop openssh nmap net-tools termux-api termux-tools ffmpeg
        pip install --upgrade pip
        pip install rich requests spotipy yt_dlp ffmpeg-python mutagen
        ;;
      2)
        echo "[+] Performing Full Installation..."
        pkg update -y && pkg upgrade -y
        pkg install -y git curl wget nano vim python python3 ruby php nodejs golang clang zip unzip tar proot neofetch htop openssh nmap net-tools termux-api termux-tools ffmpeg build-essential binutils
        pip install --upgrade pip
        pip install rich requests spotipy yt_dlp ffmpeg-python mutagen

        cd $HOME
        if [ -d "radare2" ]; then
          echo "[!] Updating existing radare2..."
          cd radare2 && git reset --hard && git pull && sh sys/install.sh && cd ..
        else
          git clone https://github.com/radareorg/radare2 && cd radare2 && sh sys/install.sh && cd ..
        fi
        r2pm update && r2pm -ci r2ghidra
        pip install r2pipe

        if [ -d "blutter-termux" ]; then
          echo "[!] Updating existing Blutter..."
          cd blutter-termux && git reset --hard && git pull && cd ..
        else
          git clone https://github.com/dedshit/blutter-termux.git && cd blutter-termux && cd ..
        fi
        echo "[✓] Full installation complete."
        ;;
      3)
        echo "[!] WARNING: This will wipe your Termux environment!"
        read -rp "Type YES to confirm: " confirm_wipe
        if [[ "$confirm_wipe" == "YES" ]]; then
          echo "Resetting Termux..."
          sleep 2
          rm -rf $HOME/* /data/data/com.termux/files/usr/* ~/.bash_history ~/.termux ~/.bashrc ~/.profile ~/.zshrc ~/../usr ~/../home/*
          echo "Wipe complete. Restart Termux to take effect."
          exit 0
        else
          echo "Cancelled."
          sleep 1
        fi
        ;;
      4) radare2_suite ;;
      5) submenu ;;
      6)
        echo "[+] Restoring Termux Environment..."
        tar --touch -zxf /sdcard/termux-backup.tar.gz -C /data/data/com.termux/files --recursive-unlink --preserve-permissions
        ;;
      7)
        echo "[+] Backing up Termux Environment..."
        tar -zcf /sdcard/termux-backup.tar.gz -C /data/data/com.termux/files ./home ./usr
        ;;
      8) blutter_suite ;;
      9)
        echo "Exiting..."
        exit 0
        ;;
      *) echo "Invalid input. Try again." ;;
    esac
  done
}

# =========[ Radare2 Suite ]=========

radare2_suite() {
  if [ -d "$HOME/radare2" ]; then
    choice=$(dialog --title "Radare2 Suite" \
      --menu "Radare2 is installed. Choose an option:" 15 50 2 \
      1 "Reinstall Radare2" \
      2 "Check for Updates" \
      3>&1 1>&2 2>&3)
  else
    choice=$(dialog --title "Radare2 Suite" \
      --menu "Radare2 not detected. Choose an option:" 10 50 1 \
      1 "Install Radare2" \
      3>&1 1>&2 2>&3)
  fi

  clear
  case "$choice" in
    1)
      echo "[+] Installing Radare2..."
      pkg install -y build-essential binutils git
      cd $HOME
      if [ -d "radare2" ]; then
        cd radare2 && git reset --hard && git pull
      else
        git clone https://github.com/radareorg/radare2 && cd radare2
      fi
      sh sys/install.sh
      r2pm update && r2pm -ci r2ghidra
      pip install r2pipe
      read -p "Press Enter to return."
      ;;
    2)
      echo "[+] Checking for Radare2 updates..."
      cd $HOME/radare2
      git fetch
      if [ "$(git rev-parse HEAD)" != "$(git rev-parse @{u})" ]; then
        echo "[!] Update found. Updating..."
        git pull && sh sys/install.sh
        echo "[✓] Updated."
      else
        echo "[✓] Already up to date."
      fi
      read -p "Press Enter to return."
      ;;
    *) echo "Cancelled." ;;
  esac
}

# =========[ Blutter Suite ]=========

blutter_suite() {
  if [ -d "$HOME/blutter-termux" ]; then
    choice=$(dialog --title "Blutter Suite" \
      --menu "Blutter is installed. Choose an option:" 15 50 2 \
      1 "Reinstall Blutter" \
      2 "Check for Updates" \
      3>&1 1>&2 2>&3)
  else
    choice=$(dialog --title "Blutter Suite" \
      --menu "Blutter not detected. Choose an option:" 10 50 1 \
      1 "Install Blutter" \
      3>&1 1>&2 2>&3)
  fi

  clear
  case "$choice" in
    1)
      echo "[+] Installing Blutter..."
      pkg install -y git cmake ninja build-essential pkg-config libicu capstone fmt python ffmpeg
      pip install --upgrade pip
      pip install requests pyelftools
      cd $HOME
      if [ -d "blutter-termux" ]; then
        cd blutter-termux && git reset --hard && git pull
      else
        git clone https://github.com/dedshit/blutter-termux.git && cd blutter-termux
      fi
      echo "[✓] Blutter installed. Run with: cd ~/blutter-termux && ./blutter"
      read -p "Press Enter to return."
      ;;
    2)
      echo "[+] Checking for Blutter updates..."
      cd $HOME/blutter-termux
      git fetch
      if [ "$(git rev-parse HEAD)" != "$(git rev-parse @{u})" ]; then
        echo "[!] Update found. Updating..."
        git pull
        echo "[✓] Updated."
      else
        echo "[✓] Already up to date."
      fi
      read -p "Press Enter to return."
      ;;
    *) echo "Cancelled." ;;
  esac
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
      F "Install Termux-os" \
      G "Return to Main Menu" \
      3>&1 1>&2 2>&3)

    clear
    case "$theme_choice" in
      A|a)
        echo "Installing Engine Theme..."
        git clone https://github.com/imegeek/Theme-Engine
        cd Theme-Engine && chmod +x theme-engine && ./theme-engine && cd ..
        ;;
      B|b)
        echo "Installing T-Header Theme..."
        git clone https://github.com/remo7777/T-Header
        cd T-Header && bash t-header.sh && cd ..
        ;;
      C|c)
        echo "Installing Random Theme..."
        git clone https://github.com/rooted-cyber/Random-Theme
        cd Random-* && bash install.sh && cd ..
        ;;
      D|d)
        echo "Installing Powerlevel10k Zsh Theme..."
        pkg install zsh git -y
        git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git ~/powerlevel10k
        echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
        cp ~/powerlevel10k/config/p10k-robbyrussell.zsh ~/.p10k.zsh 2>/dev/null
        ;;
      E|e)
        echo "Installing Zsh Add-ons..."
        sh -c "$(curl -fsSL https://github.com/Cabbagec/termux-ohmyzsh/raw/master/install.sh)"
        ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
        git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
        sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
        ;;
      F|f)
        git clone https://github.com/h4ck3r0/Termux-os
        cd Termux-os && bash os.sh
        ;;
      G|g) return ;;
      *) echo "Invalid input. Try again." ;;
    esac
  done
}

# =========[ Start Script ]=========

check_termux_storage
main_menu
