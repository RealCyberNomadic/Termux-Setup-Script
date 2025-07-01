#!/usr/bin/env bash
SCRIPT_VERSION="2.0.1"

motd_prompt() {
  prompt_count_file="$HOME/.motd_prompt_count"
  disable_forever_file="$HOME/.motd_never_ask"
  motd_enabled_flag="$HOME/.motd_enabled"

  # Initialize counter if not exists
  [ ! -f "$prompt_count_file" ] && echo 0 > "$prompt_count_file"
  prompt_count=$(cat "$prompt_count_file")

  # Exit early if user chose never to be asked again
  if [ -f "$disable_forever_file" ]; then
    return
  fi

  # Show prompt if under 3 attempts
  if [ "$prompt_count" -lt 3 ]; then
    dialog --title "MOTD Display" \
      --yesno "Do you want to remove the default Termux welcome message (MOTD) and use a custom one?" 8 60
    response=$?

    if [ "$response" -eq 0 ]; then
      echo "[+] Disabling default MOTD..."
      rm -f $PREFIX/etc/motd

      # Clean neofetch/figlet
      sed -i '/^neofetch/d' $HOME/.bashrc 2>/dev/null
      sed -i '/^figlet/d' $HOME/.bashrc 2>/dev/null
      sed -i '/^neofetch/d' $HOME/.profile 2>/dev/null
      sed -i '/^figlet/d' $HOME/.profile 2>/dev/null

      echo "[+] MOTD disabled."

      # Save flag for future color prompts
      touch "$motd_enabled_flag"

      # Let user choose color
      color_choice=$(dialog --title "MOTD Color" --menu "Choose a color for the ASCII MOTD:" 15 50 6 \
        1 "Red" \
        2 "Green" \
        3 "Yellow" \
        4 "Blue" \
        5 "Magenta" \
        6 "Cyan" 3>&1 1>&2 2>&3)

      case $color_choice in
        1) color='\033[1;31m' ;; # Red
        2) color='\033[1;32m' ;; # Green
        3) color='\033[1;33m' ;; # Yellow
        4) color='\033[1;34m' ;; # Blue
        5) color='\033[1;35m' ;; # Magenta
        6) color='\033[1;36m' ;; # Cyan
        *) color='\033[0m' ;;    # Default
      esac

      echo -e "${color}$(cat << 'EOF'
████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗
╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝
   ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝ 
   ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗ 
   ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗
   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝
EOF
)\033[0m" > $PREFIX/etc/motd

    else
      # If user says "No", increment counter
      prompt_count=$((prompt_count + 1))
      echo "$prompt_count" > "$prompt_count_file"

      echo "[+] Keeping MOTD..."
      # If 3rd "No", create a permanent skip flag
      if [ "$prompt_count" -ge 3 ]; then
        touch "$disable_forever_file"
        echo "[!] You will not be asked again."
      fi
    fi
  elif [ -f "$motd_enabled_flag" ]; then
    # If already opted in and ASCII is set, allow color re-selection
    color_choice=$(dialog --title "MOTD Color" --menu "Re-select your MOTD color:" 15 50 6 \
      1 "Red" \
      2 "Green" \
      3 "Yellow" \
      4 "Blue" \
      5 "Magenta" \
      6 "Cyan" 3>&1 1>&2 2>&3)

    case $color_choice in
      1) color='\033[1;31m' ;;
      2) color='\033[1;32m' ;;
      3) color='\033[1;33m' ;;
      4) color='\033[1;34m' ;;
      5) color='\033[1;35m' ;;
      6) color='\033[1;36m' ;;
      *) color='\033[0m' ;;
    esac

    echo -e "${color}$(cat << 'EOF'
████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗
╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝
   ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝ 
   ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗ 
   ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗
   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝
