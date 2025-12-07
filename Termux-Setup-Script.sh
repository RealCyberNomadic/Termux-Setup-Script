#!/usr/bin/env bash

# Script Configuration
SCRIPT_URL="https://raw.githubusercontent.com/RealCyberNomadic/Termux-Setup-Script/main/Termux-Setup-Script.sh"
SCRIPT_VERSION="2.2.6"

# ====[ Auto Update Function ]====
check_and_update() {
    echo -e "\033[1;34m[~] Checking for updates...\033[0m"

    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        echo -e "\033[1;33m[!] curl not found. Skipping update check.\033[0m"
        return
    fi

    # Fetch the latest version from GitHub
    LATEST_VERSION=$(curl -s "$SCRIPT_URL" | grep -o 'SCRIPT_VERSION="[0-9.]*"' | head -1 | cut -d'"' -f2)

    if [ -z "$LATEST_VERSION" ]; then
        echo -e "\033[1;33m[!] Could not check for updates. Continuing with current version.\033[0m"
        return
    fi

    if [ "$LATEST_VERSION" != "$SCRIPT_VERSION" ]; then
        echo -e "\033[1;32m[+] Update found! Current: $SCRIPT_VERSION, Latest: $LATEST_VERSION\033[0m"
        echo -e "\033[1;34m[~] Downloading update...\033[0m"

        # Download the updated script
        curl -s "$SCRIPT_URL" -o "$0.tmp"

        if [ -f "$0.tmp" ] && [ -s "$0.tmp" ]; then
            # Make it executable and replace current script
            chmod +x "$0.tmp"
            mv "$0.tmp" "$0"
            echo -e "\033[1;32m[+] Update installed! Restarting script...\033[0m"

            # Restart the script with the update
            exec "$0"
        else
            echo -e "\033[1;31m[!] Failed to download update. Continuing with current version.\033[0m"
            rm -f "$0.tmp" 2>/dev/null
        fi
    else
        echo -e "\033[1;32m[✓] You are running the latest version ($SCRIPT_VERSION)\033[0m"
    fi
}

# ====[ Utility Functions ]====
check_termux_storage() {
    # Check if storage is already set up by looking for the storage directory
    if [ ! -d "$HOME/storage" ]; then
        echo -e "\033[1;33m[!] Setting up Termux storage...\033[0m"
        termux-setup-storage
    fi
}

# ==== [ Shortcut Alias ] ====
add_alias() {
    local alias_line_lower="alias tts='bash \$HOME/Termux-Setup-Script/Termux-Setup-Script.sh'"
    local alias_line_upper="alias TTS='bash \$HOME/Termux-Setup-Script/Termux-Setup-Script.sh'"
    local shell_rc=""
    local aliases_added=0

    # Detect shell rc file
    case "$SHELL" in
        */zsh) shell_rc="$HOME/.zshrc" ;;
        */bash) shell_rc="$HOME/.bashrc" ;;
        *)
            if [ -f "$HOME/.bashrc" ]; then
                shell_rc="$HOME/.bashrc"
            elif [ -f "$HOME/.zshrc" ]; then
                shell_rc="$HOME/.zshrc"
            else
                shell_rc="$HOME/.bashrc"
            fi
            ;;
    esac

    # Ensure RC file exists
    touch "$shell_rc"

    # Add lowercase alias ONLY if not present
    if ! grep -Fxq "$alias_line_lower" "$shell_rc"; then
        printf "\n%s\n" "$alias_line_lower" >> "$shell_rc"
        aliases_added=1
    fi

    # Add uppercase alias ONLY if not present
    if ! grep -Fxq "$alias_line_upper" "$shell_rc"; then
        printf "\n%s\n" "$alias_line_upper" >> "$shell_rc"
        aliases_added=1
    fi

    # Set aliases for current session
    alias tts='bash $HOME/Termux-Setup-Script/Termux-Setup-Script.sh'
    alias TTS='bash $HOME/Termux-Setup-Script/Termux-Setup-Script.sh'

    # Show dialog ONLY if aliases were newly added
    if [ "$aliases_added" -eq 1 ] && command -v dialog >/dev/null 2>&1; then
        dialog --title "Shortcut Added" \
               --msgbox "You can now use:\n\n  tts\n  TTS\n\nto run this script from anywhere in your terminal." 12 50
    fi
}

