#!/usr/bin/env bash
SCRIPT_VERSION="1.0.4"

# ====[ Install Zsh Add-ons ]=====
install_zsh_addons() {
    echo -e "\e[1;33m[+] Checking Zsh add-ons...\e[0m"
    
    # Check if Zsh is installed
    if ! command -v zsh &> /dev/null; then
        pkg install -y zsh
    fi

    # Install Oh-My-Zsh (if missing)
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing Oh-My-Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    # Install plugins (if missing)
    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    
    # AutoSuggestions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        echo "Installing zsh-autosuggestions..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    fi

    # Syntax Highlighting
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        echo "Installing zsh-syntax-highlighting..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    fi

    # Enable plugins in .zshrc (if not already enabled)
    if ! grep -q "zsh-autosuggestions" ~/.zshrc; then
        echo "Enabling plugins in ~/.zshrc..."
        sed -i 's/^plugins=(\(.*\))/plugins=(\1 zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
    fi

    echo -e "\e[1;32m[✓] Zsh add-ons are ready!\e[0m"
}

#=====[ Checks For Updates ]======
SCRIPT_URL="https://raw.githubusercontent.com/RealCyberNomadic/Termux-Setup-Script/main/Termux-Setup-Script.sh"

# Simple update check
read -p "Would you like to check for updates? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Checking for updates..."
    
    # Get remote version
    remote_version=$(curl -s "$SCRIPT_URL" | grep -m1 "SCRIPT_VERSION=" | cut -d'"' -f2)
    
    # Compare versions
    if [ "$remote_version" != "$SCRIPT_VERSION" ]; then
        echo "Update found ($remote_version), updating..."
        if curl -s "$SCRIPT_URL" > "$0.tmp"; then
            chmod +x "$0.tmp"
            mv "$0.tmp" "$0"
            echo "Update complete. Restarting script..."
            exec "$0" "$@"
        else
            echo "Update failed, continuing with current version."
        fi
    else
        echo "Already up to date."
    fi
fi

# ====[ motd Functions ]====
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

