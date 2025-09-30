#!/bin/bash

# Bashrc Configuration Script
# Vue CLI-style interactive tool to add aliases, functions, and configurations to .bashrc

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
GRAY='\033[1;30m'
NC='\033[0m' # No Color

# Dossier contenant les scripts de configuration
CONFIG_DIR="./scripts"

# Générer dynamiquement les clés et descriptions
CONFIG_KEYS=()
declare -A CONFIG_OPTIONS=()

for file in "$CONFIG_DIR"/*; do
    [ -e "$file" ] || continue
    key=$(basename "$file")
    CONFIG_KEYS+=("$key")
    # Lire la première ligne pour la description
    desc=$(head -n 1 "$file" | sed 's/^# *//')
    CONFIG_OPTIONS["$key"]="$desc"
done

declare -A SELECTED_OPTIONS=()
CURRENT_SELECTION=0

# Function to draw the selection interface
draw_interface() {
    clear
    echo -e "${CYAN}"
    echo "Bashrc CLI v1.0.0"
    echo
    echo -e "${NC}? ${GREEN}Please pick a preset:${NC} ${GRAY}Manually select features${NC}"
    echo -e "${NC}? ${GREEN}Check the features needed for your project:${NC}"
    echo

    local i=0
    for key in "${CONFIG_KEYS[@]}"; do
        local prefix="  "
        local color="${NC}"
        local checkbox="⭘"

        # Highlight current selection
        if [ $i -eq $CURRENT_SELECTION ]; then
            prefix="> "
            color="${CYAN}"
        fi

        # Show selected items
        if [[ ${SELECTED_OPTIONS[$key]} == "1" ]]; then
            checkbox="⏺"
        fi

        echo -e "${color}${prefix}${checkbox} ${CONFIG_OPTIONS[$key]}${NC}"
        ((i++))
    done

    echo
    echo -e "${GRAY}(Use arrow keys to move, <s> to select, <a> to toggle all, <i> to invert selection, <e> to confirm)${NC}"
}

# Function to handle user input
handle_input() {
    local key

    # Read a single character
    read -rsn1 key

    # Handle escape sequences (arrow keys)
    if [[ $key == $'\e' ]]; then
        read -rsn2 -t 0.1 key
        case $key in
            "[A") # Up arrow
                ((CURRENT_SELECTION--))
                if [ $CURRENT_SELECTION -lt 0 ]; then
                    CURRENT_SELECTION=$((${#CONFIG_KEYS[@]} - 1))
                fi
                ;;
            "[B") # Down arrow
                ((CURRENT_SELECTION++))
                if [ $CURRENT_SELECTION -ge ${#CONFIG_KEYS[@]} ]; then
                    CURRENT_SELECTION=0
                fi
                ;;
        esac
    else
        case $key in
            's'|'S') # S key - toggle selection
                local current_key=${CONFIG_KEYS[$CURRENT_SELECTION]}
                if [[ ${SELECTED_OPTIONS[$current_key]} == "1" ]]; then
                    SELECTED_OPTIONS[$current_key]=""
                else
                    SELECTED_OPTIONS[$current_key]="1"
                fi
                ;;
            'a'|'A') # Toggle all
                local all_selected=1
                for key in "${CONFIG_KEYS[@]}"; do
                    if [[ ${SELECTED_OPTIONS[$key]} != "1" ]]; then
                        all_selected=0
                        break
                    fi
                done

                if [ $all_selected -eq 1 ]; then
                    # Deselect all
                    for key in "${CONFIG_KEYS[@]}"; do
                        SELECTED_OPTIONS[$key]=""
                    done
                else
                    # Select all
                    for key in "${CONFIG_KEYS[@]}"; do
                        SELECTED_OPTIONS[$key]="1"
                    done
                fi
                ;;
            'i'|'I') # Invert selection
                for key in "${CONFIG_KEYS[@]}"; do
                    if [[ ${SELECTED_OPTIONS[$key]} == "1" ]]; then
                        SELECTED_OPTIONS[$key]=""
                    else
                        SELECTED_OPTIONS[$key]="1"
                    fi
                done
                ;;
            'e'|'E') # E key - confirm selection
                return 1 # Signal to exit
                ;;
            'q'|'Q'|$'\x03') # q or Ctrl+C
                echo
                echo -e "${YELLOW}Configuration cancelled.${NC}"
                exit 0
                ;;
        esac
    fi
    return 0
}