====[ MOTD Customization ]====

motd_prompt() {
  while true; do
    choice=$(dialog --colors --title " \Z1MOTD Customization\Z0" \
      --backtitle "Termux Setup v$SCRIPT_VERSION" \
      --menu "Choose an action:" 16 60 4 \
      1 "Color Presets" \
      2 "Change Text Color" \
      3 "Restore Default MOTD" \
      4 "Return to MainMenu" 3>&1 1>&2 2>&3)

    case $choice in
      1)
        # Enhanced Color Presets with better combinations
        preset_choice=$(dialog --colors --title " \Z1Color Presets\Z0" \
          --backtitle "Termux Setup v$SCRIPT_VERSION" \
          --menu "Choose a color preset:" 20 60 12 \
          1 "Sunset \Zb\Z9■\Zn & Purple \Zb\Z5■\Zn" \
          2 "Ocean \Zb\Z4■\Zn & Teal \Zb\Z6■\Zn" \
          3 "Forest \Zb\Z2■\Zn & Lime \Zb\Z10■\Zn" \
          4 "Royal \Zb\Z5■\Zn & Gold \Zb\Z3■\Zn" \
          5 "Sunrise \Zb\Z1■\Zn & Orange \Zb\Z9■\Zn" \
          6 "Arctic \Zb\Z6■\Zn & Blue \Zb\Z4■\Zn" \
          7 "Berry \Zb\Z13■\Zn & Plum \Zb\Z5■\Zn" \
          8 "Cyan \Zb\Z14■\Zn & Navy \Zb\Z4■\Zn" \
          9 "Coral \Zb\Z9■\Zn & Rose \Zb\Z13■\Zn" \
          10 "Slate \Zb\Z8■\Zn & Emerald \Zb\Z10■\Zn" \
          11 "Rainbow Colors (Random)" \
          12 "Cancel" 3>&1 1>&2 2>&3)

        # Check if user cancelled or chose Cancel
        [ $? -ne 0 ] && continue  # User pressed ESC
        [ "$preset_choice" -eq 12 ] && continue  # User chose Cancel

        # Clear the motd file before writing new content
        > "$PREFIX/etc/motd"

        # Apply preset with better color codes
        case $preset_choice in
          1) 
            color1='\033[38;5;208m'  # Orange
            color2='\033[38;5;93m'   # Purple
            ;;
          2) 
            color1='\033[38;5;27m'   # Deep Blue
            color2='\033[38;5;43m'   # Teal
            ;;
          3) 
            color1='\033[38;5;48m'   # Forest Green
            color2='\033[38;5;46m'   # Lime
            ;;
          4) 
            color1='\033[38;5;57m'   # Royal Purple
            color2='\033[38;5;220m'  # Gold
            ;;
          5) 
            color1='\033[38;5;196m'  # Red
            color2='\033[38;5;214m'  # Orange
            ;;
          6) 
            color1='\033[38;5;51m'   # Bright Cyan
            color2='\033[38;5;33m'   # Blue
            ;;
          7) 
            color1='\033[38;5;207m'  # Pink
            color2='\033[38;5;127m'  # Purple
            ;;
          8) 
            color1='\033[38;5;45m'   # Cyan
            color2='\033[38;5;18m'   # Navy
            ;;
          9) 
            color1='\033[38;5;209m'  # Coral
            color2='\033[38;5;211m'  # Rose
            ;;
          10) 
            color1='\033[38;5;242m'  # Gray
            color2='\033[38;5;48m'   # Emerald
            ;;
          11)
            # Rainbow colors with better variety
            colors=(
              '\033[38;5;196m'  # Red
              '\033[38;5;214m'  # Orange
              '\033[38;5;226m'  # Yellow
              '\033[38;5;46m'   # Green
              '\033[38;5;45m'   # Cyan
              '\033[38;5;57m'   # Purple
              '\033[38;5;207m'  # Pink
              '\033[38;5;51m'   # Bright Cyan
            )
            color1=${colors[$RANDOM % ${#colors[@]}]}
            # Ensure color2 is different from color1
            color2=${colors[$RANDOM % ${#colors[@]}]}
            while [ "$color2" = "$color1" ]; do
              color2=${colors[$RANDOM % ${#colors[@]}]}
            done
            ;;
        esac

        # Write the colored MOTD
        printf "${color1}" >> "$PREFIX/etc/motd"
        cat << 'EOF' | head -n 3 >> "$PREFIX/etc/motd"
  ████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗
  ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝
     ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝
EOF

        printf "${color2}" >> "$PREFIX/etc/motd"
        cat << 'EOF' | tail -n 3 >> "$PREFIX/etc/motd"
     ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗
     ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗
     ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝
EOF
        printf "\033[0m" >> "$PREFIX/etc/motd"
        dialog --msgbox "\n\Z2[✓] Color preset applied successfully!\Zn" 8 50
        ;;

      2)  
        # Change Text Color - Now with the same color options as presets
        if [ -f "$PREFIX/etc/motd" ]; then
          color_choice=$(dialog --colors --title " \Z1Select Text Color\Z0" \
            --backtitle "Termux Setup v$SCRIPT_VERSION" \
            --menu "Choose a color:" 20 60 14 \
            1 "Sunset Orange \Zb\Z9■\Zn" \
            2 "Ocean Blue \Zb\Z4■\Zn" \
            3 "Forest Green \Zb\Z2■\Zn" \
            4 "Royal Purple \Zb\Z5■\Zn" \
            5 "Sunrise Red \Zb\Z1■\Zn" \
            6 "Arctic Cyan \Zb\Z6■\Zn" \
            7 "Berry Pink \Zb\Z13■\Zn" \
            8 "Cyan \Zb\Z14■\Zn" \
            9 "Coral \Zb\Z9■\Zn" \
            10 "Slate Gray \Zb\Z8■\Zn" \
            11 "Teal \Zb\Z6■\Zn" \
            12 "Lime Green \Zb\Z10■\Zn" \
            13 "Gold \Zb\Z3■\Zn" \
            14 "Navy Blue \Zb\Z4■\Zn" \
            15 "Rose Pink \Zb\Z13■\Zn" \
            16 "Emerald \Zb\Z10■\Zn" \
            17 "Rainbow Random" \
            18 "Cancel" 3>&1 1>&2 2>&3)

          # Check if user cancelled
          [ $? -ne 0 ] && continue
          [ "$color_choice" -eq 18 ] && continue

          get_color() {  
            case $1 in  
              1) echo '\033[38;5;208m' ;;    # Sunset Orange
              2) echo '\033[38;5;27m' ;;     # Ocean Blue
              3) echo '\033[38;5;28m' ;;     # Forest Green
              4) echo '\033[38;5;57m' ;;     # Royal Purple
              5) echo '\033[38;5;196m' ;;    # Sunrise Red
              6) echo '\033[38;5;51m' ;;     # Arctic Cyan
              7) echo '\033[38;5;207m' ;;    # Berry Pink
              8) echo '\033[38;5;45m' ;;     # Cyan
              9) echo '\033[38;5;209m' ;;    # Coral
              10) echo '\033[38;5;242m' ;;   # Slate Gray
              11) echo '\033[38;5;43m' ;;    # Teal
              12) echo '\033[38;5;46m' ;;    # Lime Green
              13) echo '\033[38;5;220m' ;;   # Gold
              14) echo '\033[38;5;18m' ;;    # Navy Blue
              15) echo '\033[38;5;211m' ;;   # Rose Pink
              16) echo '\033[38;5;48m' ;;    # Emerald
              17) 
                # Random from the rainbow palette
                rainbow_colors=(
                  '\033[38;5;196m'
                  '\033[38;5;214m'
                  '\033[38;5;226m'
                  '\033[38;5;46m'
                  '\033[38;5;45m'
                  '\033[38;5;57m'
                  '\033[38;5;207m'
                  '\033[38;5;51m'
                  '\033[38;5;208m'
                  '\033[38;5;93m'
                  '\033[38;5;27m'
                  '\033[38;5;43m'
                )
                echo "${rainbow_colors[$RANDOM % ${#rainbow_colors[@]}]}"
                ;;
              *) echo '\033[0m' ;;       # Default  
            esac  
          }

          color=$(get_color "$color_choice")  
          dialog --infobox "Applying text color..." 5 40  

          # Remove existing color codes and reapply new color
          motd_content=$(sed -r "s/\x1B\[[0-9;]*[mK]//g" "$PREFIX/etc/motd")  
          > "$PREFIX/etc/motd"

          # Write the color code
          echo -ne "$color" >> "$PREFIX/etc/motd"

          # FIX APPLIED HERE — prevent trailing %  
          printf "%s\n" "$motd_content" >> "$PREFIX/etc/motd"

          # Reset color
          echo -ne "\033[0m" >> "$PREFIX/etc/motd"

          dialog --msgbox "\n\Z2[✓] MOTD text color changed!\Zn" 7 50  
        else  
          dialog --msgbox "\n\Z1[!] No MOTD found to modify!\Zn" 7 50  
        fi  
        ;;  

      3)  
        dialog --yesno "\n\Z1Are you sure you want to restore the default MOTD?\Zn" 7 50  
        if [ $? -eq 0 ]; then  
          > "$PREFIX/etc/motd"  
          cat << 'EOF' > "$PREFIX/etc/motd"