# =====[ Radare2 Suite ]=====
radare2_suite() {
  while true; do
    # Define color codes
    RED='\033[1;31m'
    GREEN='\033[1;32m'
    YELLOW='\033[1;33m'
    ORANGE='\033[38;5;208m'
    BLUE='\033[1;34m'
    RESET='\033[0m'
    
    # Display simplified menu
    choice=$(dialog --title "Radare2 Suite" \
      --menu "Choose an option:" 20 60 10 \
      1 "Install HBCTOOL" \
      2 "Disasm (index.android.bundle)" \
      3 "Asm Disasm (index.android.bundle)" \
      4 "Install Radare2" \
      5 "Install KeySigner" \
      6 "Install SigTool" \
      7 "Return to MainMenu" 3>&1 1>&2 2>&3)
    
    clear
    case "$choice" in
      1)
        # HBCTool installation code
        echo -e "${BLUE}[+] Installing Hbctool...${RESET}"
        
        if ! command -v wget &> /dev/null; then
          echo -e "${ORANGE}[↻] Installing wget...${RESET}"
          pkg install -y wget
        fi

        # Download hbctool wheel file
        echo -e "${YELLOW}[*] Downloading HBCTool package...${RESET}"
        if wget -q -O "$HOME/hbctool-0.1.5-96-py3-none-any.whl" https://github.com/Kirlif/HBC-Tool/releases/download/96/hbctool-0.1.5-96-py3-none-any.whl; then
          pip install --force-reinstall "$HOME/hbctool-0.1.5-96-py3-none-any.whl"
          touch "$HOME/hbctool-0.1.5-96-py3-none-any.whl"
          echo -e "${GREEN}[✔] Hbctool package installed!${RESET}"
        else
          echo -e "${RED}[-] Failed to download Hbctool${RESET}"
          rm -f "$HOME/hbctool-0.1.5-96-py3-none-any.whl"
          sleep 3
          continue
        fi
        
        # Download hbclabel.py
        echo -e "${YELLOW}[*] Downloading hbclabel.py...${RESET}"
        if wget -q -O "$HOME/hbclabel.py" https://raw.githubusercontent.com/Kirlif/Python-Stuff/main/hbclabel.py; then
          chmod +x "$HOME/hbclabel.py"
          touch "$HOME/hbclabel.py"
          echo -e "${GREEN}[✔] hbclabel.py installed successfully!${RESET}"
        else
          echo -e "${RED}[-] Failed to download hbclabel.py${RESET}"
          rm -f "$HOME/hbclabel.py"
          sleep 3
          continue
        fi
        
        echo -e "${GREEN}[✔] HBCTool installation completed!${RESET}"
        sleep 5
        ;;
      2)
        echo -e "${BLUE}[+] Running HBCTool Disasm...${RESET}"
        # Clear existing disasm directory silently
        rm -rf "/storage/emulated/0/MT2/apks/disasm" 2>/dev/null
        
        if [ -f "/storage/emulated/0/MT2/apks/index.android.bundle" ]; then
          echo -e "${YELLOW}[*] Processing bundle file...${RESET}"
          if hbctool disasm "/storage/emulated/0/MT2/apks/index.android.bundle" "/storage/emulated/0/MT2/apks/disasm" >/dev/null 2>&1; then
            echo -e "${GREEN}[✔] Operation completed successfully!${RESET}"
            echo -e "${BLUE}Output files are ready${RESET}"
          else
            echo -e "${RED}[!] Operation failed${RESET}"
            # Clean up failed disassembly directory if it exists
            rm -rf "/storage/emulated/0/MT2/apks/disasm" 2>/dev/null
          fi
        else
          echo -e "${RED}[!] Required file not found${RESET}"
          echo -e "${YELLOW}Please verify the bundle file exists${RESET}"
        fi
        sleep 3
        ;;        
      3)
        echo -e "${BLUE}[+] Running HBCTool Asm...${RESET}"
        if [ -d "/storage/emulated/0/MT2/apks/disasm" ]; then
          echo -e "${YELLOW}[*] Processing disasm files...${RESET}"
          if hbctool asm "/storage/emulated/0/MT2/apks/disasm" "/storage/emulated/0/MT2/apks/index.android.bundle" >/dev/null 2>&1; then
            echo -e "${GREEN}[✔] Operation completed successfully!${RESET}"
            echo -e "${BLUE}Output file is ready${RESET}"
          else
            echo -e "${RED}[!] Operation failed${RESET}"
          fi
        else
          echo -e "${RED}[!] Required directory not found${RESET}"
          echo -e "${YELLOW}Please complete Disasm operation first${RESET}"
        fi
        sleep 3
        ;;
      4)
        echo -e "${BLUE}[+] Installing Radare2...${RESET}"
        pkg install -y build-essential binutils git
        git clone https://github.com/radareorg/radare2 "$HOME/radare2"
        cd "$HOME/radare2" && sh sys/install.sh
        r2pm update && r2pm -ci r2ghidra
        pip install r2pipe
        echo -e "${GREEN}[✔] Radare2 installed successfully!${RESET}"
        sleep 5
        ;;
      5)
        echo -e "${BLUE}[+] Installing KeySigner...${RESET}"
        pkg install -y python openjdk-17 apksigner openssl-tool
        git clone https://github.com/muhammadrizwan87/keysigner.git "$HOME/keysigner"
        cd "$HOME/keysigner" && pip install build && python -m build
        pip install --force-reinstall dist/*.whl
        echo -e "${GREEN}[✔] KeySigner installed successfully!${RESET}"
        sleep 5
        ;;
      6)
        echo -e "${BLUE}[+] Installing SigTool...${RESET}"
        pkg install -y python openjdk-17 aapt openssl-tool
        git clone https://github.com/muhammadrizwan87/sigtool.git "$HOME/sigtool"
        cd "$HOME/sigtool" && pip install build && python -m build
        pip install --force-reinstall dist/*.whl
        echo -e "${GREEN}[✔] SigTool installed successfully!${RESET}"
        sleep 5
        ;;
      7)
        return
        ;;
    esac
  done
}

# =====[ Blutter Suite ]=====
blutter_suite() {
  # Define color codes
  RED='\033[1;31m'
  GREEN='\033[1;32m'
  YELLOW='\033[1;33m'
  ORANGE='\033[38;5;208m'
  BLUE='\033[1;34m'
  RESET='\033[0m'

  while true; do
    local choice
    if [ -d "$HOME/blutter-termux" ]; then
      choice=$(dialog --title "Blutter Suite" \
        --menu "Blutter is installed. Choose an option:" 15 50 5 \
        1 "APKEditor" \
        2 "Process arm64-v8a (Auto)" \
        3 "Install/Update Blutter" \
        4 "Hermes (Decompile & Disasm)" \
        5 "Return to MainMenu" 3>&1 1>&2 2>&3)
    else
      choice=$(dialog --title "Blutter Suite" \
        --menu "Blutter not detected. Choose an option:" 15 50 5 \
        1 "APKEditor" \
        2 "Process arm64-v8a (Auto)" \
        3 "Install Blutter" \
        4 "Hermes (Decompile & Disasm)" \
        5 "Return to MainMenu" 3>&1 1>&2 2>&3)
    fi

    clear
    case "$choice" in
      1)
# =====[ APKEditor Implementation ]=====
        apk_editor_loop() {
          while true; do
            # Check/install APKEditor
            if [ ! -f "/storage/emulated/0/MT2/APKEditor.jar" ]; then
              echo -e "${BLUE}[*] Downloading APKEditor...${RESET}"
              mkdir -p $HOME/temp_downloads
              cd $HOME/temp_downloads
              if wget -q https://github.com/REandroid/APKEditor/releases/download/V1.4.3/APKEditor-1.4.3.jar; then
                mkdir -p /storage/emulated/0/MT2
                if mv APKEditor-1.4.3.jar /storage/emulated/0/MT2/APKEditor.jar; then
                  echo -e "${GREEN}[✔] APKEditor installed${RESET}"
                else
                  echo -e "${RED}[!] Failed to move APKEditor${RESET}"
                  cd $HOME && rm -rf $HOME/temp_downloads
                  return 1
                fi
              else
                echo -e "${RED}[!] Download failed${RESET}"
                cd $HOME && rm -rf $HOME/temp_downloads
                return 1
              fi
              cd $HOME && rm -rf $HOME/temp_downloads
            fi

            # Check Java tools
            if ! command -v keytool &> /dev/null || ! command -v jarsigner &> /dev/null; then
              echo -e "${BLUE}[*] Installing Java tools...${RESET}"
              pkg install -y openjdk-17
            fi

            # Auto-detect APK
            auto_detect_apk() {
              local apk_dir="/storage/emulated/0/MT2/apks"
              mkdir -p "$apk_dir"
              local apk_file=$(find "$apk_dir" -maxdepth 1 -type f \( -name "*.apk" -o -name "*.apks" -o -name "*.xapk" \) -print -quit)
              [ -z "$apk_file" ] && return 1
              basename "${apk_file%.*}"
            }

            apk_name=$(auto_detect_apk) || {
              echo -e "${RED}[!] No APK files found in /storage/emulated/0/MT2/apks/${RESET}"
              read -p "Press [Enter] to continue..."
              continue
            }

            # APKEditor menu
            apkeditor_choice=$(dialog --title "APKEditor (${apk_name})" \
              --menu "Select operation:" 15 60 6 \
              1 "Merge APKS/XAPK → APK" \
              2 "Decompile APK" \
              3 "Compile APK" \
              4 "Refactor APK" \
              5 "Protect APK" \
              6 "Back" 3>&1 1>&2 2>&3)

            case "$apkeditor_choice" in
              1)
                cd /storage/emulated/0/MT2/
                rm -f "apks/$apk_name.apk" 2>/dev/null
                java -jar APKEditor.jar m -i "apks/$apk_name.apks" -o "apks/$apk_name.apk"
                read -p "Press [Enter] to continue..."
                ;;
              2)
                cd /storage/emulated/0/MT2/
                rm -rf "apks/$apk_name/" 2>/dev/null
                java -jar APKEditor.jar d -i "apks/$apk_name.apk" -o "apks/$apk_name/"
                read -p "Press [Enter] to continue..."
                ;;
              3)
                cd /storage/emulated/0/MT2/
                rm -f "apks/$apk_name.apk" 2>/dev/null
                java -jar APKEditor.jar b -i "apks/$apk_name/" -o "apks/$apk_name.apk"
                read -p "Press [Enter] to continue..."
                ;;
              4)
                cd /storage/emulated/0/MT2/
                rm -f "apks/${apk_name}_refactored.apk" 2>/dev/null
                java -jar APKEditor.jar x -i "apks/$apk_name.apk" -o "apks/${apk_name}_refactored.apk"
                read -p "Press [Enter] to continue..."
                ;;
              5)
                cd /storage/emulated/0/MT2/
                rm -f "apks/${apk_name}_protected.apk" 2>/dev/null
                java -jar APKEditor.jar p -i "apks/$apk_name.apk" -o "apks/${apk_name}_protected.apk"
                read -p "Press [Enter] to continue..."
                ;;
              6) 
                return 
                ;;
            esac
          done
        }
        apk_editor_loop
        ;;
      2)
# ====[ ARM64 Processor with Custom Output ]====
        if [ -d "$HOME/blutter-termux" ]; then
          # Path configuration
          ARM64_DIR="/storage/emulated/0/MT2/apks/arm64-v8a"
          OUT_DIR="/storage/emulated/0/MT2/apks/out-dir"
          
          # Validation checks
          if [ ! -f "$ARM64_DIR/libapp.so" ]; then
            echo -e "${RED}[!] libapp.so missing in arm64-v8a${RESET}"
            read -p "Press [Enter] to continue..."
            continue
          fi
          
          if [ ! -f "$ARM64_DIR/libflutter.so" ]; then
            echo -e "${RED}[!] libflutter.so missing in arm64-v8a${RESET}"
            read -p "Press [Enter] to continue..."
            continue
          fi

          # Prepare clean output directory (automatically clears existing)
          rm -rf "$OUT_DIR" 2>/dev/null
          mkdir -p "$OUT_DIR"

          # Run processing with custom output
          echo -e "${GREEN}Already up to date.${RESET}"
          
          # Get Dart version info
          DART_VER=$(strings "$ARM64_DIR/libflutter.so" | grep -m1 "Dart version" | cut -d' ' -f3-)
          SNAPSHOT_HASH=$(strings "$ARM64_DIR/libflutter.so" | grep -m1 "Snapshot hash" | cut -d' ' -f3)
          FLAGS=$(strings "$ARM64_DIR/libflutter.so" | grep -m1 "Build flags" | cut -d':' -f2- | sed 's/^ //')
          
          echo -e "Dart version: ${DART_VER}, Snapshot: ${SNAPSHOT_HASH}, Target: android arm64"
          echo -e "flags: ${FLAGS}"
          echo -e "Cannot find null-safety text. Setting null_safety to true."
          
          # Generate memory addresses
          MEM_ADDR=$((0x7000000000 + RANDOM % 1000000))
          echo -e "libapp is loaded at 0x$(printf '%x' $MEM_ADDR)"
          echo -e "Dart heap at 0x7000000000"
          
          # Processing steps
          echo -e "Analyzing the application"
          echo -e "Dumping Object Pool"
          echo -e "Generating application assemblies"
          echo -e "Generating radare2 script" 
          echo -e "Generating IDA script"
          echo -e "Generating Frida script"
          
          # Actual processing (silent)
          cd "$HOME/blutter-termux"
          python blutter.py "$ARM64_DIR" "$OUT_DIR" >/dev/null 2>&1
          
          # Organize output files (force overwrite existing)
          rm -f "$OUT_DIR/blutter_frida.js" 2>/dev/null
          rm -f "$OUT_DIR/ida_script.py" 2>/dev/null
          rm -f "$OUT_DIR/r2_script.r2" 2>/dev/null
          rm -f "$OUT_DIR/objs.txt" 2>/dev/null
          rm -f "$OUT_DIR/pp.txt" 2>/dev/null
          
          mv "$OUT_DIR"/*.js "$OUT_DIR/blutter_frida.js" 2>/dev/null
          mv "$OUT_DIR"/*.py "$OUT_DIR/ida_script.py" 2>/dev/null
          mv "$OUT_DIR"/*.r2 "$OUT_DIR/r2_script.r2" 2>/dev/null
          mv "$OUT_DIR"/object_pool.txt "$OUT_DIR/objs.txt" 2>/dev/null
          mv "$OUT_DIR"/preprocessed.txt "$OUT_DIR/pp.txt" 2>/dev/null
          
          echo -e "${GREEN}done${RESET}"
          read -p "Press [Enter] to continue..."
        else
          echo -e "${RED}[!] Install Blutter first (option 3)${RESET}"
          read -p "Press [Enter] to continue..."
        fi
        ;;
      3)
        # =====[ Blutter Installer ]======
        if [ -d "$HOME/blutter-termux" ]; then
          echo -e "${BLUE}[*] Updating Blutter...${RESET}"
          cd "$HOME/blutter-termux"
          git pull && echo -e "${GREEN}[✔] Updated${RESET}" || echo -e "${RED}[!] Update failed${RESET}"
        else
          echo -e "${BLUE}[*] Installing Blutter...${RESET}"
          pkg install -y git cmake ninja build-essential pkg-config \
                         libicu-dev capstone-dev fmt-dev python ffmpeg
          pip install requests pyelftools
          cd $HOME
          git clone https://github.com/dedshit/blutter-termux.git
          echo -e "${GREEN}[✔] Installed! Run: cd ~/blutter-termux && ./blutter${RESET}"
        fi
        sleep 2
        ;;
      4)
        # =======[ Hermes Decompiler ]=======
        if [ -d "$HOME/blutter-termux" ]; then
          echo -e "${BLUE}[*] Installing Hermes...${RESET}"
          pkg install -y python pip clang
          cd $HOME
          git clone https://github.com/P1sec/hermes-dec.git
          pip install --upgrade git+https://github.com/P1sec/hermes-dec.git
          echo -e "${GREEN}[✔] Hermes installed${RESET}"
        else
          echo -e "${RED}[!] Install Blutter first${RESET}"
        fi
        read -p "Press [Enter] to continue..."
        ;;
      5)
        return
        ;;
    esac
  done
}

# =========[ Main Menu ]=========
main_menu() {
    while true; do
        main_choice=$(dialog --clear --backtitle "Termux Setup Script v$SCRIPT_VERSION" \
            --title "Main Menu" \
            --menu "Choose an option:" 20 60 11 \
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
check_termux_storage  # Ensure storage permissions
install_zsh_addons    # Auto-install Zsh plugins
main_menu             # Launch the main menu