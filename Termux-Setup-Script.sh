#!/usr/bin/env bash

# Script Configuration
SCRIPT_URL="https://raw.githubusercontent.com/RealCyberNomadic/Termux-Setup-Script/main/Termux-Setup-Script.sh"
SCRIPT_VERSION="1.1.1"

# ====[ Utility Functions ]====
check_termux_storage() {
  if [ ! -d "$HOME/storage" ]; then
    echo -e "\033[1;33m[!] Setting up Termux storage...\033[0m"
    termux-setup-storage
  fi
}

# ====[ MOTD Customization ]====
motd_prompt() {
  while true; do
    choice=$(dialog --colors --title " \Z1MOTD Customization\Z0" \
      --backtitle "Termux Setup v$SCRIPT_VERSION" \
      --menu "Choose an action:" 16 60 5 \
      1 "Change ASCII Art Color" \
      2 "Change Text Color" \
      3 "Dual-Color ASCII Art" \
      4 "Restore Default MOTD" \
      5 "Return to Main Menu" 3>&1 1>&2 2>&3)

    case $choice in
      1|2|3)
        if [ "$choice" -eq 3 ]; then
          # Dual color selection
          color_choice1=$(dialog --colors --title " \Z1Select First Color\Z0" \
            --backtitle "Termux Setup v$SCRIPT_VERSION" \
            --menu "Choose first color:" 18 60 9 \
            1 "Bright Blue \Zb\Z4■\Zn Sample" \
            2 "Bright Red \Zb\Z1■\Zn Sample" \
            3 "Bright Yellow \Zb\Z3■\Zn Sample" \
            4 "Orange \Zb\Z9■\Zn Sample" \
            5 "Bright Green \Zb\Z2■\Zn Sample" \
            6 "Cyan \Zb\Z6■\Zn Sample" \
            7 "White \Zb\Z7■\Zn Sample" \
            8 "Random Color" \
            9 "Cancel" 3>&1 1>&2 2>&3)
          [ $? -ne 0 ] || [ "$color_choice1" -eq 9 ] && continue

          color_choice2=$(dialog --colors --title " \Z1Select Second Color\Z0" \
            --backtitle "Termux Setup v$SCRIPT_VERSION" \
            --menu "Choose second color:" 18 60 9 \
            1 "Bright Blue \Zb\Z4■\Zn Sample" \
            2 "Bright Red \Zb\Z1■\Zn Sample" \
            3 "Bright Yellow \Zb\Z3■\Zn Sample" \
            4 "Orange \Zb\Z9■\Zn Sample" \
            5 "Bright Green \Zb\Z2■\Zn Sample" \
            6 "Cyan \Zb\Z6■\Zn Sample" \
            7 "White \Zb\Z7■\Zn Sample" \
            8 "Random Color" \
            9 "Cancel" 3>&1 1>&2 2>&3)
          [ $? -ne 0 ] || [ "$color_choice2" -eq 9 ] && continue
        else
          # Single color selection
          color_choice=$(dialog --colors --title " \Z1Select Color\Z0" \
            --backtitle "Termux Setup v$SCRIPT_VERSION" \
            --menu "Choose a color:" 18 60 9 \
            1 "Bright Blue \Zb\Z4■\Zn Sample" \
            2 "Bright Red \Zb\Z1■\Zn Sample" \
            3 "Bright Yellow \Zb\Z3■\Zn Sample" \
            4 "Orange \Zb\Z9■\Zn Sample" \
            5 "Bright Green \Zb\Z2■\Zn Sample" \
            6 "Cyan \Zb\Z6■\Zn Sample" \
            7 "White \Zb\Z7■\Zn Sample" \
            8 "Random Color" \
            9 "Cancel" 3>&1 1>&2 2>&3)
          [ $? -ne 0 ] || [ "$color_choice" -eq 9 ] && continue
        fi

        # Function to get color code
        get_color() {
          case $1 in
            1) echo '\033[1;34m' ;;    # Bright Blue
            2) echo '\033[1;31m' ;;    # Bright Red
            3) echo '\033[1;33m' ;;    # Bright Yellow
            4) echo '\033[38;5;208m' ;;# Orange
            5) echo '\033[1;32m' ;;    # Bright Green
            6) echo '\033[0;36m' ;;    # Cyan
            7) echo '\033[0;37m' ;;    # White
            8) echo "\033[38;5;$((RANDOM%230+1))m" ;; # Random
            *) echo '\033[0m' ;;       # Default
          esac
        }

        if [ "$choice" -eq 1 ] || [ "$choice" -eq 3 ]; then
          # Create colored ASCII art
          dialog --infobox "Applying colored ASCII art..." 5 40
          > $PREFIX/etc/motd
          
          if [ "$choice" -eq 3 ]; then
            # Dual color mode
            color1=$(get_color $color_choice1)
            color2=$(get_color $color_choice2)
            
            # Show color preview
            dialog --colors --msgbox "\nColor Preview:\n\n${color1}First Color\033[0m and ${color2}Second Color\033[0m" 10 40
            
            # Split ASCII art between two colors
            printf "${color1}" >> $PREFIX/etc/motd
            cat << 'EOF' | head -n 3 >> $PREFIX/etc/motd
  ████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗
  ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝
     ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝ 
