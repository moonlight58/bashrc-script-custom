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

# Configuration options with descriptions
declare -a CONFIG_KEYS=("basic_aliases" "git_aliases" "system_aliases" "npm_aliases" "vencord_function" "git_push_function" "starship_init")
declare -A CONFIG_OPTIONS=(
    ["basic_aliases"]="Basic shortcuts (cls, c, quit, q, src)"
    ["git_aliases"]="Git shortcuts (gst, gpl, gpu, gco, gcm, gaa)"
    ["system_aliases"]="System management (pls, install, remove, update)"
    ["npm_aliases"]="NPM shortcuts (nrs, nrd)"
    ["vencord_function"]="Discord Vencord installer/updater function"
    ["git_push_function"]="Advanced git-push function with sync"
    ["starship_init"]="Starship prompt initialization"
)

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
        local checkbox="◌"
        
        # Highlight current selection
        if [ $i -eq $CURRENT_SELECTION ]; then
            prefix="> "
            color="${CYAN}"
        fi
        
        # Show selected items
        if [[ ${SELECTED_OPTIONS[$key]} == "1" ]]; then
            checkbox="◉"
        fi
        
        echo -e "${color}${prefix}${checkbox} ${CONFIG_OPTIONS[$key]}${NC}"
        ((i++))
    done
    
    echo
    echo -e "${GRAY}(Use arrow keys to move, <space> to select, <a> to toggle all, <i> to invert selection)${NC}"
}

# Function to handle user input
handle_input() {
    local key
    read -rsn1 key
    
    case $key in
        A) # Up arrow (actually part of escape sequence)
            read -rsn2 -t 0.1 key
            if [[ $key == "[A" ]]; then
                ((CURRENT_SELECTION--))
                if [ $CURRENT_SELECTION -lt 0 ]; then
                    CURRENT_SELECTION=$((${#CONFIG_KEYS[@]} - 1))
                fi
            fi
            ;;
        B) # Down arrow
            read -rsn2 -t 0.1 key
            if [[ $key == "[B" ]]; then
                ((CURRENT_SELECTION++))
                if [ $CURRENT_SELECTION -ge ${#CONFIG_KEYS[@]} ]; then
                    CURRENT_SELECTION=0
                fi
            fi
            ;;
        $'\e') # Escape sequence
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
            ;;
        ' ') # Space bar - toggle selection
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
        $'\n'|'') # Enter key
            return 1 # Signal to exit
            ;;
        'q'|'Q'|$'\x03') # q or Ctrl+C
            echo
            echo -e "${YELLOW}Configuration cancelled.${NC}"
            exit 0
            ;;
    esac
    return 0
}

# Function to show the selection interface
show_selection_interface() {
    while true; do
        draw_interface
        if ! handle_input; then
            break
        fi
    done
    
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
        cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d_%H%M%S)
        echo -e "${GREEN}✓${NC} Backup created: ~/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
    fi
}

# Configuration generators
generate_basic_aliases() {
    cat << 'EOF'

# Custom Basic Aliases
alias cls='clear'
alias c='clear'
alias quit='exit'
alias q='exit'
alias src='source ~/.bashrc'

EOF
}

generate_git_aliases() {
    cat << 'EOF'

# Custom Git Aliases
alias gst='git status'
alias gpl='git pull'
alias gpu='git push'
alias gco='git checkout'
alias gcm='git commit -m'
alias gaa='git add .'

EOF
}

generate_system_aliases() {
    cat << 'EOF'

# System Management Aliases
alias pls="sudo"
alias install="sudo apt install"
alias remove="sudo apt remove"
alias update="sudo apt update && sudo apt upgrade"

EOF
}

generate_npm_aliases() {
    cat << 'EOF'

# NPM Aliases
alias nrs='npm run serve'
alias nrd='npm run dev'

EOF
}