EOF
)\033[0m" > $PREFIX/etc/motd
  fi
}

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
      1 "Themes" \
      2 "Blutter Suite" \
      3 "Radare2 Suite" \
      4 "Python Packages + Plugins" \
      5 "Backup Termux Environment" \
      6 "Restore Termux Environment" \
      7 "Wipe All Packages (Caution Dangerous!)" \
      8 "Exit Script" \
      9 "MOTD Settings" \
      3>&1 1>&2 2>&3)

    clear
    case "$main_choice" in
      1)
        submenu
        ;;
      2)
        blutter_suite
        ;;
      3)
        radare2_suite
        ;;
      4)
        clear
        echo -e "\e[1;33m[+] Updating and Installing all base packages...\e[0m"
        yes | pkg update -y
        yes | pkg upgrade -y
        yes | pkg install -y git curl wget nano vim ruby php nodejs golang clang zip unzip tar proot neofetch htop openssh nmap net-tools termux-api termux-tools ffmpeg openjdk-17 tur-repo build-essential binutils

        echo -e "\e[1;33m[+] Installing Python packages...\e[0m"
        pip install rich requests spotipy yt_dlp ffmpeg-python mutagen

        echo -e "\e[1;33m[✓] Installed Packages:\e[0m"
        echo -e "\e[1;33m- git\n- curl\n- wget\n- nano\n- vim\n- ruby\n- php\n- nodejs\n- golang\n- clang"
        echo -e "- zip\n- unzip\n- tar\n- proot\n- neofetch\n- htop\n- openssh\n- nmap\n- net-tools"
        echo -e "- termux-api\n- termux-tools\n- ffmpeg\n- openjdk-17\n- build-essential\n- binutils\e[0m"

        echo -e "\e[1;33m[✓] Installed Python packages:\e[0m"
        echo -e "\e[1;33m- rich\n- requests\n- spotipy\n- yt_dlp\n- ffmpeg-python\n- mutagen\e[0m"

        echo -e "\e[1;32m[✓] All installations complete. Returning to Main Menu...\e[0m"
        sleep 2
        continue
        ;;
      5)
        echo "[+] Backing up Termux Environment..."
        tar -zcf /sdcard/termux-backup.tar.gz -C /data/data/com.termux/files ./home ./usr
        ;;
      6)
        echo "[+] Restoring Termux Environment..."
        tar --touch -zxf /sdcard/termux-backup.tar.gz -C /data/data/com.termux/files --recursive-unlink --preserve-permissions
        ;;
      7)
        echo "[!] WARNING: This will wipe your Termux environment!"
        read -rp "Type YES to confirm: " confirm_wipe
        if [[ "$confirm_wipe" == "YES" ]]; then
          echo "Resetting Termux..."
          rm -rf $HOME/* $HOME/.* /data/data/com.termux/files/usr/* ~/.bash_history ~/.termux ~/.bashrc ~/.profile ~/.zshrc ~/../usr $PREFIX $HOME && exit
          echo "Wipe complete. Restart Termux to take effect."
          exit 0
        else
          echo "Cancelled."
        fi
        ;;
      8)
        echo "Exiting..."
        exit 0
        ;;
      9)
        motd_prompt
        ;;
      *) echo "Invalid input. Try again." ;;
    esac
  done
}

# =========[ Radare2 Suite ]=========
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
      6 "Return to Main Menu" \
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
      [ -d radare2 ] || git clone https://github.com/radareorg/radare2
      cd radare2 && git reset --hard && git pull && sh sys/install.sh
      r2pm update && r2pm -ci r2ghidra
      pip install r2pipe
      ;;
    2)
      echo "[+] Checking for Radare2 and related tools updates..."
      cd $HOME/radare2 && git pull && sh sys/install.sh
      [ -d $HOME/sigtool ] && cd $HOME/sigtool && git pull && pip install --force-reinstall dist/*.whl
      [ -d $HOME/keysigner ] && cd $HOME/keysigner && git pull && pip install --force-reinstall dist/*.whl
      [ -f $HOME/hbctool-*.whl ] && pip install --force-reinstall $HOME/hbctool-*.whl
      ;;
    3)
      echo "[+] Installing KeySigner..."
      pkg install -y python openjdk-17 apksigner openssl-tool
      pip install --force-reinstall -U git+https://github.com/muhammadrizwan87/keysigner.git
      cd $HOME && git clone https://github.com/muhammadrizwan87/keysigner.git
      cd keysigner && pip install build && python -m build
      pip install --force-reinstall dist/*.whl
      ;;
    4)
      echo "[+] Installing SigTool..."
      pkg install -y python openjdk-17 aapt openssl-tool
      pip install --force-reinstall setuptools
      pip install --force-reinstall -U git+https://github.com/muhammadrizwan87/sigtool.git
      cd $HOME && git clone https://github.com/muhammadrizwan87/sigtool.git
      cd sigtool && pip install build && python -m build
      pip install --force-reinstall dist/*.whl
      ;;
    5)
      echo "[+] Installing hbctool..."
      cd $HOME
      wget -O hbctool-0.1.5-96-py3-none-any.whl https://github.com/Kirlif/HBC-Tool/releases/download/96/hbctool-0.1.5-96-py3-none-any.whl
      pip install --force-reinstall hbctool-0.1.5-96-py3-none-any.whl
      wget -O hbclabel.py https://raw.githubusercontent.com/Kirlif/Python-Stuff/main/hbclabel.py
      ;;
    6) return ;;
  esac
}

# =========[ Blutter Suite ]=========
blutter_suite() {
  local choice
  if [ -d "$HOME/blutter-termux" ]; then
    choice=$(dialog --title "Blutter Suite" \
      --menu "Blutter is installed. Choose an option:" 15 50 4 \
      1 "Install Blutter" \
      2 "Check for Updates" \
      3 "Hermes (Decompile & Disasm)" \
      4 "Return to Main Menu" \
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
      pip install requests pyelftools
      cd $HOME
      git clone https://github.com/dedshit/blutter-termux.git
      echo "[✓] Blutter installed. Run with: cd ~/blutter-termux && ./blutter"
      ;;
    2)
      echo "[+] Checking for Blutter and Hermes updates..."
      cd $HOME/blutter-termux && git pull
      [ -d "$HOME/hermes-dec" ] && cd $HOME/hermes-dec && git pull
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

# =========[ SubMenu: Theme Environments ]=========
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
      G "Return to Main Menu" \
      3>&1 1>&2 2>&3)

    clear
    case "$theme_choice" in
      A|a)
        echo "Installing myTermux Theme..."
        pkg install -y git bc
        cd $HOME && git clone --depth=1 https://github.com/mayTermux/myTermux.git
        cd myTermux && export COLUMNS LINES && ./install.sh
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
        cp ~/powerlevel10k/config/p10k-robbyrussell.zsh ~/.p10k.zsh 2>/dev/null
        ;;
      E|e)
        echo "Installing Qurxin + Dependencies..."
        pkg update && pkg upgrade -y
        pkg install git python mpv figlet -y
        pip install lolcat

        echo "Cloning Qurxin theme..."
        git clone https://github.com/fikrado/qurxin
        cd qurxin || exit

        echo "Installing theme locally to ~/.themes..."
        mkdir -p ~/.themes
        cp -r Qurxin* ~/.themes/

        echo "Qurxin theme installed locally."
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

# =========[ Start Script ]=========
check_termux_storage
main_menu