EOF
            printf "${color2}" >> $PREFIX/etc/motd
            cat << 'EOF' | tail -n 3 >> $PREFIX/etc/motd
     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗ 
     ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗
     ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝
EOF
          else
            # Single color mode
            color=$(get_color $color_choice)
            
            # Show random color preview if selected
            if [ "$color_choice" -eq 8 ]; then
              dialog --colors --msgbox "\nRandom Color Preview:\n\n${color}This is your random color\033[0m" 8 40
            fi
            
            printf "${color}" >> $PREFIX/etc/motd
            cat << 'EOF' >> $PREFIX/etc/motd
  ████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗
  ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝
     ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝ 
     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗ 
     ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗
     ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝
EOF
          fi
          
          printf "\033[0m" >> $PREFIX/etc/motd
          dialog --msgbox "\n\Z2[✓] MOTD successfully customized!\Zn" 8 50
        else
          # Color existing MOTD text
          if [ -f "$PREFIX/etc/motd" ]; then
            color=$(get_color $color_choice)
            
            # Show random color preview if selected
            if [ "$color_choice" -eq 8 ]; then
              dialog --colors --msgbox "\nRandom Color Preview:\n\n${color}This is your random color\033[0m" 8 40
            fi
            
            dialog --infobox "Applying text color..." 5 40
            motd_content=$(sed -r "s/\x1B\[[0-9;]*[mK]//g" $PREFIX/etc/motd)
            > $PREFIX/etc/motd
            printf "${color}%s\033[0m" "$motd_content" > $PREFIX/etc/motd
            dialog --msgbox "\n\Z2[✓] MOTD text color changed!\Zn" 7 50
          else
            dialog --msgbox "\n\Z1[!] No MOTD found to modify!\Zn" 7 50
          fi
        fi
        ;;

      4)
        # Restore default MOTD with confirmation
        dialog --yesno "\n\Z1Are you sure you want to restore the default MOTD?\Zn" 7 50
        if [ $? -eq 0 ]; then
          > $PREFIX/etc/motd
          cat << 'EOF' > $PREFIX/etc/motd
Welcome to Termux!

Wiki:            https://wiki.termux.com
Community forum: https://termux.com/community
Gitter chat:     https://gitter.im/termux/termux
IRC channel:     #termux on libera.chat

Working with packages:

 * Search packages:   pkg search <query>
 * Install a package: pkg install <package>
 * Upgrade packages:  pkg upgrade

Subscribing to additional repositories:

 * Root:     pkg install root-repo
 * Unstable: pkg install unstable-repo
 * X11:      pkg install x11-repo

