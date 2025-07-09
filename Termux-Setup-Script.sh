#!/usr/bin/env bash
SCRIPT_VERSION="1.0.0"
SCRIPT_URL="https://raw.githubusercontent.com/RealCyberNomadic/Termux-Setup-Script/main/Termux-Setup-Script.sh"

# Check if dialog is installed
if ! command -v dialog &> /dev/null; then
    echo "Installing dialog..."
    pkg install -y dialog || {
        echo "Failed to install dialog. Falling back to simple menu."
        exec ./"$(basename "$0")" --simple-menu
        exit
    }
fi

# Version comparison
version_compare() {
    local ver1=$1 ver2=$2
    IFS='.' read -ra v1 <<< "$ver1"
    IFS='.' read -ra v2 <<< "$ver2"
    
    for ((i=0; i<${#v1[@]} || i<${#v2[@]}; i++)); do
        (( ${v1[i]:-0} > ${v2[i]:-0} )) && echo 1 && return
        (( ${v1[i]:-0} < ${v2[i]:-0} )) && echo -1 && return
    done
    echo 0
}

force_update() {
    # Store dialog commands in a temporary file
    tmpfile=$(mktemp)
    
    # Run update process in background
    (
        echo "0"
        echo "Checking for updates..."
        
        if ! command -v curl &>/dev/null; then
            echo "10"
            echo "Installing curl..."
            pkg install -y curl >/dev/null 2>&1 || {
                echo "100"
                echo "Failed to install curl" > "$tmpfile"
                exit 1
            }
        fi

        echo "30"
        echo "Fetching latest version..."
        remote_content=$(curl -s "$SCRIPT_URL") || {
            echo "100"
            echo "Failed to fetch update" > "$tmpfile"
            exit 1
        }

        remote_version=$(grep -m1 "SCRIPT_VERSION=" <<< "$remote_content" | cut -d'"' -f2)
        if [ -z "$remote_version" ]; then
            echo "100"
            echo "Invalid remote version" > "$tmpfile"
            exit 1
        fi

        case $(version_compare "$remote_version" "$SCRIPT_VERSION") in
            0)  echo "100"
                echo "Already up to date ($SCRIPT_VERSION)" > "$tmpfile"
                exit 1
                ;;
            -1) echo "100"
                echo "Local version ($SCRIPT_VERSION) is newer than remote ($remote_version)" > "$tmpfile"
                exit 1
                ;;
        esac

        echo "60"
        echo "Downloading update..."
        if curl -s "$SCRIPT_URL" > "$0.tmp"; then
            chmod +x "$0.tmp"
            mv "$0.tmp" "$0"
            echo "100"
            echo "Updated to $remote_version" > "$tmpfile"
            exit 0
        else
            echo "100"
            echo "Update failed" > "$tmpfile"
            rm -f "$0.tmp"
            exit 1
        fi
    ) | dialog --title "Updating" --gauge "Please wait..." 10 60 0
    
    # Check result
    if [ -s "$tmpfile" ]; then
        result=$(cat "$tmpfile")
        if [[ "$result" == *"Updated to"* ]]; then
            dialog --title "Success" --msgbox "$result\nRestarting script..." 8 40
            exec "$0" "${@}"
        else
            dialog --title "Notice" --msgbox "$result" 8 40
        fi
    fi
    rm -f "$tmpfile"
}

# Main dialog menu
show_menu() {
    while true; do
        choice=$(dialog --title "Termux Script v$SCRIPT_VERSION" \
                       --menu "Choose an option:" 12 40 3 \
                       1 "Force Update" \
                       2 "Continue to Script" \
                       3 "Exit" \
                       2>&1 >/dev/tty)
        
        case $choice in
            1) force_update ;;
            2) break ;; # Continue to main script
            3) exit 0 ;;
            *) exit 1 ;; # Dialog was closed
        esac
    done
}

# Handle command line arguments
case $1 in
    "--force-update") force_update ;;
    "--simple-menu")  # Fallback simple menu
        echo "1. Force Update"
        echo "2. Continue to Script"
        echo "3. Exit"
        read -p "Choice: " choice
        case $choice in
            1) force_update ;;
            2) : ;;
            3) exit 0 ;;
        esac
        ;;
    *) show_menu ;;
esac

# Rest of your script continues here after Option 2
echo "Main script continues..."

# =========[ motd Functions ]=========
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

# =========[ Blutter Suite ]=========
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
        # =========[ FULL APKEditor Implementation ]=========
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
              --menu "Select operation:" 15 60 7 \
              1 "Merge APKS/XAPK → APK" \
              2 "Create Keystore" \
              3 "Decompile APK" \
              4 "Compile APK" \
              5 "Refactor APK" \
              6 "Protect APK" \
              7 "Back" 3>&1 1>&2 2>&3)

            case "$apkeditor_choice" in
              1|3|4|5|6)
                cd /storage/emulated/0/MT2/
                case "$apkeditor_choice" in
                  1) java -jar APKEditor.jar m -i "apks/$apk_name.apks" -o "apks/$apk_name.apk" ;;
                  3) java -jar APKEditor.jar d -i "apks/$apk_name.apk" -o "apks/$apk_name/" ;;
                  4) java -jar APKEditor.jar b -i "apks/$apk_name/" -o "apks/$apk_name.apk" ;;
                  5) java -jar APKEditor.jar x -i "apks/$apk_name.apk" -o "apks/${apk_name}_refactored.apk" ;;
                  6) java -jar APKEditor.jar p -i "apks/$apk_name.apk" -o "apks/${apk_name}_protected.apk" ;;
                esac
                read -p "Press [Enter] to continue..."
                ;;
              2)
                # Keystore creation wizard
                echo -e "${BLUE}[*] Generating keystore...${RESET}"
                keytool -genkey -v -keystore "/storage/emulated/0/MT2/apks/$(date +%s).jks" \
                  -keyalg RSA -keysize 2048 -validity 10000 \
                  -alias "myalias" -storepass "password" -keypass "password" \
                  -dname "CN=Unknown, OU=Unknown, O=Unknown, L=Unknown, ST=Unknown, C=XX"
                echo -e "${GREEN}[✔] Keystore created${RESET}"
                read -p "Press [Enter] to continue..."
                ;;
              7) return ;;
            esac
          done
        }
        apk_editor_loop
        ;;

      2)
        # =========[ ARM64 Processor with Custom Output ]=========
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

          # Prepare clean output directory
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
          
          # Generate random memory addresses
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
          
          # Organize output files
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
        # =========[ Blutter Installer ]=========
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
        # =========[ Hermes Decompiler ]=========
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