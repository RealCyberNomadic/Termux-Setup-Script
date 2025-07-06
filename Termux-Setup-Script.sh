#!/usr/bin/env bash

# ===================== VERSION SYSTEM =====================
get_clean_version() {
    # Extract only the version numbers (e.g. "2.1.1") from GitHub
    local version=$(curl -s --max-time 5 \
        "https://raw.githubusercontent.com/RealCyberNomadic/Termux-Setup-Script/main/Termux-Setup-Script.sh" |
        grep -m1 '^SCRIPT_VERSION=' |
        grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')
    echo "${version:-0.0.0}"  # Fallback if offline
}

CLEAN_VERSION=$(get_clean_version)

# ===================== FAILSAFE UPDATE =====================
update_script() {
    echo -e "\033[1;36m[+] Downloading latest version...\033[0m"
    
    # Create secure temporary file
    tmp_file=$(mktemp 2>/dev/null || echo "${0}.tmp")
    
    # Download with validation
    if ! curl -L --max-time 10 --fail \
        "https://raw.githubusercontent.com/RealCyberNomadic/Termux-Setup-Script/main/Termux-Setup-Script.sh" \
        -o "$tmp_file"; then
        echo -e "\033[1;31m[!] Download failed - check internet\033[0m"
        rm -f "$tmp_file"
        return 1
    fi

    # Verify script structure
    if ! [[ -s "$tmp_file" ]] || ! grep -q '^#!/' "$tmp_file"; then
        echo -e "\033[1;31m[!] Invalid script downloaded\033[0m"
        rm -f "$tmp_file"
        return 1
    fi

    # Get the actual new version
    new_version=$(grep -m1 '^SCRIPT_VERSION=' "$tmp_file" | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+')

    # Replace current script
    if chmod +x "$tmp_file" && mv "$tmp_file" "$0"; then
        echo -e "\033[1;32m[✓] Successfully updated to v$new_version\033[0m"
        sleep 1
        exec "$0" "$@"
    else
        echo -e "\033[1;31m[!] Install failed (try: sudo $0)\033[0m"
        return 1
    fi
}

# ===================== STORAGE CHECK =====================
check_termux_storage() {
    if [[ ! -d ~/storage ]]; then
        echo -e "\033[1;33m[*] Setting up Termux storage...\033[0m"
        termux-setup-storage
        sleep 2
    fi
}

# ===================== MAIN MENU =====================
main_menu() {
    while true; do
        # This now shows ONLY clean version (e.g. "v2.1.1")
        main_choice=$(dialog --clear \
            --backtitle "Termux Setup Script v$CLEAN_VERSION" \
            --title "Main Menu" \
            --menu "Choose an option:" 20 60 12 \
            0 "Themes" \
            1 "Blutter Suite" \
            2 "Radare2 Suite" \
            3 "Python Packages + Plugins" \
            4 "Backup Termux Environment" \
            5 "Restore Termux Environment" \
            6 "Wipe All Packages (Caution!)" \
            7 "Update Script Now" \
            8 "MOTD Settings" \
            9 "Exit Script" 3>&1 1>&2 2>&3)

        clear
        case "$main_choice" in
            0) submenu ;;
            1) blutter_suite ;;
            2) radare2_suite ;;
            3)
                echo -e "\033[1;33m[+] Installing packages...\033[0m"
                yes | pkg update -y && yes | pkg upgrade -y
                yes | pkg install -y git curl wget nano vim ruby php nodejs golang clang \
                  zip unzip tar proot neofetch htop openssh nmap net-tools termux-api \
                  termux-tools ffmpeg openjdk-17 tur-repo build-essential binutils
                pip install rich requests spotipy yt_dlp ffmpeg-python mutagen
                echo -e "\033[1;32m[+] Installation complete!\033[0m"
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
                update_script
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

# ===================== STARTUP =====================
# Background version check
{
    current=$CLEAN_VERSION
    latest=$(get_clean_version)
    
    if [[ "$current" != "$latest" ]]; then
        echo -e "\n\033[1;33m[!] New version v$latest available (Option 7 to update)\033[0m"
        sleep 3
    fi
} &

check_termux_storage
main_menu

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

