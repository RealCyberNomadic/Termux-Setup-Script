#!/usr/bin/env bash
SCRIPT_VERSION="3.0.1"  # This will be automatically updated

# Function to compare version numbers
version_compare() {
    local ver1=$1
    local ver2=$2
    
    if [ "$ver1" == "$ver2" ]; then
        echo 0
        return
    fi
    
    IFS='.' read -ra ver1_arr <<< "$ver1"
    IFS='.' read -ra ver2_arr <<< "$ver2"
    
    for ((i=0; i<${#ver1_arr[@]} || i<${#ver2_arr[@]}; i++)); do
        local num1=$((i < ${#ver1_arr[@]} ? ver1_arr[i] : 0))
        local num2=$((i < ${#ver2_arr[@]} ? ver2_arr[i] : 0))
        
        if ((num1 > num2)); then
            echo 1
            return
        elif ((num1 < num2)); then
            echo -1
            return
        fi
    done
    
    echo 0
}

check_updates() {
    local auto_update=${1:-1}  # Default to auto-update (1), set to 0 for check-only
    SCRIPT_URL="https://raw.githubusercontent.com/RealCyberNomadic/Termux-Setup-Script/main/Termux-Setup-Script.sh"

    if ! command -v curl &> /dev/null; then
        echo "[!] curl not found. Installing..."
        pkg install -y curl
    fi

    echo "[+] Checking for updates..."
    remote_content=$(curl -s "$SCRIPT_URL" || echo "")
    
    if [ -z "$remote_content" ]; then
        echo "[!] Failed to fetch remote script. Check your internet connection."
        return 1
    fi

    remote_version=$(echo "$remote_content" | grep -m 1 "SCRIPT_VERSION=" | cut -d '"' -f 2)
    
    if [ -z "$remote_version" ]; then
        echo "[!] Could not determine remote version."
        return 1
    fi

    comparison=$(version_compare "$remote_version" "$SCRIPT_VERSION")
    
    if [ "$comparison" -gt 0 ]; then
        echo -e "\033[1;32m[✓] New Update Available: $remote_version\033[0m"
        echo -e "\033[1;33m[*] Current Version: $SCRIPT_VERSION\033[0m"
        
        if [ "$auto_update" -eq 1 ]; then
            echo -e "\033[1;36m[+] Downloading update...\033[0m"
            if curl -s "$SCRIPT_URL" > "$0.tmp"; then
                sed -i "s/^SCRIPT_VERSION=.*/SCRIPT_VERSION=\"$remote_version\"/" "$0.tmp"
                mv "$0.tmp" "$0"
                chmod +x "$0"
                echo -e "\033[1;32m[✓] Update successful! Restarting script...\033[0m"
                sleep 2
                exec bash "$0" "$@"
            else
                echo -e "\033[1;31m[!] Update failed. Continuing with current version.\033[0m"
                rm -f "$0.tmp"
                return 1
            fi
        else
            echo -e "\033[1;33m[i] Run the script again to auto-update to version $remote_version\033[0m"
        fi
    elif [ "$comparison" -eq 0 ]; then
        echo -e "\033[1;32m[✓] No Update Available - You have the latest version ($SCRIPT_VERSION)\033[0m"
    else
        echo -e "\033[1;33m[i] Local version ($SCRIPT_VERSION) is newer than remote ($remote_version)\033[0m"
    fi
    return 0
}

# check_updates  # This will auto-update if available
# check_updates 0  # This will only check and notify without updating

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
      2 "Hbctool (Asm/Disasm)" \
      3 "Return to Main Menu" 3>&1 1>&2 2>&3)
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
      echo "[+] Installing hbctool..."
      cd $HOME
      wget -O hbctool-0.1.5-96-py3-none-any.whl https://github.com/Kirlif/HBC-Tool/releases/download/96/hbctool-0.1.5-96-py3-none-any.whl
      pip install --force-reinstall hbctool-0.1.5-96-py3-none-any.whl
      ;;
    3) return ;;
  esac
}

blutter_suite() {
  while true; do
    local choice
    if [ -d "$HOME/blutter-termux" ]; then
      choice=$(dialog --title "Blutter Suite" \
        --menu "Blutter is installed. Choose an option:" 15 50 4 \
        1 "APKEditor" \
        2 "Install Blutter" \
        3 "Return to MainMenu" 3>&1 1>&2 2>&3)
    else
      choice=$(dialog --title "Blutter Suite" \
        --menu "Blutter not detected. Choose an option:" 10 50 4 \
        1 "APKEditor" \
        2 "Install Blutter" \
        3 "Return to MainMenu" 3>&1 1>&2 2>&3)
    fi

    clear
    case "$choice" in
      1)
        # APKEditor function with its own loop
        apk_editor_loop() {
          while true; do
            # Check/install APKEditor
            if [ ! -f "/storage/emulated/0/MT2/APKEditor.jar" ]; then
              echo "[*] APKEditor not found. Downloading..."
              mkdir -p $HOME/temp_downloads
              cd $HOME/temp_downloads
              if wget https://github.com/REandroid/APKEditor/releases/download/V1.4.3/APKEditor-1.4.3.jar; then
                echo "[*] Download successful"
                mkdir -p /storage/emulated/0/MT2
                if mv APKEditor-1.4.3.jar /storage/emulated/0/MT2/APKEditor.jar; then
                  echo "[*] File moved and renamed successfully"
                else
                  echo "[!] Failed to move file to /storage/emulated/0/MT2/"
                  echo "[*] The file is available at $HOME/temp_downloads/APKEditor-1.4.3.jar"
                  read -p "Press [Enter] to continue..."
                  cd $HOME && rm -rf $HOME/temp_downloads
                  return 1
                fi
              else
                echo "[!] Download failed. Check your internet connection."
                read -p "Press [Enter] to continue..."
                cd $HOME && rm -rf $HOME/temp_downloads
                return 1
              fi
              cd $HOME && rm -rf $HOME/temp_downloads
            fi

            # Check/install Keystore tools if not present
            if ! command -v keytool &> /dev/null || ! command -v jarsigner &> /dev/null; then
              echo "[*] Installing Java Keystore tools..."
              pkg install -y openjdk-17
            fi

            # Auto-detect APK/XAPK name
            auto_detect_apk() {
              local apk_dir="/storage/emulated/0/MT2/apks"
              mkdir -p "$apk_dir"
              
              local apk_file=$(find "$apk_dir" -maxdepth 1 -type f \( -name "*.apk" -o -name "*.apks" -o -name "*.xapk" \) -print -quit)
              
              if [ -z "$apk_file" ]; then
                echo "[!] No APK/APKS/XAPK files found in $apk_dir"
                echo "Please place your files in $apk_dir first"
                read -p "Press [Enter] to continue..."
                return 1
              fi
              
              basename "${apk_file%.*}"
            }

            # Get APK name automatically
            apk_name=$(auto_detect_apk) || continue

            # APKEditor operations submenu
            apkeditor_choice=$(dialog --title "APKEditor Operations (Detected: $apk_name)" \
              --menu "Choose an operation:" 18 60 7 \
              1 "Merge APKS/XAPK to APK" \
              2 "Create New Keystore" \
              3 "Decompile APK" \
              4 "Compile APK" \
              5 "Refactor APK" \
              6 "Protect APK" \
              7 "Return to Main Menu" 3>&1 1>&2 2>&3)
            
            clear
            case "$apkeditor_choice" in
              1)
                echo "[*] Running APKEditor Merge for $apk_name..."
                cd /storage/emulated/0/MT2/
                [ -f "apks/$apk_name.apk" ] && rm -f "apks/$apk_name.apk"
                
                if [[ -f "apks/$apk_name.xapk" ]]; then
                  echo "[*] XAPK file detected - converting to APKS first..."
                  unzip -q "apks/$apk_name.xapk" -d "apks/$apk_name.apks" || {
                    echo "[!] Failed to extract XAPK"
                    read -p "Press [Enter] to continue..."
                    continue
                  }
                fi
                
                java -jar APKEditor.jar m -i "apks/$apk_name.apks" -o "apks/$apk_name.apk"
                read -p "Press [Enter] to continue..."
                ;;
              2)
                echo "[*] Keystore Creation Wizard"
                mkdir -p "/storage/emulated/0/MT2/apks/"
                
                # Modified keystore filename input to show .jks extension
                KEYSTORE_NAME=$(dialog --inputbox "Enter keystore filename (include .jks extension):" 8 40 "mykeystore_$(date +%s).jks" 3>&1 1>&2 2>&3)
                
                # Ensure the filename ends with .jks
                if [[ ! "$KEYSTORE_NAME" =~ \.jks$ ]]; then
                    KEYSTORE_NAME="${KEYSTORE_NAME}.jks"
                fi
                
                KEY_ALIAS=$(dialog --inputbox "Enter alias:" 8 40 "myalias_$(shuf -i 1000-9999 -n 1)" 3>&1 1>&2 2>&3)
                STORE_PASS=$(dialog --inputbox "Enter store password:" 8 40 "pass_$(shuf -i 1000-9999 -n 1)" 3>&1 1>&2 2>&3)
                KEY_PASS=$(dialog --inputbox "Enter key password:" 8 40 "$STORE_PASS" 3>&1 1>&2 2>&3)
                VALIDITY=$(dialog --inputbox "Enter validity in days:" 8 40 "500000" 3>&1 1>&2 2>&3)
                
                while true; do
                  COUNTRY=$(dialog --inputbox "Enter 2-letter country code (e.g., US):" 8 40 "US" 3>&1 1>&2 2>&3)
                  [[ $COUNTRY =~ ^[A-Z]{2}$ ]] && break
                  dialog --msgbox "Invalid country code. Please enter exactly 2 uppercase letters." 8 40
                done
                
                ORG="Org_$(shuf -i 1-100 -n 1)"
                ORG_UNIT="Dept_$(shuf -i 1-10 -n 1)"
                CITY="City_$(shuf -i 1-50 -n 1)"
                STATE="State_$(shuf -i 1-20 -n 1)"
                
                KEYSTORE_FILE="/storage/emulated/0/MT2/apks/${KEYSTORE_NAME}"
                
                if [ -f "$KEYSTORE_FILE" ]; then
                  dialog --yesno "Keystore already exists. Overwrite?" 7 40 && rm -f "$KEYSTORE_FILE" || continue
                fi
                
                keytool -genkey -v -keystore "$KEYSTORE_FILE" \
                  -alias "$KEY_ALIAS" -keyalg RSA -keysize 2048 -validity "$VALIDITY" \
                  -storepass "$STORE_PASS" -keypass "$KEY_PASS" \
                  -dname "CN=$KEY_ALIAS, OU=$ORG_UNIT, O=$ORG, L=$CITY, ST=$STATE, C=$COUNTRY"
                
                # Create message for dialog
                KEYSTORE_INFO="Keystore created successfully!\n\n"
                KEYSTORE_INFO+="Path: $KEYSTORE_FILE\n"
                KEYSTORE_INFO+="Alias: $KEY_ALIAS\n"
                KEYSTORE_INFO+="Store Password: $STORE_PASS\n"
                KEYSTORE_INFO+="Key Password: $KEY_PASS\n"
                KEYSTORE_INFO+="Validity: $VALIDITY days\n\n"
                KEYSTORE_INFO+="WARNING: Save this information securely!"
                
                dialog --title "Keystore Created" --msgbox "$KEYSTORE_INFO" 15 60
                ;;
              3)
                echo "[*] Running APKEditor Decompile for $apk_name..."
                cd /storage/emulated/0/MT2/
                [ -d "apks/$apk_name" ] && rm -rf "apks/$apk_name"
                java -jar APKEditor.jar d -i "apks/$apk_name.apk" -o "apks/$apk_name/"
                read -p "Press [Enter] to continue..."
                ;;
              4)
                echo "[*] Running APKEditor Compile for $apk_name..."
                cd /storage/emulated/0/MT2/
                [ -f "apks/$apk_name.apk" ] && rm -f "apks/$apk_name.apk"
                java -jar APKEditor.jar b -i "apks/$apk_name/" -o "apks/$apk_name.apk"
                read -p "Press [Enter] to continue..."
                ;;
              5)
                echo "[*] Running APKEditor Refactor for $apk_name..."
                cd /storage/emulated/0/MT2/
                
                if [[ -f "apks/$apk_name.apks" || -f "apks/$apk_name.xapk" ]]; then
                  echo "[*] APKS/XAPK bundle detected - converting to APK first..."
                  [ -f "apks/$apk_name.apk" ] && rm -f "apks/$apk_name.apk"
                  
                  if [[ -f "apks/$apk_name.xapk" ]]; then
                    unzip -q "apks/$apk_name.xapk" -d "apks/$apk_name.apks" || {
                      echo "[!] Failed to extract XAPK"
                      read -p "Press [Enter] to continue..."
                      continue
                    }
                  fi
                  
                  java -jar APKEditor.jar m -i "apks/$apk_name.apks" -o "apks/$apk_name.apk" || {
                    echo "[!] Failed to convert to APK"
                    read -p "Press [Enter] to continue..."
                    continue
                  }
                fi
                
                refactored_name="${apk_name%.*}_refactored.apk"
                [ -f "apks/$refactored_name" ] && rm -f "apks/$refactored_name"
                java -jar APKEditor.jar x -i "apks/$apk_name.apk" -o "apks/$refactored_name"
                read -p "Press [Enter] to continue..."
                ;;
              6)
                echo "[*] Running APKEditor Protect for $apk_name..."
                cd /storage/emulated/0/MT2/
                
                if [[ -f "apks/$apk_name.apks" || -f "apks/$apk_name.xapk" ]]; then
                  echo "[*] APKS/XAPK bundle detected - converting to APK first..."
                  [ -f "apks/$apk_name.apk" ] && rm -f "apks/$apk_name.apk"
                  
                  if [[ -f "apks/$apk_name.xapk" ]]; then
                    unzip -q "apks/$apk_name.xapk" -d "apks/$apk_name.apks" || {
                      echo "[!] Failed to extract XAPK"
                      read -p "Press [Enter] to continue..."
                      continue
                    }
                  fi
                  
                  java -jar APKEditor.jar m -i "apks/$apk_name.apks" -o "apks/$apk_name.apk" || {
                    echo "[!] Failed to convert to APK"
                    read -p "Press [Enter] to continue..."
                    continue
                  }
                fi
                
                protected_name="${apk_name%.*}_protected.apk"
                [ -f "apks/$protected_name" ] && rm -f "apks/$protected_name"
                java -jar APKEditor.jar p -i "apks/$apk_name.apk" -o "apks/$protected_name"
                read -p "Press [Enter] to continue..."
                ;;
              7)
                return
                ;;
            esac
          done
        }
        
        apk_editor_loop
        ;;
      2)
        echo "[*] Installing Blutter..."
        pkg install -y git cmake ninja build-essential pkg-config libicu capstone fmt python ffmpeg
        pip install requests pyelftools
        cd $HOME
        [ -d "$HOME/blutter-termux" ] && rm -rf "$HOME/blutter-termux"
        git clone https://github.com/dedshit/blutter-termux.git
        echo "[*] Blutter installed. Run with: cd ~/blutter-termux && ./blutter"
        read -p "Press [Enter] to continue..."
        ;;
      3)
        return
        ;;
    esac
  done
}

# =========[ Theme Submenu ]=========
submenu() {
  while true; do
    theme_choice=$(dialog --clear --backtitle "Theme Manager" \
      --title "Theme Options" \
      --menu "Select a theme action:" 20 60 10 \
      A "AutoSuggestions + Highlighting Add-ons" \
      B "Return to Main Menu" 3>&1 1>&2 2>&3)

    clear
    case "$theme_choice" in
      A|a)
        echo "Installing Zsh Add-ons..."
        pkg install -y zsh git curl
        export ZSH="$HOME/.oh-my-zsh"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
        ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
        git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
        sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
        ;;
      D|d) return ;;
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