Welcome to Termux!

Wiki:            https://wiki.termux.com
Community forum: https://termux.com/community
Gitter chat:     https://gitter.im/termux/termux
IRC channel:     #termux on freenode

Working with packages:
- Search packages:   pkg search <query>
- Install a package:  pkg install <package>
- Upgrade packages:   pkg upgrade

Subscribing to additional repositories:
- Root:      pkg install root-repo
- Unstable:  pkg install unstable-repo
- X11:       pkg install x11-repo

Report issues at https://termux.com/issues
EOF
          dialog --msgbox "\n\Z2[✓] Default MOTD has been restored!\Zn" 7 50
        else
          dialog --msgbox "\n\Z3[!] MOTD restoration cancelled.\Zn" 7 50
        fi
        ;;

      4)
        break
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
      --menu "Choose an option:" 20 60 6 \
      1 "Asm Disasm (index.android.bundle)" \
      2 "Disasm (index.android.bundle)" \
      3 "Install HBCTOOL" \
      4 "Install Radare2" \
      5 "Return to MainMenu" 3>&1 1>&2 2>&3)

    clear
    case "$choice" in
      1)
        echo -e "${BLUE}[+] Running HBCTool Asm...${RESET}"
        if [ -d "/storage/emulated/0/Shite/apks/disasm" ]; then
          echo -e "${YELLOW}[*] Processing disasm files...${RESET}"
          if hbctool asm "/storage/emulated/0/Shite/apks/disasm" "/storage/emulated/0/Shite/apks/index.android.bundle" >/dev/null 2>&1; then
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
        rm -rf "/storage/emulated/0/Shite/apks/disasm" 2>/dev/null

        if [ -f "/storage/emulated/0/Shite/apks/index.android.bundle" ]; then
          echo -e "${YELLOW}[*] Processing bundle file...${RESET}"
          if hbctool disasm "/storage/emulated/0/Shite/apks/index.android.bundle" "/storage/emulated/0/Shite/apks/disasm" >/dev/null 2>&1; then
            echo -e "${GREEN}[✔] Operation completed successfully!${RESET}"
            echo -e "${BLUE}Output files are ready${RESET}"
          else
            echo -e "${RED}[!] Operation failed${RESET}"
            rm -rf "/storage/emulated/0/Shite/apks/disasm" 2>/dev/null
          fi
        else
          echo -e "${RED}[!] Required file not found${RESET}"
          echo -e "${YELLOW}Please verify the bundle file exists${RESET}"
        fi
        sleep 3
        ;;
      3)
        echo -e "${BLUE}[+] Installing Hbctool...${RESET}"

        if ! command -v wget &> /dev/null; then
          echo -e "${ORANGE}[↻] Installing wget...${RESET}"
          pkg install -y wget
        fi

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
        echo -e "${BLUE}[+] Installing Radare2...${RESET}"
        pkg update -y && pkg upgrade -y && pkg install -y git clang make binutils curl python && git clone https://github.com/radareorg/radare2 "$HOME/radare2" && cd "$HOME/radare2" && ./sys/install.sh && source ~/.bashrc && r2pm init && r2pm update && r2pm -ci r2ghidra && pip install --upgrade pip && pip install r2pipe
        echo -e "${GREEN}[✔] Radare2 installed successfully!${RESET}"
        sleep 5
        ;;
      5)
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
                3 "Blutter Manager" \
                4 "Process arm64-v8a (Auto)" \
                5 "Return to MainMenu" 3>&1 1>&2 2>&3)
        else
            choice=$(dialog --title "Blutter Suite" \
                --menu "Blutter not detected. Choose an option:" 15 50 5 \
                1 "APKEditor" \
                2 "Hermes (Decompile & Disasm)" \
                3 "Blutter Manager" \
                4 "Process arm64-v8a (Auto)" \
                5 "Return to MainMenu" 3>&1 1>&2 2>&3)
        fi

        clear
        case "$choice" in
            1)
                # =====[ APKEditor Implementation ]=====
                apk_editor_loop() {
                    # Ensure APKEditor exists
                    if [ ! -f "/storage/emulated/0/Shite/APKEditor.jar" ]; then
                        echo -e "${BLUE}[*] Downloading APKEditor v1.4.5...${RESET}"
                        mkdir -p "$HOME/temp_downloads"
                        cd "$HOME/temp_downloads"
                        if wget -q https://github.com/REandroid/APKEditor/releases/download/V1.4.5/APKEditor-1.4.5.jar; then
                            mkdir -p /storage/emulated/0/Shite
                            mv APKEditor-1.4.5.jar /storage/emulated/0/Shite/APKEditor.jar
                        else
                            echo -e "${RED}[!] Download failed${RESET}"
                            cd "$HOME" && rm -rf "$HOME/temp_downloads"
                            return 1
                        fi
                        cd "$HOME" && rm -rf "$HOME/temp_downloads"
                    fi

                    # Ensure Java tools
                    if ! command -v keytool &> /dev/null || ! command -v jarsigner &> /dev/null; then
                        pkg install -y openjdk-17
                    fi

                    # Auto-detect APKS/XAPK
                    auto_detect_apk() {
                        local apk_dir="/storage/emulated/0/Shite/apks"
                        mkdir -p "$apk_dir"
                        find "$apk_dir" -maxdepth 1 -type f \( -name "*.apk" -o -name "*.apks" -o -name "*.xapk" \) -print -quit
                    }

                    apk_file=$(auto_detect_apk)
                    if [ -z "$apk_file" ]; then
                        echo -e "${RED}[!] No APKS/XAPK files found in /storage/emulated/0/Shite/apks/. Returning to Blutter Suite...${RESET}"
                        sleep 2
                        return
                    fi

                    apk_name=$(basename "${apk_file%.*}")

                    while true; do
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
                                cd /storage/emulated/0/Shite/
                                rm -f "apks/$apk_name.apk" 2>/dev/null
                                java -jar APKEditor.jar m -i "apks/$apk_name.apks" -o "apks/$apk_name.apk"
                                ;;
                            2)
                                cd /storage/emulated/0/Shite/
                                rm -rf "apks/$apk_name/" 2>/dev/null
                                java -jar APKEditor.jar d -i "apks/$apk_name.apk" -o "apks/$apk_name/"
                                ;;
                            3)
                                cd /storage/emulated/0/Shite/
                                rm -f "apks/$apk_name.apk" 2>/dev/null
                                java -jar APKEditor.jar b -i "apks/$apk_name/" -o "apks/$apk_name.apk"
                                ;;
                            4)
                                cd /storage/emulated/0/Shite/
                                rm -f "apks/${apk_name}_refactored.apk" 2>/dev/null
                                java -jar APKEditor.jar x -i "apks/$apk_name.apk" -o "apks/${apk_name}_refactored.apk"
                                ;;
                            5)
                                cd /storage/emulated/0/Shite/
                                rm -f "apks/${apk_name}_protected.apk" 2>/dev/null
                                java -jar APKEditor.jar p -i "apks/$apk_name.apk" -o "apks/${apk_name}_protected.apk"
                                ;;
                            6)
                                return
                                ;;
                        esac

                        # Re-check if APK exists
                        apk_file=$(auto_detect_apk)
                        if [ -z "$apk_file" ]; then
                            echo -e "${RED}[!] APK disappeared. Returning to Blutter Suite...${RESET}"
                            sleep 2
                            return
                        fi
                        apk_name=$(basename "${apk_file%.*}")
                    done
                }
                apk_editor_loop
                ;;
            2)
                if [ -d "$HOME/blutter-termux" ]; then
                    pkg install -y python pip clang
                    cd "$HOME"
                    git clone https://github.com/P1sec/hermes-dec.git
                    pip install --upgrade git+https://github.com/P1sec/hermes-dec.git
                else
                    echo -e "${RED}[!] Install Blutter first${RESET}"
                fi
                read -p "Press [Enter] to continue..."
                ;;
            3)
                # =====[ Blutter Manager ]=====
                while true; do
                    if [ -d "$HOME/blutter-termux" ]; then
                        installed_version="Dedshit"
                        installed_path="$HOME/blutter-termux"
                    else
                        installed_version="None"
                        installed_path=""
                    fi

                    blutter_option=$(dialog --title "Blutter Manager (Installed: $installed_version)" \
                        --menu "Select an option:" 15 60 5 \
                        1 "Fresh Install Blutter" \
                        2 "Check for Update Blutter" \
                        3 "Reprovision Blutter" \
                        4 "Nuke Blutter Completely" \
                        5 "Return To Blutter Suite" 3>&1 1>&2 2>&3)

                    clear

                    case "$blutter_option" in
                        1)
                            if [ "$installed_version" != "None" ]; then
                                dialog --msgbox "Blutter is already installed.\nUse Update or Reinstall." 10 50
                            else
                                pkg update -y && pkg upgrade -y
                                pkg install -y git cmake ninja build-essential pkg-config libicu capstone fmt
                                pip install requests pyelftools
                                cd "$HOME"
                                git clone https://github.com/dedshit/blutter-termux.git
                            fi
                            ;;
                        2)
                            if [ "$installed_version" = "None" ]; then
                                dialog --msgbox "No Blutter installation found." 8 40
                            else
                                cd "$installed_path"
                                git pull
                            fi
                            ;;
                        3)
                            rm -rf "$HOME/blutter-termux"
                            cd "$HOME"
                            pkg update -y && pkg upgrade -y
                            pkg install -y git cmake ninja build-essential pkg-config libicu capstone fmt
                            pip install requests pyelftools
                            git clone https://github.com/dedshit/blutter-termux.git
                            ;;
                        4)
                            rm -rf "$HOME/blutter-termux"
                            dialog --msgbox "Blutter removed successfully." 8 40
                            ;;
                        5)
                            break
                            ;;
                    esac
                done
                ;;
            4)
                if [ -d "$HOME/blutter-termux" ]; then
                    ARM64_DIR="/storage/emulated/0/Shite/apks/arm64-v8a"
                    OUT_DIR="/storage/emulated/0/Shite/apks/out-dir"

                    if [ ! -f "$ARM64_DIR/libapp.so" ]; then
                        echo -e "${RED}[!] libapp.so missing${RESET}"
                        read -p "Press [Enter] to continue..."
                        continue
                    fi
                    if [ ! -f "$ARM64_DIR/libflutter.so" ]; then
                        echo -e "${RED}[!] libflutter.so missing${RESET}"
                        read -p "Press [Enter] to continue..."
                        continue
                    fi

                    rm -rf "$OUT_DIR" 2>/dev/null
                    mkdir -p "$OUT_DIR"

                    cd "$HOME/blutter-termux"
                    python blutter.py "$ARM64_DIR" "$OUT_DIR" >/dev/null 2>&1
                    read -p "Press [Enter] to continue..."
                else
                    echo -e "${RED}[!] Install Blutter first${RESET}"
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
    echo -e "\e[1;34m[~] Checking for updates first...\e[0m"

    # Check if we have curl available
    if command -v curl &> /dev/null; then
        # Force an update check by temporarily changing version to trigger update
        OLD_VERSION="$SCRIPT_VERSION"
        SCRIPT_VERSION="0.0.0"  # Force update check to find newer version

        # Call the update function
        if check_and_update; then
            # If update happened, script will have already restarted
            return 0
        else
            # If no update, restore version
            SCRIPT_VERSION="$OLD_VERSION"
        fi
    else
        echo -e "\e[1;33m[!] curl not available, performing normal refresh...\e[0m"
    fi

    # Clear the screen and re-execute
    clear
    echo -e "\e[1;32m[+] Restarting script...\e[0m"
    sleep 1
    exec bash "$0" "$@"

    # If exec fails (shouldn't happen)
    echo -e "\e[1;31m[!] Refresh failed\e[0m"
    return 1
}