# =========[ Radare2 Suite ]=========
radare2_suite() {
  while true; do
    # Define color codes
    RED='\033[1;31m'
    GREEN='\033[1;32m'
    YELLOW='\033[1;33m'
    ORANGE='\033[38;5;208m'
    BLUE='\033[1;34m'
    RESET='\033[0m'
    
    # Build menu options dynamically
    local menu_options=()
    local option_counter=1

    # Radare2 options
    if [ -d "$HOME/radare2" ]; then
      menu_options+=("$option_counter" "Update Radare2")
      radare_update_option=$option_counter
      ((option_counter++))
    else
      menu_options+=("$option_counter" "Install Radare2")
      radare_install_option=$option_counter
      ((option_counter++))
    fi

    # KeySigner options
    if [ -d "$HOME/keysigner" ]; then
      menu_options+=("$option_counter" "Update KeySigner")
      keysigner_update_option=$option_counter
      ((option_counter++))
    else
      menu_options+=("$option_counter" "Install KeySigner")
      keysigner_install_option=$option_counter
      ((option_counter++))
    fi

    # SigTool options
    if [ -d "$HOME/sigtool" ]; then
      menu_options+=("$option_counter" "Update SigTool")
      sigtool_update_option=$option_counter
      ((option_counter++))
    else
      menu_options+=("$option_counter" "Install SigTool")
      sigtool_install_option=$option_counter
      ((option_counter++))
    fi

    # Always show Hbctool and Return options
    menu_options+=("$option_counter" "Install Hbctool")
    hbctool_option=$option_counter
    ((option_counter++))
    
    menu_options+=("$option_counter" "Return to Main Menu")
    return_option=$option_counter

    # Display menu
    choice=$(dialog --title "Radare2 Suite" \
      --menu "Choose an option:" 20 60 10 \
      "${menu_options[@]}" 3>&1 1>&2 2>&3)
    
    clear
    case "$choice" in
      $radare_install_option)
        echo -e "${BLUE}[+] Installing Radare2...${RESET}"
        pkg install -y build-essential binutils git
        git clone https://github.com/radareorg/radare2 "$HOME/radare2"
        cd "$HOME/radare2" && sh sys/install.sh
        r2pm update && r2pm -ci r2ghidra
        pip install r2pipe
        echo -e "${GREEN}[✔] Radare2 installed successfully!${RESET}"
        sleep 5
        ;;

      $radare_update_option)
        echo -e "${BLUE}[+] Checking for Radare2 Updates...${RESET}"
        cd "$HOME/radare2"
        git remote update
        LOCAL_COMMIT=$(git rev-parse --short HEAD)
        REMOTE_COMMIT=$(git rev-parse --short @{u})

        if [ "$LOCAL_COMMIT" = "$REMOTE_COMMIT" ]; then
          echo -e "${GREEN}[✔] Radare2 is up to date (Version: $LOCAL_COMMIT)${RESET}"
        else
          echo -e "${RED}[!] Update available! Current: $LOCAL_COMMIT → Available: $REMOTE_COMMIT${RESET}"
          echo -e "${ORANGE}[↻] Updating Radare2...${RESET}"
          
          find "$HOME/radare2" -type f -print0 | xargs -0 touch
          git reset --hard origin/master
          git clean -fdx
          git pull
          sh sys/install.sh
          r2pm update && r2pm -ci r2ghidra
          find "$HOME/radare2" -type f -print0 | xargs -0 touch
          
          echo -e "${YELLOW}[✓] Radare2 updated to Version $REMOTE_COMMIT${RESET}"
        fi
        sleep 5
        ;;

      $keysigner_install_option)
        echo -e "${BLUE}[+] Installing KeySigner...${RESET}"
        pkg install -y python openjdk-17 apksigner openssl-tool
        git clone https://github.com/muhammadrizwan87/keysigner.git "$HOME/keysigner"
        cd "$HOME/keysigner" && pip install build && python -m build
        pip install --force-reinstall dist/*.whl
        echo -e "${GREEN}[✔] KeySigner installed successfully!${RESET}"
        sleep 5
        ;;

      $keysigner_update_option)
        echo -e "${BLUE}[+] Checking for KeySigner Updates...${RESET}"
        cd "$HOME/keysigner"
        git remote update
        LOCAL_COMMIT=$(git rev-parse --short HEAD)
        REMOTE_COMMIT=$(git rev-parse --short @{u})

        if [ "$LOCAL_COMMIT" = "$REMOTE_COMMIT" ]; then
          echo -e "${GREEN}[✔] KeySigner is up to date (Version: $LOCAL_COMMIT)${RESET}"
        else
          echo -e "${RED}[!] Update available! Current: $LOCAL_COMMIT → Available: $REMOTE_COMMIT${RESET}"
          echo -e "${ORANGE}[↻] Updating KeySigner...${RESET}"
          
          find "$HOME/keysigner" -type f -print0 | xargs -0 touch
          git reset --hard origin/master
          git clean -fdx
          git pull
          pip install build && python -m build
          pip install --force-reinstall dist/*.whl
          find "$HOME/keysigner" -type f -print0 | xargs -0 touch
          
          echo -e "${YELLOW}[✓] KeySigner updated to Version $REMOTE_COMMIT${RESET}"
        fi
        sleep 5
        ;;

      $sigtool_install_option)
        echo -e "${BLUE}[+] Installing SigTool...${RESET}"
        pkg install -y python openjdk-17 aapt openssl-tool
        git clone https://github.com/muhammadrizwan87/sigtool.git "$HOME/sigtool"
        cd "$HOME/sigtool" && pip install build && python -m build
        pip install --force-reinstall dist/*.whl
        echo -e "${GREEN}[✔] SigTool installed successfully!${RESET}"
        sleep 5
        ;;

      $sigtool_update_option)
        echo -e "${BLUE}[+] Checking for SigTool Updates...${RESET}"
        cd "$HOME/sigtool"
        git remote update
        LOCAL_COMMIT=$(git rev-parse --short HEAD)
        REMOTE_COMMIT=$(git rev-parse --short @{u})

        if [ "$LOCAL_COMMIT" = "$REMOTE_COMMIT" ]; then
          echo -e "${GREEN}[✔] SigTool is up to date (Version: $LOCAL_COMMIT)${RESET}"
        else
          echo -e "${RED}[!] Update available! Current: $LOCAL_COMMIT → Available: $REMOTE_COMMIT${RESET}"
          echo -e "${ORANGE}[↻] Updating SigTool...${RESET}"
          
          find "$HOME/sigtool" -type f -print0 | xargs -0 touch
          git reset --hard origin/master
          git clean -fdx
          git pull
          pip install build && python -m build
          pip install --force-reinstall dist/*.whl
          find "$HOME/sigtool" -type f -print0 | xargs -0 touch
          
          echo -e "${YELLOW}[✓] SigTool updated to Version $REMOTE_COMMIT${RESET}"
        fi
        sleep 5
        ;;

      $hbctool_option)
        echo -e "${BLUE}[+] Installing Hbctool...${RESET}"
        
        # First check if wget is installed
        if ! command -v wget &> /dev/null; then
          echo -e "${ORANGE}[↻] Installing wget...${RESET}"
          pkg install -y wget
        fi

        # Install Hbctool wheel
        if wget -q -O "$HOME/hbctool-0.1.5-96-py3-none-any.whl" https://github.com/Kirlif/HBC-Tool/releases/download/96/hbctool-0.1.5-96-py3-none-any.whl; then
          pip install --force-reinstall "$HOME/hbctool-0.1.5-96-py3-none-any.whl"
          touch "$HOME/hbctool-0.1.5-96-py3-none-any.whl"
          echo -e "${GREEN}[✔] Hbctool installed successfully!${RESET}"
        else
          echo -e "${RED}[-] Failed to download Hbctool${RESET}"
          rm -f "$HOME/hbctool-0.1.5-96-py3-none-any.whl"
        fi
        
        # Install hbclabel.py
        if wget -q -O "$HOME/hbclabel.py" https://raw.githubusercontent.com/Kirlif/Python-Stuff/main/hbclabel.py; then
          chmod +x "$HOME/hbclabel.py"
          touch "$HOME/hbclabel.py"
          echo -e "${GREEN}[✔] hbclabel.py installed successfully!${RESET}"
        else
          echo -e "${RED}[-] Failed to download hbclabel.py${RESET}"
          rm -f "$HOME/hbclabel.py"
        fi
        
        sleep 5
        ;;

      $return_option)
        return
        ;;
    esac
  done
}

# =========[ Blutter Suite ]=========
blutter_suite() {
  while true; do
    local choice
    if [ -d "$HOME/blutter-termux" ]; then
      choice=$(dialog --title "Blutter Suite" \
        --menu "Blutter is installed. Choose an option:" 15 50 4 \
        1 "APKEditor" \
        2 "Install Blutter" \
        3 "Hermes (Decompile & Disasm)" \
        4 "Return to MainMenu" 3>&1 1>&2 2>&3)
    else
      choice=$(dialog --title "Blutter Suite" \
        --menu "Blutter not detected. Choose an option:" 10 50 4 \
        1 "APKEditor" \
        2 "Install Blutter" \
        3 "Hermes (Decompile & Disasm)" \
        4 "Return to MainMenu" 3>&1 1>&2 2>&3)
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
              
              # Show directory contents to user
              echo "[*] Checking for APK/APKS/XAPK files in: $apk_dir"
              echo "[*] Current directory contents:"
              ls -lh "$apk_dir" || {
                echo "[!] Could not list directory contents"
                read -p "Press [Enter] to continue..."
                return 1
              }
              echo ""
              
              local apk_file=$(find "$apk_dir" -maxdepth 1 -type f \( -name "*.apk" -o -name "*.apks" -o -name "*.xapk" \) -print -quit)
              
              if [ -z "$apk_file" ]; then
                echo "[!] No APK/APKS/XAPK files found in $apk_dir"
                echo ""
                echo "To use APKEditor, you need to:"
                echo "1. Place your APK/APKS/XAPK file in this directory:"
                echo "   $apk_dir"
                echo "2. Make sure the file has one of these extensions:"
                echo "   .apk, .apks, or .xapk"
                echo "3. Then run APKEditor again"
                echo ""
                read -p "Press [Enter] to return to menu..."
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
        if [ -d "$HOME/blutter-termux" ]; then
          echo "[*] Installing Hermes-Dec..."
          pkg install -y python pip clang
          cd $HOME && git clone https://github.com/P1sec/hermes-dec.git
          pip install --upgrade git+https://github.com/P1sec/hermes-dec.git
          read -p "Press [Enter] to continue..."
        else
          echo "[!] Blutter not installed. Please install Blutter first."
          read -p "Press [Enter] to continue..."
        fi
        ;;
      4)
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
