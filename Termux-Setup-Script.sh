#!/usr/bin/env bash

=========[ Check and Enable Termux Storage ]=========

check_termux_storage() {
  if [ ! -d "$HOME/storage" ]; then
    termux-setup-storage
  fi
}

=========[ Display Main Menu ]=========

main_menu() {
  while true; do
    main_choice=$(dialog --clear --backtitle "Termux Setup Script" \
    --title "Main Menu" \
    --menu "Choose an option:" 20 60 13 \
    1 "Install Packages + Plugins" \
    2 "Full Installation + Plugins" \
    3 "Wipe All Packages (Danger!)" \
    4 "Radare2 Suite" \
    5 "Open (Themes)" \
    6 "Restore Termux Environment" \
    7 "Backup Termux Environment" \
    8 "Install Blutter" \
    9 "Exit Script" \
    3>&1 1>&2 2>&3)

    clear  
    case "$main_choice" in  
      1)  
        echo "[+] Installing Packages..."  
        apt update && apt upgrade -y  
        pkg update -y && pkg upgrade -y  
        pkg install -y git curl wget nano vim python python3 ruby php nodejs golang clang zip unzip tar proot neofetch htop openssh nmap net-tools termux-api termux-tools  
        pkg install -y python ffmpeg git wget  
        pip install --upgrade pip  
        pip install rich requests spotipy yt_dlp ffmpeg-python mutagen  
        ;;  
      2)  
        echo "[+] Performing Full Installation..."  
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
        
        # Install Blutter as part of full installation
        echo "[+] Installing Blutter..."  
        cd $HOME  
        pkg update -y && pkg upgrade -y  
        pkg install -y git cmake ninja build-essential pkg-config libicu capstone fmt python ffmpeg  
        pip install --upgrade pip  
        pip install requests pyelftools  

        if [ -d "blutter-termux" ]; then  
          echo "[!] Blutter is already installed."  
        else  
          git clone https://github.com/dedshit/blutter-termux.git  
          cd blutter-termux  
          echo "[✓] Blutter installation complete."  
        fi  
        echo "To run Blutter, use: cd ~/blutter-termux && ./blutter"  
        ;;  
      3)  
        echo "[!] WARNING: This will wipe your Termux environment!"  
        echo -n "Type YES to confirm: "  
        read -r confirm_wipe  
        if [[ "$confirm_wipe" == "YES" ]]; then  
          echo "Resetting Termux..."  
          sleep 2  
          rm -rf $HOME/* > /dev/null 2>&1  
          rm -rf /data/data/com.termux/files/usr/* > /dev/null 2>&1  
          rm -rf /data/data/com.termux/files/home/.* > /dev/null 2>&1  
          rm -rf /sdcard/Android/data/com.termux/ > /dev/null 2>&1  
          rm -rf ~/.bash_history ~/.termux ~/.bashrc ~/.profile ~/.zshrc ~/../usr ~/../home/* > /dev/null 2>&1  
          echo "Wipe complete."  
          echo "Please restart Termux to take effect."  
          exit 0  
        else  
          echo "Cancelled."  
          sleep 1  
        fi  
        ;;  
      4)  
        radare2_suite  
        ;;  
      5)  
        submenu  
        ;;  
      6)  
        echo "[+] Restoring Termux Environment..."  
        tar -zxf /sdcard/termux-backup.tar.gz -C /data/data/com.termux/files --recursive-unlink --preserve-permissions  
        ;;  
      7)  
        echo "[+] Backing up Termux Environment..."  
        tar -zcf /sdcard/termux-backup.tar.gz -C /data/data/com.termux/files ./home ./usr  
        ;;  
      8)  
        blutter_suite  
        ;;  
      9)  
        echo "Exiting to Termux..."  
        exit 0  
        ;;  
      *)  
        echo "Invalid input. Please choose between 1 - 9."  
        sleep 2  
        ;;  
    esac

  done
}

=========[ Radare2 Suite ]=========

radare2_suite() {
  while true; do
    radare2_choice=$(dialog --clear --backtitle "Radare2 Suite" \
    --title "Radare2 Suite" \
    --menu "Choose an option:" 20 60 10 \
    1 "Install Radare2" \
    2 "Check for Radare2 Update" \
    3 "Exit Radare2 Suite" \
    3>&1 1>&2 2>&3)

    clear  
    case "$radare2_choice" in  
      1)  
        echo "[+] Installing Radare2 Suite..."  
        cd $HOME  
        pkg update && pkg upgrade -y  
        pkg install -y build-essential binutils wget git  
        if [ -d "$HOME/radare2" ]; then  
          echo "[!] Radare2 is already installed."  
        else  
          git clone https://github.com/radareorg/radare2  
          cd radare2  
          sh sys/install.sh  
          echo "[✓] Radare2 installation complete."  
        fi  
        r2pm update && r2pm -ci r2ghidra  
        pip install r2pipe  
        ;;  
      2)  
        if [ -d "$HOME/radare2" ]; then  
          echo "[!] Checking for Radare2 update..."  
          cd $HOME/radare2  
          git fetch --all  
          LOCAL=$(git rev-parse @)  
          REMOTE=$(git rev-parse origin/master)  
          if [ $LOCAL != $REMOTE ]; then  
            echo "[✓] Radare2 is outdated. Updating..."  
            git reset --hard origin/master  
            sh sys/install.sh  
            echo "[✓] Radare2 updated."  
          else  
            echo "[✓] Radare2 is already up to date."  
          fi  
        else  
          echo "[!] Radare2 is not installed. Please install it first."  
        fi  
        read -n 1 -s -r -p "Press Enter to return to the Radare2 Suite menu..."  # Wait for user input to return  
        ;;  
      3)  
        return  
        ;;  
      *)  
        echo "Invalid input. Please choose between 1 - 3."  
        ;;  
    esac
  done
}

=========[ Blutter Suite ]=========

blutter_suite() {
  while true; do
    blutter_choice=$(dialog --clear --backtitle "Blutter Suite" \
    --title "Blutter Suite" \
    --menu "Choose an option:" 20 60 10 \
    1 "Install Blutter" \
    2 "Check for Blutter Update" \
    3 "Exit Blutter Suite" \
    3>&1 1>&2 2>&3)

    clear  
    case "$blutter_choice" in  
      1)  
        echo "[+] Installing Blutter..."  
        cd $HOME  
        pkg update -y && pkg upgrade -y  
        pkg install -y git cmake ninja build-essential pkg-config libicu capstone fmt python ffmpeg  
        pip install --upgrade pip  
        pip install requests pyelftools  

        if [ -d "blutter-termux" ]; then  
          echo "[!] Blutter is already installed."  
        else  
          git clone https://github.com/dedshit/blutter-termux.git  
          cd blutter-termux  
          echo "[✓] Blutter installation complete."  
        fi  
        echo "To run Blutter, use: cd ~/blutter-termux && ./blutter"  
        read -n 1 -s -r -p "Press Enter to return to the Blutter Suite menu..."  # Wait for user input to return  
        ;;  
      2)  
        if [ -d "$HOME/blutter-termux" ]; then  
          echo "[!] Checking for Blutter update..."  
          cd $HOME/blutter-termux  
          git fetch --all  
          LOCAL=$(git rev-parse @)  
          REMOTE=$(git rev-parse origin/master)  
          if [ $LOCAL != $REMOTE ]; then  
            echo "[✓] Blutter is outdated. Updating..."  
            git reset --hard origin/master  
            echo "[✓] Blutter updated."  
          else  
            echo "[✓] Blutter is already up to date."  
          fi  
        else  
          echo "[!] Blutter is not installed. Please install it first."  
        fi  
        read -n 1 -s -r -p "Press Enter to return to the Blutter Suite menu..."  # Wait for user input to return  
        ;;  
      3)  
        return  
        ;;  
      *)  
        echo "Invalid input. Please choose between 1 - 3."  
        ;;  
    esac
  done
}

=========[ SubMenu: Theme Environments ]=========

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
        pkg install git curl wget -y  
        git clone https://github.com/imegeek/Theme-Engine  
        cd Theme-Engine && chmod +x theme-engine && ./theme-engine && cd ..  
        ;;  
      B|b)  
        echo "Installing T-Header Theme..."  
        apt update && apt upgrade -y  
        apt install git -y  
        git clone https://github.com/remo7777/T-Header  
        cd T-Header && bash t-header.sh && cd ..  
        ;;  
      C|c)  
        echo "Installing Random Theme..."  
        apt update && apt upgrade -y  
        apt install wget git -y  
        apt install --fix-broken -y  
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
        echo "Installing Termux-os..."  
        cd $HOME  
        git clone https://github.com/h4ck3r0/Termux-os  
        cd Termux-os  
        bash os.sh  
        ;;  
      G|g)  
        return  
        ;;  
      *)  
        echo "Invalid input. Please choose between A - G."  
        ;;  
    esac

  done
}

=========[ Start Script ]=========

check_termux_storage
main_menu