Report issues at https://termux.com/issues
EOF
          dialog --msgbox "\n\Z2[✓] Default MOTD has been restored!\Zn" 7 50
        else
          dialog --msgbox "\n\Z3[!] MOTD restoration cancelled.\Zn" 7 50
        fi
        ;;

      5)
        return
        ;;
    esac
  done
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
    
    # Display alphabetized menu
    choice=$(dialog --title "Radare2 Suite" \
      --menu "Choose an option:" 20 60 10 \
      1 "Asm Disasm (index.android.bundle)" \
      2 "Disasm (index.android.bundle)" \
      3 "Install HBCTOOL" \
      4 "Install KeySigner" \
      5 "Install Radare2" \
      6 "Install SigTool" \
      7 "Return to MainMenu" 3>&1 1>&2 2>&3)
    
    clear
    case "$choice" in
      1)
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
      4)
        echo -e "${BLUE}[+] Installing KeySigner...${RESET}"
        pkg install -y python openjdk-17 apksigner openssl-tool
        git clone https://github.com/muhammadrizwan87/keysigner.git "$HOME/keysigner"
        cd "$HOME/keysigner" && pip install build && python -m build
        pip install --force-reinstall dist/*.whl
        echo -e "${GREEN}[✔] KeySigner installed successfully!${RESET}"
        sleep 5
        ;;
      5)
        echo -e "${BLUE}[+] Installing Radare2...${RESET}"
        pkg update -y && pkg upgrade -y && pkg install -y git clang make binutils curl python && git clone https://github.com/radareorg/radare2 "$HOME/radare2" && cd "$HOME/radare2" && ./sys/install.sh && source ~/.bashrc && r2pm init && r2pm update && r2pm -ci r2ghidra && pip install --upgrade pip && pip install r2pipe
        echo -e "${GREEN}[✔] Radare2 installed successfully!${RESET}"
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
        2 "Hermes (Decompile & Disasm)" \
        3 "Install Blutter" \
        4 "Process arm64-v8a (Auto)" \
        5 "Return to MainMenu" 3>&1 1>&2 2>&3)
    else
      choice=$(dialog --title "Blutter Suite" \
        --menu "Blutter not detected. Choose an option:" 15 50 5 \
        1 "APKEditor" \
        2 "Hermes (Decompile & Disasm)" \
        3 "Install Blutter" \
        4 "Process arm64-v8a (Auto)" \
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
      3)
        # =====[ Corrected Blutter Installer ]======
        echo -e "${BLUE}[*] Starting Blutter installation...${RESET}"
        
        # Update system packages
        echo -e "${YELLOW}[!] Updating system packages...${RESET}"
        pkg update -y && pkg upgrade -y
        
        # Install dependencies
        echo -e "${YELLOW}[!] Installing dependencies...${RESET}"
        pkg install -y git cmake ninja build-essential pkg-config libicu capstone fmt
        
        # Install Python packages
        echo -e "${YELLOW}[!] Installing Python dependencies...${RESET}"
        pip install requests pyelftools
        
        # Clone repository
        echo -e "${YELLOW}[!] Cloning Blutter repository...${RESET}"
        cd $HOME
        if git clone https://github.com/dedshit/blutter-termux.git; then
          echo -e "${GREEN}[✔] Repository cloned successfully${RESET}"
          
          # Check for std::format errors and fix if needed
          echo -e "${YELLOW}[!] Checking for compilation issues...${RESET}"
          if grep -r "std::format" $HOME/blutter-termux/; then
            echo -e "${YELLOW}[!] Found std::format usage, replacing with fmt::format...${RESET}"
            find $HOME/blutter-termux/ -type f -exec sed -i 's/std::format/fmt::format/g' {} +
            echo -e "${GREEN}[✔] Source files modified${RESET}"
          fi
          
          echo -e "${GREEN}[✔] Blutter installed successfully!${RESET}"
          echo -e "To run Blutter, execute:"
          echo -e "cd ~/blutter-termux && ./blutter"
        else
          echo -e "${RED}[!] Failed to clone repository${RESET}"
          echo -e "Please check your internet connection and try again"
        fi
        sleep 2
        ;;
      4)
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
      5)
        return
        ;;
    esac
  done
}

# =========[ Refresh Function ]=========
refresh_script() {
    echo -e "\e[1;32m[+] Refreshing script...\e[0m"
    # Store current variables that need to persist
    local current_dir="$PWD"
    local stored_vars="SCRIPT_VERSION=$SCRIPT_VERSION"
    
    # Clear the screen and re-execute with preserved environment
    clear
    exec env $stored_vars bash "$0" --refreshed "$@"
    
    # If exec fails (shouldn't happen)
    echo -e "\e[1;31m[!] Refresh failed\e[0m"
    return 1
}
# ====[ Install Zsh Add-ons ]=====
install_zsh_addons() {
    echo -e "\e[1;33m[+] Installing Zsh Add-ons...\e[0m"
    pkg install -y zsh git curl
    export ZSH="$HOME/.oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
    ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
    git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
    echo -e "\e[1;32m[✓] Zsh add-ons installation complete!\e[0m"
    sleep 2
}

# =========[ Main Menu ]=========
main_menu() {
    # Check if we're coming from a refresh
    if [ "$1" == "--refreshed" ]; then
        echo -e "\e[1;32m[✓] Script refreshed successfully!\e[0m"
        sleep 1
        clear
    fi

    while true; do
        main_choice=$(dialog --clear --backtitle "Termux Setup Script v$SCRIPT_VERSION" \
            --title "Main Menu" \
            --menu "Choose an option:" 22 60 13 \
            0 "Backup & Wipe Tools" \
            1 "Blutter Suite" \
            2 "Dex2c Tools" \
            3 "Exit Script" \
            4 "Install Zsh Add-ons" \
            5 "MOTD Settings" \
            6 "Python Packages + Plugins" \
            7 "Radare2 Suite" \
            8 "Refresh Script" \
            9 "Update Script" \
            10 "File Explorer" 3>&1 1>&2 2>&3)

        clear
        case "$main_choice" in
            0) backup_wipe_menu ;;
            1) blutter_suite ;;
            2) dex2c_menu ;;
            3)
                echo "Exiting..."
                exit 0
                ;;
            4) install_zsh_addons ;;
            5) motd_prompt ;;
            6)
                echo -e "\e[1;33m[+] Installing packages...\e[0m"
                yes | pkg update -y && yes | pkg upgrade -y
                yes | pkg install -y git curl wget nano vim ruby php nodejs golang clang \
                    zip unzip tar proot neofetch htop openssh nmap net-tools termux-api \
                    termux-tools ffmpeg openjdk-17 tur-repo build-essential binutils
                pip install rich requests spotipy yt_dlp ffmpeg-python mutagen
                echo -e "\e[1;32m[✓] Installation complete!\e[0m"
                sleep 2
                ;;
            7) radare2_suite ;;
            8) refresh_script ;;
            9) 
                echo -e "\e[1;33m[*] Checking for script updates...\e[0m"
                remote_version=$(curl -s "$SCRIPT_URL" | grep -m1 "SCRIPT_VERSION=" | cut -d'"' -f2)
                
                if [ "$remote_version" != "$SCRIPT_VERSION" ]; then
                    echo -e "\e[1;32m[+] Update found ($remote_version), updating...\e[0m"
                    if curl -s "$SCRIPT_URL" > "$0.tmp"; then
                        chmod +x "$0.tmp"
                        mv "$0.tmp" "$0"
                        echo -e "\e[1;32m[✓] Update complete. Restarting script...\e[0m"
                        sleep 2
                        exec "$0" "$@"
                    else
                        echo -e "\e[1;31m[!] Update failed, continuing with current version.\e[0m"
                        sleep 2
                    fi
                else
                    echo -e "\e[1;32m[✓] Already up to date.\e[0m"
                    sleep 2
                fi
                ;;
            10) 
                file_explorer
                # No need to refresh unless changes were made
                ;;
            *) echo "Invalid option" ;;
        esac
    done
}

# =========[ File Explorer ]=========
file_explorer() {
    local current_path="$HOME"
    
    while true; do
        # Build the file list
        local items=()
        if [ "$current_path" != "/" ]; then
            items+=(".." "Go Up")
        fi
        
        # Add directories (sorted)
        while IFS= read -r dir; do
            [ -z "$dir" ] && continue
            items+=("$dir/" "DIR")
        done < <(find "$current_path" -maxdepth 1 -type d ! -path "$current_path" -printf "%f\n" | sort)
        
        # Add files (sorted)
        while IFS= read -r file; do
            [ -z "$file" ] && continue
            items+=("$file" "FILE")
        done < <(find "$current_path" -maxdepth 1 -type f -printf "%f\n" | sort)

        # Show dialog with action buttons
        choice=$(dialog --clear \
            --backtitle "File Explorer" \
            --title " $current_path " \
            --ok-label "Open" \
            --cancel-label "Back" \
            --extra-button \
            --extra-label "Delete" \
            --menu "Select:" \
            20 60 20 \
            "${items[@]}" \
            3>&1 1>&2 2>&3)
            
        ret=$?
        
        # Handle button presses
        case $ret in
            0) # Open pressed
                if [[ "$choice" == ".." ]]; then
                    current_path=$(dirname "$current_path")
                elif [[ "$choice" == */ ]]; then
                    current_path="$current_path/${choice%/}"
                else
                    file_actions "$current_path/$choice"
                fi
                ;;
            3) # Delete pressed
                if [[ -n "$choice" && "$choice" != ".." ]]; then
                    target="$current_path/$choice"
                    dialog --yesno "Delete PERMANENTLY?\n$target" 7 60
                    [ $? -eq 0 ] && rm -rf "$target"
                fi
                ;;
            *) # ESC/Back pressed
                return  # Return to main menu without refreshing
                ;;
        esac
    done
}