# Function to show the selection interface
show_selection_interface() {
    # Configure terminal for raw input
    stty -echo -icanon min 1 time 0

    while true; do
        draw_interface
        if ! handle_input; then
            break
        fi
    done

    # Restore terminal settings
    stty echo icanon

    # Check if any options were selected
    local has_selections=0
    for key in "${CONFIG_KEYS[@]}"; do
        if [[ ${SELECTED_OPTIONS[$key]} == "1" ]]; then
            has_selections=1
            break
        fi
    done

    if [ $has_selections -eq 0 ]; then
        echo
        echo -e "${YELLOW}No configurations selected. Exiting.${NC}"
        exit 0
    fi
}

# Function to backup .bashrc
backup_bashrc() {
    if [ -f ~/.bashrc ]; then
        local backup_name="$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
        cp ~/.bashrc "$backup_name"
        echo -e "${GREEN}✓${NC} Backup created: $backup_name"
    fi
}

# Main function
main() {
    # Show the Vue CLI-style interface
    show_selection_interface

    clear
    echo -e "${CYAN}Bashrc CLI v1.0.0${NC}"
    echo
    echo -e "${GREEN}✨ Creating bashrc configuration...${NC}"
    echo

    # Show selected configurations
    echo -e "${GREEN}Selected configurations:${NC}"
    for key in "${CONFIG_KEYS[@]}"; do
        if [[ ${SELECTED_OPTIONS[$key]} == "1" ]]; then
            echo -e "  ${GREEN}◉${NC} ${CONFIG_OPTIONS[$key]}"
        fi
    done
    echo

    # Create backup
    backup_bashrc

    # Add configurations
    echo -e "${BLUE}🔧 Adding configurations to ~/.bashrc...${NC}"

    # Add header comment
    echo "" >> ~/.bashrc
    echo "# === Added by Bashrc Configurator $(date) ===" >> ~/.bashrc

    for key in "${CONFIG_KEYS[@]}"; do
        if [[ ${SELECTED_OPTIONS[$key]} == "1" ]]; then
            file="$CONFIG_DIR/$key"
            desc="# ${CONFIG_OPTIONS[$key]}"
            # Vérification si le bloc existe déjà (on cherche la description)
            if ! grep -qF "$desc" ~/.bashrc; then
                echo -e "  ${GREEN}✓${NC} Adding ${CONFIG_OPTIONS[$key]}"
                cat "$file" >> ~/.bashrc
                echo "
                " >> ~/.bashrc
            else
                echo -e "  ${YELLOW}⚠ ${NC} ${CONFIG_OPTIONS[$key]} already present, skipping."
            fi
        fi
    done

    echo "# === End of Bashrc Configurator additions ===" >> ~/.bashrc
    echo "" >> ~/.bashrc

    echo
    echo -e "${GREEN}🎉 Successfully created bashrc configuration!${NC}"
    echo
    echo -e "${YELLOW}Get started with the following commands:${NC}"
    echo
    echo -e " ${GRAY}\$${NC} ${CYAN}source ~/.bashrc${NC}"
    echo -e " ${GRAY}\$${NC} ${CYAN}# Or restart your terminal${NC}"
    echo
    echo -e "${GRAY}You can always restore from backup if needed.${NC}"
}

# Trap to restore terminal settings on exit
trap 'stty echo icanon' EXIT

# Check if we're in a terminal that supports the required features
if [ ! -t 0 ]; then
    echo -e "${RED}Error: This script requires an interactive terminal.${NC}"
    exit 1
fi

# Run the script
main "$@"