generate_vencord_function() {
    cat << 'EOF'

# Fonction update/install discord - vencord
vencord-discord() {
    # vérif argument
    if [ $# -ne 1 ]; then
        echo "Usage: vencord-discord install/update"
        return 1
    fi

    local type_install="$1"

    echo "=== $type_install the discord client ==="

    echo "=== Downloading the latest stable version of Discord ==="
    curl -o discord.tar.gz -J --location-trusted --max-redirs 10 "https://discord.com/api/download/stable?platform=linux&format=tar.gz"

    echo "=== Updating Discord to the latest stable version ==="
    tar -xzf discord.tar.gz

    echo "=== $type_install Discord files to /opt/discord/ ==="
    sudo mkdir -p /opt/discord
    sudo cp -r Discord/* /opt/discord/

    echo "=== Modifying the desktop file for custom folder ==="
    sudo sed -i 's|Exec=/usr/share/discord/Discord|Exec=/usr/bin/discord|' /opt/discord/discord.desktop
    sudo sed -i 's|Icon=discord|Icon=/opt/discord/discord.png|' /opt/discord/discord.desktop

    echo "=== Installing Discord ==="
    if [ $1 == "install" ]; then
        # set symlink
        sudo ln -sf /opt/discord/Discord /usr/bin/discord

        echo "$"
    fi

    echo "=== Add execute permission and set root user ==="
    sudo chown root:root -R /opt/discord/
    sudo chmod -R +x /opt/discord/

    echo "=== Delete temp files ==="
    rm -rf discord.tar.gz Discord

    echo "Launching Vencord Installer/Updater..."
    sh -c "$(curl -sS https://raw.githubusercontent.com/Vendicated/VencordInstaller/main/install.sh)"

    echo -e "\e[32m=== Operation completed successfully! ===\e[0m"
}

EOF
}

generate_git_push_function() {
    cat << 'EOF'

# Fonction git-push
git-push() {
    # Vérification du premier argument (message de commit)
    if [ $# -ne 1 ]; then
        echo -e "\e[33mUsage: git-push \"message du commit\" branch\e[0m"
        echo -e "\e[33m   or: git-push \"message du commit\"\e[0m"
        return 1
    fi

    local commit_message="$1"
    local branch="$2"

    # Si la branche n'est pas fournie, utiliser la branche actuelle
    if [ -z "$branch" ]; then
        branch=$(git branch --show-current)
        if [ -z "$branch" ]; then
            echo -e "\e[31mErreur: Impossible de déterminer la branche actuelle. Veuillez spécifier une branche.\e[0m"
            return 1
        fi
        echo -e "\e[33m Récupération de la branche actuelle: $branch\e[0m"
    fi

    echo -e "\e[32m=== Synchronisation avec le repo distant ===\e[0m"

    # Fetch des dernières modifications
    echo "Récupération des dernières modifications du repo distant..."
    if ! git fetch origin; then
        echo -e "\e[31mErreur lors du fetch. Arrêt de l'opération.\e[0m"
        return 1
    fi

    # Vérification si on est sur la bonne branche
    current_branch=$(git branch --show-current)
    if [ "$current_branch" != "$branch" ]; then
        echo "Passage à la branche: $branch"
        if ! git checkout "$branch"; then
            echo -e "\e[31mErreur lors du changement de branche. Arrêt de l'opération.\e[0m"
            return 1
        fi
    fi

    # Vérification s'il y a des modifications distantes
    local_commit=$(git rev-parse HEAD)
    remote_commit=$(git rev-parse "origin/$branch" 2>/dev/null)

    if [ "$local_commit" != "$remote_commit" ]; then
        echo "Des modifications distantes ont été détectées. Mise à jour locale..."
        if ! git pull origin "$branch"; then
            echo -e "\e[31mErreur lors du pull. Veuillez résoudre les conflits manuellement.\e[0m"
            return 1
        fi
        echo "Synchronisation terminée avec succès."
    else
        echo "Le repo local est déjà à jour."
    fi

    echo -e "\e[32m=== Création et envoi du commit ===\e[0m"

    # Vérification s'il y a des modifications à committer
    if git diff --quiet && git diff --cached --quiet; then
        echo -e "\e[35mAucune modification à committer.\e[0m"
        return 0
    fi

    # Ajout des fichiers modifiés
    echo "Ajout des fichiers modifiés..."
    git add .

    # Création du commit
    echo "Création du commit avec le message: '$commit_message'"
    if ! git commit -m "$commit_message"; then
        echo -e "\e[31mErreur lors de la création du commit.\e[0m"
        return 1
    fi

    # Push vers la branche
    echo "Push vers la branche: $branch"
    if ! git push origin "$branch"; then
        echo -e "\e[31mErreur lors du push.\e[0m"
        return 1
    fi

    echo -e "\e[32m=== Opération terminée avec succès ! ===\e[0m"
}

EOF
}

generate_starship_init() {
    cat << 'EOF'

# Starship prompt initialization
eval "$(starship init bash)"

EOF
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
    echo -e "${BLUE}📝 Adding configurations to ~/.bashrc...${NC}"
    
    # Add header comment
    echo "" >> ~/.bashrc
    echo "# === Added by Bashrc Configurator $(date) ===" >> ~/.bashrc
    
    for key in "${CONFIG_KEYS[@]}"; do
        if [[ ${SELECTED_OPTIONS[$key]} == "1" ]]; then
            echo -e "  ${GREEN}✓${NC} Adding ${CONFIG_OPTIONS[$key]}"
            case $key in
                "basic_aliases") generate_basic_aliases >> ~/.bashrc ;;
                "git_aliases") generate_git_aliases >> ~/.bashrc ;;
                "system_aliases") generate_system_aliases >> ~/.bashrc ;;
                "npm_aliases") generate_npm_aliases >> ~/.bashrc ;;
                "vencord_function") generate_vencord_function >> ~/.bashrc ;;
                "git_push_function") generate_git_push_function >> ~/.bashrc ;;
                "starship_init") generate_starship_init >> ~/.bashrc ;;
            esac
        fi
    done
    
    echo "# === End of Bashrc Configurator additions ===" >> ~/.bashrc
    echo "" >> ~/.bashrc
    
    echo
    echo -e "${GREEN}🎉 Successfully created bashrc configuration!${NC}"
    echo
    echo -e "${YELLOW}Get started with the following commands:${NC}"
    echo
    echo -e " ${GRAY}$${NC} ${CYAN}source ~/.bashrc${NC}"
    echo -e " ${GRAY}$${NC} ${CYAN}# Or restart your terminal${NC}"
    echo
    echo -e "${GRAY}You can always restore from backup if needed.${NC}"
}

# Check if we're in a terminal that supports the required features
if [ ! -t 0 ]; then
    echo -e "${RED}Error: This script requires an interactive terminal.${NC}"
    exit 1
fi

# Run the script
main "$@"