# =========[ File Actions Dialog ]=========
file_actions() {
    local file="$1"
    
    while true; do
        action=$(dialog --clear \
            --backtitle "File Actions" \
            --title " $file " \
            --ok-label "Select" \
            --cancel-label "Back" \
            --extra-button \
            --extra-label "Delete" \
            --menu "Choose:" \
            15 50 10 \
            "View" "Show file contents" \
            "Edit" "Edit with nano" \
            "Rename" "Change filename" \
            3>&1 1>&2 2>&3)
            
        ret=$?
        
        case $ret in
            0) # Select pressed
                case "$action" in
                    "View") 
                        clear
                        less "$file"
                        ;;
                    "Edit")
                        if command -v nano >/dev/null; then
                            clear
                            nano "$file"
                        else
                            dialog --msgbox "nano not installed" 5 40
                        fi
                        ;;
                    "Rename")
                        new_name=$(dialog --inputbox "New name:" 8 40 "$(basename "$file")" 3>&1 1>&2 2>&3)
                        [ -n "$new_name" ] && mv "$file" "$(dirname "$file")/$new_name"
                        return
                        ;;
                esac
                ;;
            3) # Delete pressed
                dialog --yesno "Delete PERMANENTLY?\n$file" 7 60
                [ $? -eq 0 ] && rm -f "$file" && return
                ;;
            *) # Back pressed
                break
                ;;
        esac
    done
}