# =========[ Updated check_and_update function with refresh support ]=========
check_and_update() {
    echo -e "\e[1;34m[~] Checking for updates...\e[0m"

    # Check if curl is available
    if ! command -v curl &> /dev/null; then
        echo -e "\e[1;33m[!] curl not found. Skipping update check.\e[0m"
        return 1
    fi

    # Fetch the latest version from GitHub
    LATEST_VERSION=$(curl -s "$SCRIPT_URL" | grep -o 'SCRIPT_VERSION="[0-9.]*"' | head -1 | cut -d'"' -f2)

    if [ -z "$LATEST_VERSION" ]; then
        echo -e "\e[1;33m[!] Could not check for updates. Continuing with current version.\e[0m"
        return 1
    fi

    if [ "$LATEST_VERSION" != "$SCRIPT_VERSION" ]; then
        echo -e "\e[1;32m[+] Update found! Current: $SCRIPT_VERSION, Latest: $LATEST_VERSION\e[0m"
        echo -e "\e[1;34m[~] Downloading update...\e[0m"

        # Download the updated script
        curl -s "$SCRIPT_URL" -o "$0.tmp"

        if [ -f "$0.tmp" ] && [ -s "$0.tmp" ]; then
            # Make it executable and replace current script
            chmod +x "$0.tmp"
            mv "$0.tmp" "$0"
            echo -e "\e[1;32m[+] Update installed! Restarting script...\e[0m"
            echo -e "\e[1;33m========================================\e[0m"

            # Restart the script with the update
            exec bash "$0" "$@"
        else
            echo -e "\e[1;31m[!] Failed to download update. Continuing with current version.\e[0m"
            rm -f "$0.tmp" 2>/dev/null
            return 1
        fi
    else
        echo -e "\e[1;32m[✓] You are running the latest version ($SCRIPT_VERSION)\e[0m"
        return 0
    fi
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

# =========[ MainMenu ]=========
main_menu() {
    # Check if we're coming from a refresh
    if [ "$1" == "--refreshed" ]; then
        echo -e "\e[1;32m[✓] Script refreshed successfully!\e[0m"
        sleep 1
        clear
    fi

    while true; do
        main_choice=$(dialog --clear --backtitle "Termux Setup Script v$SCRIPT_VERSION" \
            --title "MainMenu" \
            --menu "Choose an option:" 22 60 10 \
            0 "File Manager" \
            1 "Blutter Suite" \
            2 "Radare2 Suite" \
            3 "Backup Tools" \
            4 "MOTD Settings" \
            5 "Install Zsh Add-ons" \
            6 "Python Packages + Plugins" \
            7 "Refresh/Update Script" \
            8 "Exit" 3>&1 1>&2 2>&3)

        clear
        case "$main_choice" in
            0) 
                file_explorer
                ;;
            1) 
                blutter_suite 
                ;;
            2) 
                radare2_suite 
                ;;
            3) 
                backup_wipe_menu 
                ;;
            4) 
                motd_prompt 
                ;;
            5) 
                install_zsh_addons 
                ;;
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
            7)
                echo -e "\e[1;33m[*] Checking for script updates...\e[0m"
                remote_version=$(curl -s "$SCRIPT_URL" | grep -m1 "SCRIPT_VERSION=" | cut -d'"' -f2)

                if [ "$remote_version" != "$SCRIPT_VERSION" ]; then
                    echo -e "\e[1;32m[+] Update found ($remote_version), updating...\e[0m"
                    if curl -s "$SCRIPT_URL" > "$0.tmp"; then
                        chmod +x "$0.tmp"
                        mv "$0.tmp" "$0"
                        echo -e "\e[1;32m[✓] Update complete. Restarting script...\e[0m"
                        sleep 2
                        exec "$0" "--refreshed"
                    else
                        echo -e "\e[1;31m[!] Update failed, refreshing current version...\e[0m"
                        sleep 2
                        exec "$0" "--refreshed"
                    fi
                else
                    echo -e "\e[1;32m[✓] Already up to date. Refreshing...\e[0m"
                    sleep 2
                    exec "$0" "--refreshed"
                fi
                ;;
            8)
                echo "Exiting..."
                exit 0
                ;;
            *) echo "Invalid option" ;;
        esac
    done
}

