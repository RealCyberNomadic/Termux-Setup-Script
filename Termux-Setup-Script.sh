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
      1 "Themes" \
      2 "Blutter Suite" \
      3 "Radare2 Suite" \
      4 "Full Installation" \
      5 "Python Packages + Plugins" \
      6 "Backup Termux Environment" \
      7 "Restore Termux Environment" \
      8 "Wipe All Packages (Caution Dangerous!)" \
      9 "Exit Script" \
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
        echo "[+] Performing Full Installation..."
        pkg update -y && pkg upgrade -y
        pkg install -y git curl wget nano vim python python ruby php nodejs golang clang zip unzip tar proot neofetch htop openssh nmap net-tools termux-api termux-tools ffmpeg build-essential binutils
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
5)
    python_choice=$(dialog --clear --title "Python Version Selection" \
      --menu "Choose Python version to install and activate:\n(Note: 3.12 and 3.13 may not be available on all systems)" 20 60 6 \
      1 "Python 3.10" \
      2 "Python 3.11" \
      3 "Python 3.12 (may not work)" \
      4 "Python 3.13 (may not work)" \
      5 "Return to Main Menu" \
      3>&1 1>&2 2>&3)

    if [[ "$python_choice" == "5" || -z "$python_choice" ]]; then
  continue
fi

    clear
    echo -e "\e[1;33m[+] Installing base packages...\e[0m"
    pkg update -y && pkg upgrade -y
    pkg install -y git curl wget nano vim ruby php nodejs golang clang zip unzip tar proot neofetch htop openssh nmap net-tools termux-api termux-tools ffmpeg openjdk-17 tur-repo

    echo -e "\e[1;31m[!] Removing old Python versions...\e[0m"
    removed_versions=$(pkg uninstall -y python python3 python3.10 python3.11 python3.12 python3.13 2>&1 | grep -Eo 'python[0-9.]*' | uniq)

    case "$python_choice" in
      1) version_pkg="python3.10" ;;
      2) version_pkg="python3.11" ;;
      3) version_pkg="python3.12" ;;
      4) version_pkg="python3.13" ;;
    esac

    echo -e "\e[1;33m[+] Installing $version_pkg...\e[0m"
    if ! pkg install -y "$version_pkg"; then
        echo -e "\e[1;31m[!] Failed to install $version_pkg. It may not be available.\e[0m"
        read -p "Press Enter to return to Main Menu."
        continue
    fi

    # Symlink active python version
    selected_version=$(ls /data/data/com.termux/files/usr/bin/python3.* | grep -o 'python3\.[0-9]\+' | sort -V | tail -n 1)
    ln -sf "/data/data/com.termux/files/usr/bin/$selected_version" "$PREFIX/bin/python"
    ln -sf "/data/data/com.termux/files/usr/bin/$selected_version" "$PREFIX/bin/python3"

    echo -e "\e[1;32m[✓] Active Python version: $selected_version\e[0m"

    echo -e "\e[1;33m[+] Installing Python packages...\e[0m"
    python_bin=$(command -v python)
    pip_user_base=$($python_bin -m site --user-base)/bin
    pip_cmd="$pip_user_base/pip"

    # Ensure pip is available
    if ! command -v pip >/dev/null 2>&1; then
        echo -e "\e[1;31m[!] pip not found. Trying to install via ensurepip...\e[0m"
        $python_bin -m ensurepip --upgrade
        if [ -f "$pip_cmd" ]; then
            ln -sf "$pip_cmd" "$PREFIX/bin/pip"
            chmod +x "$pip_cmd"
        fi
    fi

    if command -v pip >/dev/null 2>&1; then
        pip install rich requests spotipy yt_dlp ffmpeg-python mutagen
        echo -e "\e[1;32m[✓] Installed Python packages:\e[0m"
        echo -e "\e[1;33m- rich\n- requests\n- spotipy\n- yt_dlp\n- ffmpeg-python\n- mutagen\e[0m"
    else
        echo -e "\e[1;31m[!] pip still not available. Package installation skipped.\e[0m"
    fi

    if [ -n "$removed_versions" ]; then
        echo -e "\e[1;31m[!] Removed old Python versions:\e[0m"
        echo -e "\e[1;31m$removed_versions\e[0m"
    fi

    echo
    read -p "Press Enter to return to Main Menu."
    ;;
        6)
        echo "[+] Backing up Termux Environment..."
        tar -zcf /sdcard/termux-backup.tar.gz -C /data/data/com.termux/files ./home ./usr
        ;;
      7)
        echo "[+] Restoring Termux Environment..."
        tar --touch -zxf /sdcard/termux-backup.tar.gz -C /data/data/com.termux/files --recursive-unlink --preserve-permissions
        ;;
      8)
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
        pkg install git python mpv figlet -y
        pip install lolcat
        git clone https://github.com/fikrado/qurxin
        cd qurxin && chmod +x * && sh install.sh
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