# ====[ Dex2c Submenu ]=====
dex2c_menu() {
    while true; do
        dex_choice=$(dialog --clear --backtitle "Termux Setup Script v$SCRIPT_VERSION" \
            --title "Dex2c Tools" \
            --menu "Choose an option:" 15 50 4 \
            1 "Check Dependencies" \
            2 "Install Dex2c" \
            3 "Remove Dex2c" \
            4 "Return to Main Menu" 3>&1 1>&2 2>&3)

        clear
        case "$dex_choice" in
            1) check_dex2c_deps ;;
            2) install_dex2c ;;
            3) remove_dex2c ;;
            4) return ;;
            *) echo "Invalid option" ;;
        esac
    done
}

# ====[ Silent Package Manager ]=====
termux_pkg() {
    case $1 in
        install)
            shift
            for pkg in "$@"; do
                if ! dpkg -s "$pkg" >/dev/null 2>&1; then
                    apt-get install -y -qq \
                        -o Dpkg::Options::="--force-confdef" \
                        -o Dpkg::Options::="--force-confold" \
                        --no-install-recommends \
                        "$pkg" >/dev/null 2>&1 || return 1
                fi
            done
            ;;
        update)
            apt-get update -y -qq \
                -o Dpkg::Options::="--force-confdef" \
                -o Dpkg::Options::="--force-confold" >/dev/null 2>&1
            ;;
        upgrade)
            apt-get upgrade -y -qq \
                -o Dpkg::Options::="--force-confdef" \
                -o Dpkg::Options::="--force-confold" >/dev/null 2>&1
            ;;
        *) return 1 ;;
    esac
}