# =========[ File Explorer ]=========
file_explorer() {
    local current_path="$HOME"

    while true; do
        local items=()
        if [ "$current_path" != "/" ]; then
            items+=(".." "Go Up")
        fi

        while IFS= read -r dir; do
            [ -z "$dir" ] && continue
            items+=("$dir/" "DIR")
        done < <(find "$current_path" -maxdepth 1 -type d ! -path "$current_path" -printf "%f\n" | sort)

        while IFS= read -r file; do
            [ -z "$file" ] && continue
            items+=("$file" "FILE")
        done < <(find "$current_path" -maxdepth 1 -type f -printf "%f\n" | sort)

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

        case $ret in
            0) 
                if [[ "$choice" == ".." ]]; then
                    current_path=$(dirname "$current_path")
                elif [[ "$choice" == */ ]]; then
                    current_path="$current_path/${choice%/}"
                else
                    file_actions "$current_path/$choice"
                fi
                ;;
            3) 
                if [[ -n "$choice" && "$choice" != ".." ]]; then
                    target="$current_path/$choice"
                    dialog --yesno "Delete PERMANENTLY?\n$target" 7 60
                    [ $? -eq 0 ] && rm -rf "$target"
                fi
                ;;
            *) 
                return
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
            0)
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
            3)
                dialog --yesno "Delete PERMANENTLY?\n$file" 7 60
                [ $? -eq 0 ] && rm -f "$file" && return
                ;;
            *) 
                break
                ;;
        esac
    done
}

# =========[ Backup & Wipe Submenu ]=========
backup_wipe_menu() {
    while true; do
        sub_choice=$(dialog --clear --backtitle "Termux Setup Script v$SCRIPT_VERSION" \
            --title "Backup Tools" \
            --menu "Choose an option:" 15 50 4 \
            1 "Backup Environment" \
            2 "Restore Environment" \
            3 "Wipe All Packages (Caution!)" \
            4 "Return to MainMenu" 3>&1 1>&2 2>&3)

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
check_and_update
add_alias
main_menu