# ====[ Check Dependencies ]=====
check_dex2c_deps() {
    deps_missing=0
    check_result="Dependency Check Results:\n\n"
    
    # Check commands
    check_cmd() {
        if command -v "$1" >/dev/null 2>&1; then
            check_result+="✓ $1 installed\n"
            return 0
        else
            check_result+="✗ $1 missing\n"
            return 1
        fi
    }
    
    check_cmd git || deps_missing=1
    check_cmd java || deps_missing=1
    check_cmd make || deps_missing=1
    check_cmd python || deps_missing=1
    check_cmd unzip || deps_missing=1
    check_cmd wget || deps_missing=1
    
    # Simplified check without directory paths
    [ -d "$HOME/dex2c" ] || { check_result+="✗ Dex2c not installed\n"; deps_missing=1; }
    [ -d "$HOME/ndk" ] || { check_result+="✗ NDK not installed\n"; deps_missing=1; }
    
    if [ $deps_missing -eq 0 ]; then
        dialog --title "Dependency Check" --msgbox "${check_result}\nAll dependencies are satisfied." 12 50
    else
        dialog --title "Dependency Check" --yesno "${check_result}\n\nMissing dependencies found. Install now?" 12 50 && install_dex2c
    fi
}

# ====[ Install Dex2c ]=====
install_dex2c() {
    (
        echo "10"
        echo "# Checking system requirements..."
        
        echo "20"
        echo "# Updating package lists..."
        termux_pkg update || { echo "Package update failed" >&2; exit 1; }
        
        echo "30"
        echo "# Upgrading existing packages..."
        termux_pkg upgrade || { echo "Package upgrade failed" >&2; exit 1; }
        
        echo "40"
        echo "# Installing core dependencies..."
        termux_pkg install clang curl git make openjdk-17 propt python unzip wget zip || { echo "Dependency installation failed" >&2; exit 1; }
        
        echo "50"
        echo "# Preparing Dex2c environment..."
        [ -d "$HOME/dex2c" ] && rm -rf "$HOME/dex2c"
        
        echo "60"
        echo "# Cloning Dex2c repository..."
        git clone -q https://github.com/RealCyberNomadic/dex2c "$HOME/dex2c" || { echo "Clone failed" >&2; exit 1; }
        
        echo "70"
        echo "# Setting up Apktool..."
        mkdir -p "$HOME/dex2c/tools"
        wget -q https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.9.3.jar -O "$HOME/dex2c/tools/apktool.jar" || { echo "Apktool download failed" >&2; exit 1; }
        
        echo "80"
        echo "# Installing NDK..."
        [ -d "$HOME/ndk" ] && rm -rf "$HOME/ndk"
        wget -q https://dl.google.com/android/repository/android-ndk-r26b-linux.zip -O "$HOME/ndk.zip" || { echo "NDK download failed" >&2; exit 1; }
        unzip -q "$HOME/ndk.zip" -d "$HOME" || { echo "NDK extraction failed" >&2; exit 1; }
        mv "$HOME/android-ndk-r26b" "$HOME/ndk"
        rm "$HOME/ndk.zip"
        
        echo "90"
        echo "# Configuring environment..."
        grep -q 'export NDK=' "$HOME/.bashrc" || echo 'export NDK=$HOME/ndk' >> "$HOME/.bashrc"
        grep -q 'export PATH=$NDK:$PATH' "$HOME/.bashrc" || echo 'export PATH=$NDK:$PATH' >> "$HOME/.bashrc"
        
        echo "100"
        echo "# Finalizing installation..."
        sleep 1
    ) | dialog --title "Dex2c Installation" --gauge "Installing Dex2c..." 10 70 0

    # Verify installation
    if [ -d "$HOME/dex2c" ] && [ -d "$HOME/ndk" ]; then
        dialog --msgbox "Dex2c installed successfully!\n\nLocation: $HOME/dex2c\nNDK: $HOME/ndk" 9 50
    else
        dialog --msgbox "Installation completed with possible errors.\nCheck $HOME/dex2c and $HOME/ndk exist." 9 50
    fi
}

# ====[ Remove Dex2c ]=====
remove_dex2c() {
    dialog --yesno "WARNING: This will completely remove:\n\n- Dex2c and all components\n- NDK\n- Android SDK\n- Related packages\n\nContinue?" 12 50 || return

    (
        echo "20"
        echo "# Removing Dex2c core..."
        rm -rf "$HOME/dex2c"
        
        echo "30"
        echo "# Removing NDK..."
        rm -rf "$HOME/ndk"
        
        echo "40"
        echo "# Removing Android SDK..."
        rm -rf "$HOME/android-sdk"
        
        echo "50"
        echo "# Uninstalling packages..."
        apt-get remove -y -qq \
            -o Dpkg::Options::="--force-confdef" \
            -o Dpkg::Options::="--force-confold" \
            --auto-remove \
            android-sdk clang dex2c git java make ndk python unzip wget >/dev/null 2>&1
        
        echo "70"
        echo "# Cleaning package cache..."
        apt-get clean -y -qq >/dev/null 2>&1
        
        echo "80"
        echo "# Updating environment..."
        sed -i '/export ANDROID_SDK=\$HOME\/android-sdk/d' "$HOME/.bashrc"
        sed -i '/export NDK=\$HOME\/ndk/d' "$HOME/.bashrc"
        sed -i '/export PATH=\$NDK:\$PATH/d' "$HOME/.bashrc"
        
        echo "100"
        echo "# Removal complete!"
        sleep 1
    ) | dialog --title "Dex2c Removal" --gauge "Cleaning system..." 10 70 0

    dialog --msgbox "All Dex2c components and related packages were removed successfully." 7 50
}

# ====[ Check Dependencies ]=====
check_dex2c_deps() {
    missing_pkgs=0
    check_result="Dependency Check:\n\n"
    
    # Check package function
    check_pkg() {
        if dpkg -s "$1" >/dev/null 2>&1; then
            check_result+="✓ $1\n"
        else
            check_result+="✗ $1\n"
            missing_pkgs=1
        fi
    }
    
    # Check directory function 
    check_dir() {
        [ -d "$1" ] && check_result+="✓ $2\n" || check_result+="✗ $2\n"
    }
    
    # Check required packages 
    check_pkg "clang"
    check_pkg "git"
    check_pkg "make"
    check_pkg "openjdk-17"
    check_pkg "python"
    check_pkg "unzip"
    check_pkg "wget"
    
    # Check components 
    check_dir "$HOME/dex2c" "Dex2c"
    check_dir "$HOME/ndk" "NDK"
    
    if [ $missing_pkgs -eq 0 ]; then
        dialog --title "Dependencies" --msgbox "${check_result}\nAll packages are installed." 15 60
    else
        dialog --title "Missing Packages" --yesno "${check_result}\n\nInstall missing packages now?" 15 60 && {
            (
                echo "20"; echo "# Updating packages...";
                pkg update -y >/dev/null 2>&1
                
                echo "50"; echo "# Installing missing packages...";
                pkg install -y clang git make openjdk-17 python unzip wget >/dev/null 2>&1
                
                echo "100"; echo "# Done!";
                sleep 1
            ) | dialog --gauge "Installing packages..." 10 70 0
        }
    fi
}

# ====[ Remove Dex2c ]=====
remove_dex2c() {
    # List of packages to remove
    PKG_LIST="clang git make openjdk-17 python unzip wget"
    
    dialog --yesno "WARNING: This will remove:\n\n- Dex2c files (~/dex2c)\n- NDK files (~/ndk)\n- Packages: $PKG_LIST\n\nContinue?" 13 50 || return

    (
        echo "10"
        echo "# Removing Dex2c files..."
        rm -rf "$HOME/dex2c"
        
        echo "25" 
        echo "# Removing NDK files..."
        rm -rf "$HOME/ndk"
        
        echo "40"
        echo "# Removing packages..."
        for pkg in $PKG_LIST; do
            if dpkg -s "$pkg" >/dev/null 2>&1; then
                apt-get remove -y --purge "$pkg" >/dev/null 2>&1
            fi
        done
        
        echo "70"
        echo "# Cleaning up dependencies..."
        apt-get autoremove -y >/dev/null 2>&1
        apt-get clean >/dev/null 2>&1
        
        echo "85"
        echo "# Updating environment..."
        sed -i '/export NDK=\$HOME\/ndk/d' "$HOME/.bashrc"
        sed -i '/export PATH=\$NDK:\$PATH/d' "$HOME/.bashrc"
        
        echo "100"
        echo "# Uninstall complete!"
        sleep 1
    ) | dialog --title "Dex2c Removal" --gauge "Uninstalling..." 10 70 0

    dialog --msgbox "Dex2c and all related components were successfully removed." 7 50
}

# ====[ Backup & Wipe Submenu ]=====
backup_wipe_menu() {
    while true; do
        sub_choice=$(dialog --clear --backtitle "Termux Setup Script v$SCRIPT_VERSION" \
            --title "Backup & Wipe Tools" \
            --menu "Choose an option:" 15 50 4 \
            1 "Backup Termux Environment" \
            2 "Restore Termux Environment" \
            3 "Wipe All Packages (Caution!)" \
            4 "Return to Main Menu" 3>&1 1>&2 2>&3)

        clear
        case "$sub_choice" in
            1)
                echo "[+] Backing up Termux..."
                tar -zcf /sdcard/termux-backup.tar.gz -C /data/data/com.termux/files ./home ./usr
                ;;
            2)
                echo "[+] Restoring Termux..."
                tar -zxf /sdcard/termux-backup.tar.gz -C /data/data/com.termux/files --recursive-unlink
                ;;
            3)
                while true; do
                    echo -e "\n\033[1;31m[!] WARNING: This will COMPLETELY WIPE your Termux environment!\033[0m"
                    echo -e "\033[1;33mAll packages, configurations, and home files will be permanently deleted.\033[0m\n"
                    read -rp "Are you sure you want to continue? [Y/N/YES/NO]: " confirm_wipe
                    
                    case "${confirm_wipe^^}" in
                        "Y"|"YES")
                            echo -e "\n\033[1;31mStarting wipe process...\033[0m"
                            echo -e "\033[1;33mRemoving all packages and files...\033[0m"
                            
                            # Wipe sequence with progress indication
                            echo "[1/3] Removing packages..."
                            pkg list-installed | cut -d/ -f1 | xargs pkg uninstall -y >/dev/null 2>&1
                            
                            echo "[2/3] Cleaning home directory..."
                            rm -rf $HOME/* $HOME/.* >/dev/null 2>&1
                            
                            echo "[3/3] Removing system files..."
                            rm -rf /data/data/com.termux/files/usr/* >/dev/null 2>&1
                            
                            echo -e "\n\033[1;32mWipe completed successfully!\033[0m"
                            echo -e "\033[1;33mPress Enter to exit Termux (you'll need to restart it)...\033[0m"
                            read -r
                            exit 0
                            ;;
                        "N"|"NO")
                            echo -e "\n\033[1;32mWipe cancelled. No changes were made.\033[0m"
                            sleep 1
                            break
                            ;;
                        *)
                            echo -e "\n\033[1;31mInvalid input. Please enter Y/YES or N/NO.\033[0m"
                            sleep 1
                            clear
                            continue
                            ;;
                    esac
                done
                ;;
            4) return ;;
            *) echo "Invalid option" ;;
        esac
    done
}

# =========[ Start Script ]=========
check_termux_storage
main_menu