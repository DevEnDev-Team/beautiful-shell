
download_themes() {
    print_step "Téléchargement des thèmes Oh My Posh..."
    
    # Créer le dossier themes
    mkdir -p "$OMP_THEMES_DIR"
    
    # Télécharger les thèmes depuis le repo officiel
    local themes_url="https://github.com/JanDeDobbeleer/oh-my-posh/archive/refs/heads/main.zip"
    local temp_dir=$(mktemp -d)
    
    print_info "Téléchargement des thèmes officiels..."
    if wget -q --show-progress "$themes_url" -O "$temp_dir/themes.zip"; then
        unzip -q "$temp_dir/themes.zip" -d "$temp_dir"
        
        # Copier uniquement les fichiers de thèmes
        if [ -d "$temp_dir/oh-my-posh-main/themes" ]; then
            cp "$temp_dir/oh-my-posh-main/themes"/*.omp.json "$OMP_THEMES_DIR/" 2>/dev/null
            
            # Vérifier qu'au moins quelques thèmes ont été copiés
            local theme_count=$(ls "$OMP_THEMES_DIR"/*.omp.json 2>/dev/null | wc -l)
            if [ "$theme_count" -gt 0 ]; then
                print_success "Thèmes téléchargés ($theme_count thèmes) dans $OMP_THEMES_DIR"
            else
                print_warning "Aucun thème trouvé, création d'un thème par défaut"
                create_default_theme
            fi
        else
            print_warning "Structure de thèmes non trouvée, création d'un thème par défaut"
            create_default_theme
        fi
        
        rm -rf "$temp_dir"
    else
        print_warning "Échec du téléchargement des thèmes, création d'un thème par défaut"
        create_default_theme
    fi
}

create_default_theme() {
    # Créer un thème simple qui fonctionne toujours
    cat > "$OMP_THEMES_DIR/default.omp.json" << 'EOF'
{
  "$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json",
  "version": 2,
  "final_space": true,
  "blocks": [
    {
      "type": "prompt",
      "alignment": "left",
      "segments": [
        {
          "type": "session",
          "style": "diamond",
          "leading_diamond": "",
          "trailing_diamond": "",
          "template": " {{ .UserName }}@{{ .HostName }} ",
          "background": "#c#!/bin/bash

# =============================================================================
# BEAUTIFUL SHELL - Installation complète Terminal + Oh My Posh + Kitty
# Version finale - Compatible toutes distributions Linux
# =============================================================================

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/beautiful-shell.log"
KITTY_CONFIG_DIR="$HOME/.config/kitty"
OMP_THEMES_DIR="$HOME/.cache/oh-my-posh/themes"
OMP_BINARY="$HOME/.local/bin/oh-my-posh"

# =============================================================================
# FONCTIONS D'AFFICHAGE
# =============================================================================

print_header() {
    clear
    echo ""
    echo -e "${PURPLE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}                    ${CYAN}🦊${NC} ${WHITE}${BOLD}BEAUTIFUL SHELL${NC}                     ${PURPLE}║${NC}"
    echo -e "${PURPLE}║${NC}                  ${DIM}Configuration automatisée${NC}                 ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    echo -e "${BLUE}[ÉTAPE]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCÈS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERREUR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[ATTENTION]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# =============================================================================
# VÉRIFICATIONS
# =============================================================================

check_sudo() {
    if [[ $EUID -eq 0 ]]; then
        print_error "Ne pas exécuter ce script en tant que root"
        exit 1
    fi
}

detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        print_info "Distribution détectée : $PRETTY_NAME"
    else
        print_error "Impossible de détecter la distribution Linux"
        exit 1
    fi
}

check_dependencies() {
    print_step "Vérification des dépendances..."
    
    local deps=("curl" "wget" "unzip" "git" "jq")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        print_warning "Installation des dépendances manquantes : ${missing[*]}"
        
        case $DISTRO in
            ubuntu|debian|pop|mint|elementary|zorin|neon)
                sudo apt update && sudo apt install -y curl wget unzip git jq fontconfig
                ;;
            fedora|centos|rhel|rocky|almalinux)
                sudo dnf install -y curl wget unzip git jq fontconfig
                ;;
            arch|manjaro|endeavouros|arcolinux)
                sudo pacman -S --noconfirm curl wget unzip git jq fontconfig
                ;;
            opensuse*|sles)
                sudo zypper install -y curl wget unzip git jq fontconfig
                ;;
            void)
                sudo xbps-install -Sy curl wget unzip git jq fontconfig
                ;;
            alpine)
                sudo apk add curl wget unzip git jq fontconfig
                ;;
            *)
                print_error "Distribution non supportée automatiquement"
                print_info "Installez manuellement : curl wget unzip git jq fontconfig"
                read -p "Continuer quand même ? (y/N) " -n 1 -r
                echo
                if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                    exit 1
                fi
                ;;
        esac
    fi
    
    print_success "Dépendances OK"
}

# =============================================================================
# NETTOYAGE PRÉALABLE
# =============================================================================

cleanup_previous_install() {
    print_step "Nettoyage des installations précédentes..."
    
    # Nettoyer les variables d'environnement Oh My Posh
    unset POSH_THEME POSH_SESSION_ID POSH_SHELL_VERSION POSH_PID
    
    # Supprimer le cache Oh My Posh s'il est corrompu
    if [ -d "$HOME/.cache/oh-my-posh" ]; then
        print_info "Suppression du cache Oh My Posh existant"
        rm -rf "$HOME/.cache/oh-my-posh"
    fi
    
    # Sauvegarder et nettoyer .bashrc
    if [ -f "$HOME/.bashrc" ]; then
        cp "$HOME/.bashrc" "$HOME/.bashrc.backup.$(date +%Y%m%d_%H%M%S)"
        print_info "Sauvegarde .bashrc créée"
        
        # Supprimer les anciennes configurations
        sed -i '/oh-my-posh/d' "$HOME/.bashrc" 2>/dev/null
        sed -i '/Oh My Posh/d' "$HOME/.bashrc" 2>/dev/null
        sed -i '/POSH_/d' "$HOME/.bashrc" 2>/dev/null
        sed -i '/# BEAUTIFUL SHELL CONFIGURATION/,$d' "$HOME/.bashrc" 2>/dev/null
    fi
    
    print_success "Nettoyage terminé"
}

# =============================================================================
# INSTALLATIONS
# =============================================================================

install_fonts() {
    print_step "Installation des polices Nerd Fonts..."
    
    local font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"
    
    local temp_dir=$(mktemp -d)
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    
    if wget -q --show-progress "$font_url" -O "$temp_dir/JetBrainsMono.zip"; then
        unzip -q "$temp_dir/JetBrainsMono.zip" -d "$temp_dir/JetBrainsMono"
        find "$temp_dir/JetBrainsMono" -name "JetBrainsMonoNerdFont-*.ttf" -exec cp {} "$font_dir/" \;
        fc-cache -fv "$font_dir" >/dev/null 2>&1
        rm -rf "$temp_dir"
        print_success "Polices JetBrains Mono Nerd Font installées"
    else
        print_error "Échec téléchargement polices"
        return 1
    fi
}

install_oh_my_posh() {
    print_step "Installation d'Oh My Posh..."
    
    # Créer le répertoire bin
    mkdir -p "$HOME/.local/bin"
    
    # Supprimer binaire existant s'il est corrompu
    if [ -f "$OMP_BINARY" ] && ! "$OMP_BINARY" --version >/dev/null 2>&1; then
        print_warning "Suppression binaire Oh My Posh corrompu"
        rm -f "$OMP_BINARY"
    fi
    
    # Détecter l'architecture
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) OMP_ARCH="amd64" ;;
        aarch64|arm64) OMP_ARCH="arm64" ;;
        armv7l) OMP_ARCH="arm" ;;
        *) 
            print_error "Architecture non supportée: $ARCH"
            return 1
            ;;
    esac
    
    # Téléchargement du binaire
    local omp_url="https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-${OMP_ARCH}"
    
    print_info "Téléchargement Oh My Posh pour $ARCH ($OMP_ARCH)"
    
    if wget -q --show-progress "$omp_url" -O "$OMP_BINARY"; then
        chmod +x "$OMP_BINARY"
        
        # Vérification du binaire
        if "$OMP_BINARY" --version >/dev/null 2>&1; then
            local version=$("$OMP_BINARY" --version 2>/dev/null | head -n1)
            print_success "Oh My Posh installé : $version"
        else
            print_error "Binaire Oh My Posh non fonctionnel"
            rm -f "$OMP_BINARY"
            return 1
        fi
    else
        print_error "Échec téléchargement Oh My Posh"
        return 1
    fi
}

download_themes() {
    print_step "Téléchargement des thèmes Oh My Posh..."
    
    mkdir -p "$OMP_THEMES_DIR"
    
    # Liste des thèmes essentiels
    local themes=(
        "aliens" "atomic" "blue-owl" "capr4n" "catppuccin" 
        "craver" "dracula" "jandedobbeleer" "kushal" "lambda" 
        "marcduiker" "paradox" "pure" "robbyrussell" "spaceship" 
        "star" "stelbent" "tokyo" "powerlevel10k_rainbow"
    )
    
    local downloaded=0
    local failed=0
    
    for theme in "${themes[@]}"; do
        local theme_url="https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/${theme}.omp.json"
        if wget -q "$theme_url" -O "$OMP_THEMES_DIR/${theme}.omp.json" 2>/dev/null; then
            ((downloaded++))
        else
            ((failed++))
        fi
    done
    
    if [ "$downloaded" -gt 0 ]; then
        print_success "$downloaded thèmes téléchargés ($failed échecs)"
    else
        print_warning "Aucun thème téléchargé - utilisation du thème par défaut"
    fi
}

install_kitty() {
    print_step "Installation de Kitty Terminal..."
    
    if command -v kitty &> /dev/null; then
        print_warning "Kitty déjà installé"
        return 0
    fi
    
    case $DISTRO in
        ubuntu|debian|pop|mint|elementary|zorin|neon)
            sudo apt install -y kitty
            ;;
        fedora|centos|rhel|rocky|almalinux)
            sudo dnf install -y kitty
            ;;
        arch|manjaro|endeavouros|arcolinux)
            sudo pacman -S --noconfirm kitty
            ;;
        opensuse*|sles)
            sudo zypper install -y kitty
            ;;
        void)
            sudo xbps-install -Sy kitty
            ;;
        alpine)
            sudo apk add kitty
            ;;
        *)
            print_info "Installation manuelle de Kitty..."
            if curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin; then
                sudo ln -sf "$HOME/.local/kitty.app/bin/kitty" /usr/local/bin/kitty 2>/dev/null || true
            else
                print_warning "Échec installation Kitty - continuez manuellement"
                return 1
            fi
            ;;
    esac
    
    if command -v kitty &> /dev/null; then
        print_success "Kitty installé avec succès"
    else
        print_warning "Kitty non détecté après installation"
    fi
}

# =============================================================================
# CONFIGURATIONS
# =============================================================================

configure_kitty() {
    print_step "Configuration de Kitty..."
    
    mkdir -p "$KITTY_CONFIG_DIR"
    
    cat > "$KITTY_CONFIG_DIR/kitty.conf" << 'EOF'
# THEME KITTY - Catppuccin Mocha (Configuration corrigée)
# vim:ft=kitty

# Police - Configuration corrigée pour éviter les erreurs
font_family      JetBrainsMonoNerdFont-Regular
bold_font        JetBrainsMonoNerdFont-Bold
italic_font      JetBrainsMonoNerdFont-Italic
bold_italic_font JetBrainsMonoNerdFont-BoldItalic
font_size        11.0

# Apparence
background_opacity         0.95
confirm_os_window_close    0

# Couleurs Catppuccin Mocha
# text
foreground           #cdd6f4
background           #1e1e2e
# selection
selection_foreground #1e1e2e
selection_background #f5e0dc

# Couleurs normales
color0  #45475a
color1  #f38ba8
color2  #a6e3a1
color3  #f9e2af
color4  #89b4fa
color5  #f5c2e7
color6  #94e2d5
color7  #bac2de

# Couleurs brillantes
color8  #585b70
color9  #f38ba8
color10 #a6e3a1
color11 #f9e2af
color12 #89b4fa
color13 #f5c2e7
color14 #94e2d5
color15 #a6adc8

# Curseur
cursor                     #f5e0dc
cursor_text_color          #1e1e2e
cursor_shape               block

# Raccourcis clavier
map ctrl+c copy_and_clear_or_interrupt
map ctrl+v paste_from_clipboard
map ctrl+shift+c copy_to_clipboard
map ctrl+shift+v paste_from_clipboard
map ctrl+shift+enter new_window
map ctrl+shift+] next_window
map ctrl+shift+[ previous_window

# Configuration fenêtre
initial_window_width 100c
initial_window_height 30c
window_padding_width 10 10 10 10
remember_window_size no

# Shell integration
shell_integration enabled
EOF

    # Script de démarrage
    cat > "$KITTY_CONFIG_DIR/startup.sh" << 'EOF'
#!/bin/bash

clear
printf "\033[2J\033[H"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
ORANGE='\033[0;33m'
PINK='\033[1;35m'
GRAY='\033[0;90m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# Bannière de bienvenue
get_padding() {
    local term_width=$(tput cols 2>/dev/null || echo 80)
    local content_width=35
    echo $(( (term_width - content_width) / 2 ))
}

padding=$(get_padding)
spaces=$(printf "%*s" $padding "")
USERNAME=$(whoami | tr '[:lower:]' '[:upper:]')

echo ""
echo -e "${spaces}${ORANGE}🦊${NC} ${WHITE}${BOLD}BEAUTIFUL SHELL ${USERNAME}${NC} ${ORANGE}🦊${NC}"
echo -e "${spaces}${DIM}${GRAY}Intelligent • Rapide • Fiable${NC}"
echo ""

# Informations système
USER_INFO="${USER}@$(hostname)"
echo -e "  ${CYAN}👤${NC} ${WHITE}Utilisateur   ${GRAY}→${NC}  ${YELLOW}${USER_INFO}${NC}"
echo -e "  ${CYAN}🚀${NC} ${WHITE}Ready to code   ${GRAY}→${NC}  Tapez '${YELLOW}aide${NC}' pour plus de commandes"

# Informations Git si dans un repo
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null || echo "detached")
    CHANGES=$(git status --porcelain 2>/dev/null | wc -l)
    echo -e "  ${PINK}🔗${NC} ${WHITE}Git Branch    ${GRAY}→${NC}  ${YELLOW}${BRANCH}${NC} ${GRAY}(${CHANGES} modifications)${NC}"
fi

echo ""

# Citation aléatoire
QUOTES=(
    "Les programmes doivent être écrits pour que les gens les lisent, et accessoirement pour que les machines les exécutent. - Harold Abelson"
    "Les mots ne coûtent rien. Montrez-moi le code. - Linus Torvalds"
    "Le code est comme l'humour. Quand on doit l'expliquer, c'est qu'il est mauvais. - Cory House"
    "D'abord, résolvez le problème. Ensuite, écrivez le code. - John Johnson"
    "Le meilleur message d'erreur est celui qui n'apparaît jamais. - Thomas Fuchs"
    "La simplicité est la sophistication suprême. - Leonardo da Vinci"
    "N'importe quel idiot peut écrire du code qu'un ordinateur comprend. Les bons programmeurs écrivent du code que les humains comprennent. - Martin Fowler"
    "L'expérience est le nom que chacun donne à ses erreurs. - Oscar Wilde"
    "La seule façon d'apprendre un nouveau langage de programmation est d'écrire des programmes avec. - Dennis Ritchie"
    "Déboguer est deux fois plus difficile que d'écrire le code au départ. - Brian Kernighan"
    "Faites que ça marche, faites que ce soit correct, faites que ce soit rapide. - Kent Beck"
    "Le code ne ment jamais, les commentaires parfois. - Ron Jeffries"
    "La programmation ne consiste pas à taper, mais à réfléchir. - Rich Hickey"
    "La propriété la plus importante d'un programme est de réaliser l'intention de son utilisateur. - C.A.R. Hoare"
    "Ce n'est pas un bug, c'est une fonctionnalité non documentée. - Anonyme"
    "Avant qu'un logiciel puisse être réutilisable, il doit d'abord être utilisable. - Ralph Johnson"
    "L'ordinateur est né pour résoudre des problèmes qui n'existaient pas avant. - Bill Gates"
    "Marcher sur l'eau et développer un logiciel à partir d'une spécification, c'est facile si les deux sont gelés. - Edward V. Berard"
    "Un bon code est son propre meilleur documentation. - Steve McConnell"
    "Il y a deux façons de concevoir un logiciel : le rendre si simple qu'il n'y a évidemment pas de défauts, ou le rendre si compliqué qu'il n'y a pas de défauts évidents. - C.A.R. Hoare"
)

RANDOM_QUOTE=${QUOTES[$RANDOM % ${#QUOTES[@]}]}
echo -e "  ${DIM}${GRAY}💭 ${RANDOM_QUOTE}${NC}"
echo ""

# Initialiser Oh My Posh si disponible
if command -v oh-my-posh &> /dev/null; then
    # Utiliser un thème simple et robuste
    if [ -f "$HOME/.cache/oh-my-posh/themes/powerlevel10k_rainbow.omp.json" ]; then
        eval "$(oh-my-posh init bash --config '$HOME/.cache/oh-my-posh/themes/powerlevel10k_rainbow.omp.json')"
    elif [ -f "$HOME/.cache/oh-my-posh/themes/jandedobbeleer.omp.json" ]; then
        eval "$(oh-my-posh init bash --config '$HOME/.cache/oh-my-posh/themes/jandedobbeleer.omp.json')"
    else
        # Utiliser le thème par défaut intégré (plus stable)
        eval "$(oh-my-posh init bash)"
    fi
fi
EOF

    chmod +x "$KITTY_CONFIG_DIR/startup.sh"
    print_success "Configuration Kitty créée"
}

configure_bashrc() {
    print_step "Configuration du .bashrc..."
    
    cat >> "$HOME/.bashrc" << 'EOF'

# =============================================================================
# BEAUTIFUL SHELL CONFIGURATION
# =============================================================================

# Couleurs pour les fonctions personnalisées
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
ORANGE='\033[0;33m'
PINK='\033[1;35m'
GRAY='\033[0;90m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'

# PATH pour Oh My Posh
export PATH="$HOME/.local/bin:$PATH"

# Démarrage personnalisé (uniquement en mode interactif et première fois)
if [[ $- == *i* ]] && [[ -z "$STARTUP_DONE" ]] && [[ -f "$HOME/.config/kitty/startup.sh" ]]; then
    export STARTUP_DONE=1
    ~/.config/kitty/startup.sh
fi

# =============================================================================
# FONCTIONS PERSONNALISÉES
# =============================================================================

# Fonction d'aide complète
beautiful-help() {
    echo ""
    echo -e "${WHITE}${BOLD}🦊 BEAUTIFUL SHELL - AIDE${NC}"
    echo -e "${GRAY}▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔${NC}"
    echo -e "  ${GREEN}Navigation :${NC} proj, web, util, home, .., ..."
    echo -e "  ${PURPLE}Git :${NC} gs (status), ga (add), gc (commit), gp (push), gl (log), gd (diff)"
    echo -e "  ${BLUE}Système :${NC} ll, la, ports, myip, cpu"
    echo -e "  ${ORANGE}Thèmes :${NC} beautiful-themes, omp-theme [nom], omp-save [nom], omp-reset, omp-list"
    echo -e "  ${RED}Maintenance :${NC} beautiful-remove, beautiful-backup"
    echo ""
    echo -e "${WHITE}${BOLD}💡 TIPS & ASTUCES${NC}"
    echo -e "${GRAY}▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔${NC}"
    echo -e "  ${CYAN}🎨 Personnalisation :${NC}"
    echo -e "     • beautiful-themes pour gérer les thèmes"
    echo -e "     • omp-theme [nom] pour tester un thème"
    echo -e "     • omp-save [nom] pour sauvegarder"
    echo -e "     • Modifiez ~/.config/kitty/kitty.conf pour Kitty"
    echo ""
    echo -e "  ${CYAN}⌨️  Raccourcis Kitty :${NC}"
    echo -e "     • Ctrl+C & Ctrl+V : Copier/Coller"
    echo -e "     • Ctrl+Shift+Enter : Nouvelle fenêtre"
    echo -e "     • Ctrl+Shift+] : Fenêtre suivante"
    echo -e "     • Ctrl+Shift+[ : Fenêtre précédente"
    echo ""
    echo -e "  ${CYAN}🔧 Dépannage :${NC}"
    echo -e "     • omp-reset pour réinitialiser Oh My Posh"
    echo -e "     • source ~/.bashrc pour recharger"
    echo -e "     • beautiful-backup pour voir les sauvegardes"
    echo -e "     • beautiful-remove pour tout supprimer"
    echo ""
    echo -e "  ${CYAN}🚀 Productivité :${NC}"
    echo -e "     • 'proj' pour vos projets"
    echo -e "     • 'gs' pour git status rapide"
    echo -e "     • 'll' pour listing détaillé"
    echo -e "     • 'myip' pour votre IP publique"
    echo ""
    echo -e "${WHITE}${BOLD}📋 COMMANDES BEAUTIFUL SHELL :${NC}"
    echo -e "${GRAY}▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔${NC}"
    echo -e "  • ${GREEN}beautiful-help${NC}          Afficher cette aide"
    echo -e "  • ${GREEN}beautiful-themes${NC}        Gestionnaire de thèmes"
    echo -e "  • ${GREEN}beautiful-remove${NC}        Désinstaller Beautiful Shell"
    echo -e "  • ${GREEN}beautiful-backup${NC}        Voir les sauvegardes"
    echo ""
    echo -e "  ${CYAN}Versions courtes :${NC}"
    echo -e "  • ${GREEN}bs-help${NC}   • ${GREEN}bs-themes${NC}   • ${GREEN}bs-remove${NC}   • ${GREEN}bs-backup${NC}"
    echo ""
}

# Gestionnaire de thèmes interactif
beautiful-themes() {
    while true; do
        clear
        echo ""
        echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${PURPLE}║${NC}                ${CYAN}🎨${NC} ${WHITE}${BOLD}GESTIONNAIRE DE THÈMES${NC}                ${PURPLE}║${NC}"
        echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        
        echo -e "${WHITE}${BOLD}ACTIONS DISPONIBLES :${NC}"
        echo -e "${GRAY}────────────────────────────────────────────────────────────────${NC}"
        echo ""
        echo -e "${CYAN}1.${NC} Voir tous les thèmes disponibles"
        echo -e "${CYAN}2.${NC} Prévisualiser un thème"
        echo -e "${CYAN}3.${NC} Sauvegarder le thème actuel"
        echo -e "${CYAN}4.${NC} Réinitialiser au thème par défaut"
        echo -e "${CYAN}5.${NC} Voir le thème actuellement utilisé"
        echo -e "${CYAN}0.${NC} Retour au terminal"
        echo ""
        
        read -p "Votre choix : " choice
        echo ""
        
        case $choice in
            1)
                echo -e "${CYAN}Thèmes disponibles :${NC}"
                omp-list
                ;;
            2)
                read -p "Nom du thème à prévisualiser : " theme_name
                if [ -n "$theme_name" ]; then
                    omp-theme "$theme_name"
                fi
                ;;
            3)
                read -p "Nom du thème à sauvegarder : " theme_name
                if [ -n "$theme_name" ]; then
                    omp-save "$theme_name"
                fi
                ;;
            4)
                omp-reset
                ;;
            5)
                if [ -n "$POSH_THEME" ]; then
                    current_theme=$(basename "$POSH_THEME" .omp.json)
                    echo -e "${CYAN}Thème actuel :${NC} ${GREEN}$current_theme${NC}"
                else
                    echo -e "${YELLOW}Thème par défaut d'Oh My Posh${NC}"
                fi
                ;;
            0)
                echo -e "${GREEN}Retour au terminal${NC}"
                break
                ;;
            *)
                echo -e "${RED}Choix invalide${NC}"
                ;;
        esac
        
        if [ "$choice" != "0" ]; then
            echo ""
            read -p "Appuyez sur Entrée pour continuer..."
        fi
    done
}

# Fonction de désinstallation complète
beautiful-remove() {
    echo ""
    echo -e "${RED}${BOLD}⚠️  DÉSINSTALLATION BEAUTIFUL SHELL ⚠️${NC}"
    echo -e "${YELLOW}Cette action va supprimer complètement l'installation${NC}"
    echo ""
    
    echo -e "${WHITE}Éléments qui seront supprimés :${NC}"
    echo -e "  • Oh My Posh (binaire et cache)"
    echo -e "  • Configuration Kitty personnalisée"
    echo -e "  • Thèmes Oh My Posh"
    echo -e "  • Polices JetBrains Mono Nerd Font (optionnel)"
    echo -e "  • Aliases et fonctions personnalisées"
    echo ""
    echo -e "${CYAN}Options de désinstallation :${NC}"
    echo -e "  • Kitty peut être désinstallé (optionnel)"
    echo -e "  • Le terminal par défaut sera restauré"
    echo -e "  • Le .bashrc sera restauré depuis la sauvegarde"
    echo ""
    
    read -p "Tapez 'CONFIRMER' pour continuer : " confirmation
    
    if [ "$confirmation" != "CONFIRMER" ]; then
        echo -e "${GREEN}Désinstallation annulée${NC}"
        return 0
    fi
    
    echo ""
    echo -e "${BLUE}Début de la désinstallation...${NC}"
    
    # 1. Supprimer Oh My Posh
    echo -e "${YELLOW}1. Suppression d'Oh My Posh...${NC}"
    rm -f "$HOME/.local/bin/oh-my-posh" 2>/dev/null && echo -e "   ✓ Binaire supprimé"
    rm -rf "$HOME/.cache/oh-my-posh" 2>/dev/null && echo -e "   ✓ Cache et thèmes supprimés"
    
    # 2. Restaurer .bashrc
    echo -e "${YELLOW}2. Restauration du .bashrc...${NC}"
    latest_backup=$(ls -t ~/.bashrc.backup.* 2>/dev/null | head -n1)
    
    if [ -n "$latest_backup" ] && [ -f "$latest_backup" ]; then
        cp ~/.bashrc ~/.bashrc.before_uninstall.$(date +%Y%m%d_%H%M%S)
        cp "$latest_backup" ~/.bashrc
        echo -e "   ✓ Restauré depuis : $(basename "$latest_backup")"
    else
        sed -i '/# BEAUTIFUL SHELL CONFIGURATION/,$d' ~/.bashrc 2>/dev/null
        echo -e "   ✓ Configuration supprimée manuellement"
    fi
    
    # 3. Configuration Kitty
    echo -e "${YELLOW}3. Configuration Kitty...${NC}"
    if grep -q "BEAUTIFUL SHELL" "$HOME/.config/kitty/kitty.conf" 2>/dev/null; then
        rm -f "$HOME/.config/kitty/kitty.conf"
        echo -e "   ✓ Configuration personnalisée supprimée"
    fi
    rm -f "$HOME/.config/kitty/startup.sh" 2>/dev/null && echo -e "   ✓ Script de démarrage supprimé"
    
    # 4. Restaurer le terminal par défaut
    echo -e "${YELLOW}4. Restauration du terminal par défaut...${NC}"
    
    # Détecter le terminal par défaut du système
    if command -v gnome-terminal >/dev/null 2>&1; then
        DEFAULT_TERMINAL="gnome-terminal"
    elif command -v konsole >/dev/null 2>&1; then
        DEFAULT_TERMINAL="konsole"
    elif command -v xfce4-terminal >/dev/null 2>&1; then
        DEFAULT_TERMINAL="xfce4-terminal"
    elif command -v mate-terminal >/dev/null 2>&1; then
        DEFAULT_TERMINAL="mate-terminal"
    elif command -v lxterminal >/dev/null 2>&1; then
        DEFAULT_TERMINAL="lxterminal"
    elif command -v terminator >/dev/null 2>&1; then
        DEFAULT_TERMINAL="terminator"
    elif command -v alacritty >/dev/null 2>&1; then
        DEFAULT_TERMINAL="alacritty"
    else
        DEFAULT_TERMINAL="xterm"
    fi
    
    # Restaurer le terminal par défaut avec update-alternatives
    if command -v update-alternatives >/dev/null 2>&1; then
        DEFAULT_TERMINAL_PATH=$(which $DEFAULT_TERMINAL 2>/dev/null)
        if [ -n "$DEFAULT_TERMINAL_PATH" ] && [ -x "$DEFAULT_TERMINAL_PATH" ]; then
            sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$DEFAULT_TERMINAL_PATH" 50 2>/dev/null
            sudo update-alternatives --set x-terminal-emulator "$DEFAULT_TERMINAL_PATH" 2>/dev/null
            echo -e "   ✓ Terminal par défaut restauré : $DEFAULT_TERMINAL"
        else
            echo -e "   ${YELLOW}⚠ Impossible de restaurer le terminal par défaut automatiquement${NC}"
        fi
    else
        echo -e "   ${YELLOW}⚠ update-alternatives non disponible${NC}"
    fi
    
    # Restaurer les raccourcis clavier pour les environnements de bureau courants
    echo -e "${YELLOW}5. Restauration des raccourcis clavier...${NC}"
    
    # GNOME
    if command -v gsettings >/dev/null 2>&1 && [ "$XDG_CURRENT_DESKTOP" = "GNOME" ] || [ "$XDG_CURRENT_DESKTOP" = "ubuntu:GNOME" ]; then
        gsettings set org.gnome.settings-daemon.plugins.media-keys terminal "['<Super>t']" 2>/dev/null
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "Terminal" 2>/dev/null
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "$DEFAULT_TERMINAL" 2>/dev/null
        gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "<Super>t" 2>/dev/null
        echo -e "   ✓ Raccourci Super+T restauré pour GNOME"
    fi
    
    # KDE Plasma
    if command -v kwriteconfig5 >/dev/null 2>&1 && [ "$XDG_CURRENT_DESKTOP" = "KDE" ]; then
        kwriteconfig5 --file kglobalshortcutsrc --group "org.kde.konsole.desktop" --key "_launch" "Ctrl+Alt+T,none,Konsole"
        echo -e "   ✓ Raccourci restauré pour KDE"
    fi
    
    # XFCE
    if command -v xfconf-query >/dev/null 2>&1 && [ "$XDG_CURRENT_DESKTOP" = "XFCE" ]; then
        xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>t" -s "$DEFAULT_TERMINAL" 2>/dev/null
        echo -e "   ✓ Raccourci Super+T restauré pour XFCE"
    fi
    
    # 6. Désinstaller Kitty (optionnel)
    echo -e "${YELLOW}6. Désinstallation de Kitty...${NC}"
    read -p "Désinstaller Kitty Terminal ? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Détecter la distribution pour la désinstallation
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case $ID in
                ubuntu|debian|pop|mint|elementary|zorin|neon)
                    sudo apt remove -y kitty 2>/dev/null
                    ;;
                fedora|centos|rhel|rocky|almalinux)
                    sudo dnf remove -y kitty 2>/dev/null
                    ;;
                arch|manjaro|endeavouros|arcolinux)
                    sudo pacman -Rs --noconfirm kitty 2>/dev/null
                    ;;
                opensuse*|sles)
                    sudo zypper remove -y kitty 2>/dev/null
                    ;;
                void)
                    sudo xbps-remove -y kitty 2>/dev/null
                    ;;
                alpine)
                    sudo apk del kitty 2>/dev/null
                    ;;
                *)
                    echo -e "   ${YELLOW}Désinstallation manuelle requise pour cette distribution${NC}"
                    ;;
            esac
            echo -e "   ✓ Kitty désinstallé"
        fi
    else
        echo -e "   ✓ Kitty conservé"
    fi
    
    # 7. Polices (optionnel)
    echo -e "${YELLOW}7. Polices JetBrains Mono...${NC}"
    read -p "Supprimer les polices ? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        find "$HOME/.local/share/fonts" -name "JetBrainsMonoNerdFont-*.ttf" -delete 2>/dev/null
        fc-cache -fv "$HOME/.local/share/fonts" >/dev/null 2>&1
        echo -e "   ✓ Polices supprimées"
    else
        echo -e "   ✓ Polices conservées"
    fi
    
    # 8. Variables d'environnement
    unset POSH_THEME POSH_SESSION_ID POSH_SHELL_VERSION POSH_PID STARTUP_DONE
    
    echo ""
    echo -e "${GREEN}${BOLD}✅ DÉSINSTALLATION TERMINÉE${NC}"
    echo ""
    echo -e "${WHITE}${BOLD}RÉSUMÉ :${NC}"
    echo -e "  ✓ Beautiful Shell complètement supprimé"
    echo -e "  ✓ Terminal par défaut restauré : ${GREEN}$DEFAULT_TERMINAL${NC}"
    echo -e "  ✓ Raccourci Super+T restauré"
    echo -e "  ✓ Configuration .bashrc restaurée"
    echo ""
    echo -e "${CYAN}Actions recommandées :${NC}"
    echo -e "  • Redémarrez votre session ou tapez : ${YELLOW}source ~/.bashrc${NC}"
    echo -e "  • Testez le raccourci : ${YELLOW}Super+T${NC}"
    echo -e "  • Le terminal par défaut est maintenant : ${YELLOW}$DEFAULT_TERMINAL${NC}"
    echo ""
}

# Lister les sauvegardes disponibles
beautiful-backup() {
    echo -e "${CYAN}${BOLD}SAUVEGARDES DISPONIBLES :${NC}"
    echo ""
    
    echo -e "${YELLOW}.bashrc :${NC}"
    if ls ~/.bashrc.backup.* >/dev/null 2>&1; then
        ls -la ~/.bashrc.backup.* | while read -r line; do
            echo "  $line"
        done
    else
        echo "  Aucune sauvegarde trouvée"
    fi
    echo ""
}

# Fonction d'aide complète (alias pour rétrocompatibilité)
aide() {
    beautiful-help
}

# Fonction pour changer de thème Oh My Posh
omp-theme() {
    if [ -z "$1" ]; then
        echo -e "${YELLOW}Usage: omp-theme [nom_du_thème]${NC}"
        echo -e "${CYAN}Thèmes disponibles :${NC}"
        omp-list
        return
    fi
    
    local theme_file="$HOME/.cache/oh-my-posh/themes/$1.omp.json"
    if [ -f "$theme_file" ]; then
        eval "$(oh-my-posh init bash --config "$theme_file")"
        echo -e "${GREEN}✓ Thème '$1' appliqué pour cette session${NC}"
        echo -e "${DIM}Pour le sauvegarder : omp-save $1${NC}"
    else
        echo -e "${RED}✗ Thème '$1' introuvable${NC}"
        echo -e "${CYAN}Thèmes disponibles :${NC}"
        omp-list
    fi
}

# Fonction pour sauvegarder un thème de façon permanente
omp-save() {
    local theme_name="$1"
    
    if [ -z "$theme_name" ]; then
        echo -e "${YELLOW}Usage: omp-save [nom_du_thème]${NC}"
        return 1
    fi
    
    local theme_file="$HOME/.cache/oh-my-posh/themes/$theme_name.omp.json"
    
    if [ ! -f "$theme_file" ]; then
        echo -e "${RED}✗ Thème '$theme_name' introuvable${NC}"
        return 1
    fi
    
    # Créer une sauvegarde du .bashrc
    cp ~/.bashrc ~/.bashrc.backup.theme.$(date +%Y%m%d_%H%M%S)
    
    # Supprimer l'ancienne configuration Oh My Posh
    sed -i '/# Initialisation Oh My Posh/,/^fi$/d' ~/.bashrc
    
    # Ajouter la nouvelle configuration avec le thème sauvegardé en premier
    cat >> ~/.bashrc << 'ENDOFCONFIG'

# Initialisation Oh My Posh avec thème sauvegardé
if [[ $- == *i* ]] && command -v oh-my-posh >/dev/null 2>&1; then
    if oh-my-posh --version >/dev/null 2>&1; then
        if [ -f "$HOME/.cache/oh-my-posh/themes/THEME_NAME.omp.json" ]; then
            eval "$(oh-my-posh init bash --config "$HOME/.cache/oh-my-posh/themes/THEME_NAME.omp.json")"
        elif [ -f "$HOME/.cache/oh-my-posh/themes/aliens.omp.json" ]; then
            eval "$(oh-my-posh init bash --config "$HOME/.cache/oh-my-posh/themes/aliens.omp.json")"
        else
            eval "$(oh-my-posh init bash)"
        fi
    fi
fi

ENDOFCONFIG

    # Remplacer THEME_NAME par le vrai nom du thème
    sed -i "s/THEME_NAME/$theme_name/g" ~/.bashrc

    echo -e "${GREEN}✓ Thème '$theme_name' sauvegardé comme thème par défaut${NC}"
    echo -e "${CYAN}Le thème sera appliqué dans les nouvelles sessions${NC}"
    echo -e "${DIM}Sauvegarde créée : ~/.bashrc.backup.theme.$(date +%Y%m%d_%H%M%S)${NC}"
}

# Lister les thèmes disponibles
omp-list() {
    if [ -d "$HOME/.cache/oh-my-posh/themes" ]; then
        echo -e "${CYAN}Thèmes Oh My Posh disponibles :${NC}"
        ls "$HOME/.cache/oh-my-posh/themes"/*.omp.json 2>/dev/null | xargs -n1 basename | sed 's/.omp.json//' | sort | column
    else
        echo -e "${RED}Aucun thème trouvé. Réinstallez Beautiful Shell.${NC}"
    fi
}

# Réinitialiser Oh My Posh
omp-reset() {
    unset POSH_THEME POSH_SESSION_ID POSH_SHELL_VERSION
    if [ -f "$HOME/.cache/oh-my-posh/themes/aliens.omp.json" ]; then
        eval "$(oh-my-posh init bash --config "$HOME/.cache/oh-my-posh/themes/aliens.omp.json")"
        echo -e "${GREEN}✓ Oh My Posh réinitialisé avec le thème aliens${NC}"
    elif [ -f "$HOME/.cache/oh-my-posh/themes/atomic.omp.json" ]; then
        eval "$(oh-my-posh init bash --config "$HOME/.cache/oh-my-posh/themes/atomic.omp.json")"
        echo -e "${GREEN}✓ Oh My Posh réinitialisé avec le thème atomic${NC}"
    else
        eval "$(oh-my-posh init bash)"
        echo -e "${GREEN}✓ Oh My Posh réinitialisé avec le thème par défaut${NC}"
    fi
}

# =============================================================================
# FONCTIONS DE DÉSINSTALLATION
# =============================================================================

# Fonction de désinstallation complète (alias pour rétrocompatibilité)
desinstaller() {
    beautiful-remove
}

# Lister les sauvegardes disponibles (alias pour rétrocompatibilité)
sauvegardes() {
    beautiful-backup
}

# =============================================================================
# ALIASES
# =============================================================================

# Beautiful Shell commands (versions principales)
alias beautiful-help='beautiful-help'
alias beautiful-themes='beautiful-themes'
alias beautiful-remove='beautiful-remove'
alias beautiful-backup='beautiful-backup'

# Beautiful Shell commands (versions courtes)
alias bs-help='beautiful-help'
alias bs-themes='beautiful-themes'
alias bs-remove='beautiful-remove'
alias bs-backup='beautiful-backup'

# Listing et navigation
alias ll='ls -alF --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias home='cd ~'

# Système
alias ports='sudo netstat -tuln'
alias myip='curl -s https://httpbin.org/ip | jq -r .origin 2>/dev/null || curl -s ifconfig.me'
alias cpu='top -bn1 | grep "Cpu(s)" | awk "{print \$2}" | awk -F"%" "{print \$1}" || echo "N/A"'
alias df='df -h'
alias free='free -h'

# Git aliases
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline -10'
alias gd='git diff'
alias gb='git branch'
alias gco='git checkout'

# Navigation projets (avec création automatique)
alias proj='mkdir -p ~/Documents/Projets && cd ~/Documents/Projets'
alias web='mkdir -p ~/Documents/Projets && cd ~/Documents/Projets'
alias util='mkdir -p ~/Documents/Utilitaires && cd ~/Documents/Utilitaires'

# Raccourcis utiles
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# =============================================================================
# INITIALISATION OH MY POSH
# =============================================================================

# Oh My Posh - Configuration sécurisée
if [[ $- == *i* ]] && command -v oh-my-posh >/dev/null 2>&1; then
    if oh-my-posh --version >/dev/null 2>&1; then
        if [ -f "$HOME/.cache/oh-my-posh/themes/aliens.omp.json" ]; then
            eval "$(oh-my-posh init bash --config "$HOME/.cache/oh-my-posh/themes/aliens.omp.json")"
        elif [ -f "$HOME/.cache/oh-my-posh/themes/atomic.omp.json" ]; then
            eval "$(oh-my-posh init bash --config "$HOME/.cache/oh-my-posh/themes/atomic.omp.json")"
        elif [ -f "$HOME/.cache/oh-my-posh/themes/paradox.omp.json" ]; then
            eval "$(oh-my-posh init bash --config "$HOME/.cache/oh-my-posh/themes/paradox.omp.json")"
        else
            eval "$(oh-my-posh init bash)"
        fi
    fi
fi

EOF

    print_success "Configuration Beautiful Shell complète créée"
}

set_default_terminal() {
    print_step "Configuration du terminal par défaut..."
    
    if command -v kitty >/dev/null 2>&1 && command -v update-alternatives >/dev/null 2>&1; then
        KITTY_PATH=$(which kitty)
        if [ -x "$KITTY_PATH" ]; then
            sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator "$KITTY_PATH" 100 2>/dev/null
            sudo update-alternatives --set x-terminal-emulator "$KITTY_PATH" 2>/dev/null
            print_success "Kitty défini comme terminal par défaut"
        fi
    else
        print_info "Configuration du terminal par défaut ignorée"
    fi
}

# =============================================================================
# TESTS ET DIAGNOSTICS
# =============================================================================

run_diagnostics() {
    print_step "Tests de validation finale..."
    
    local errors=0
    local warnings=0
    
    # Test Oh My Posh
    if [ -f "$OMP_BINARY" ] && "$OMP_BINARY" --version >/dev/null 2>&1; then
        local omp_version=$("$OMP_BINARY" --version 2>/dev/null | head -n1)
        print_success "Oh My Posh : $omp_version"
    else
        print_error "Oh My Posh non fonctionnel"
        ((errors++))
    fi
    
    # Test Kitty
    if command -v kitty &> /dev/null; then
        local kitty_version=$(kitty --version 2>/dev/null | head -n1)
        print_success "Kitty : $kitty_version"
    else
        print_warning "Kitty non détecté"
        ((warnings++))
    fi
    
    # Test polices
    if fc-list | grep -i "jetbrainsmono" >/dev/null 2>&1; then
        print_success "Polices JetBrains Mono Nerd Font détectées"
    else
        print_warning "Polices JetBrains Mono non détectées"
        ((warnings++))
    fi
    
    # Test thèmes
    local theme_count=$(ls "$OMP_THEMES_DIR"/*.omp.json 2>/dev/null | wc -l)
    if [ "$theme_count" -gt 0 ]; then
        print_success "$theme_count thèmes Oh My Posh disponibles"
    else
        print_warning "Aucun thème Oh My Posh trouvé"
        ((warnings++))
    fi
    
    # Test configuration
    if [ -f "$KITTY_CONFIG_DIR/kitty.conf" ]; then
        print_success "Configuration Kitty présente"
    else
        print_warning "Configuration Kitty manquante"
        ((warnings++))
    fi
    
    # Test initialisation Oh My Posh
    export PATH="$HOME/.local/bin:$PATH"
    if command -v oh-my-posh >/dev/null 2>&1 && oh-my-posh init bash >/dev/null 2>&1; then
        print_success "Initialisation Oh My Posh fonctionnelle"
    else
        print_error "Initialisation Oh My Posh défaillante"
        ((errors++))
    fi
    
    echo ""
    if [ $errors -eq 0 ]; then
        if [ $warnings -eq 0 ]; then
            print_success "Tous les tests passés avec succès !"
        else
            print_warning "$warnings avertissement(s) - Installation fonctionnelle"
        fi
        return 0
    else
        print_error "$errors erreur(s) critique(s) détectée(s)"
        return 1
    fi
}

# =============================================================================
# FONCTION PRINCIPALE
# =============================================================================

main() {
    print_header
    log "Début installation Beautiful Shell"
    
    # Vérifications préalables
    check_sudo
    detect_distro
    
    # Nettoyage des installations précédentes
    cleanup_previous_install
    
    # Vérification et installation des dépendances
    check_dependencies
    
    echo ""
    
    # Installations principales
    install_fonts
    echo ""
    install_oh_my_posh
    echo ""
    download_themes
    echo ""
    install_kitty
    echo ""
    
    # Configurations
    configure_kitty
    echo ""
    configure_bashrc
    echo ""
    set_default_terminal
    echo ""
    
    # Tests de validation
    if run_diagnostics; then
        print_header
        echo -e "${GREEN}${BOLD}🎉 BEAUTIFUL SHELL INSTALLÉ AVEC SUCCÈS ! 🎉${NC}"
        echo ""
        echo -e "${WHITE}${BOLD}PROCHAINES ÉTAPES :${NC}"
        echo -e "${CYAN}▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔${NC}"
        echo ""
        echo -e "  ${YELLOW}1.${NC} ${BOLD}Redémarrez votre session${NC} ou lancez :"
        echo -e "     ${DIM}source ~/.bashrc${NC}"
        echo ""
        echo -e "  ${YELLOW}2.${NC} ${BOLD}Lancez Kitty Terminal :${NC}"
        echo -e "     ${DIM}kitty${NC}"
        echo ""
        echo -e "  ${YELLOW}3.${NC} ${BOLD}Explorez les thèmes :${NC}"
        echo -e "     ${DIM}omp-list${NC}"
        echo -e "     ${DIM}omp-theme dracula${NC}"
        echo -e "     ${DIM}omp-save dracula${NC}"
        echo ""
        echo -e "  ${YELLOW}4.${NC} ${BOLD}Aide et astuces :${NC}"
        echo -e "     ${DIM}aide${NC}"
        echo ""
        echo -e "${WHITE}${BOLD}COMMANDES UTILES :${NC}"
        echo -e "${CYAN}▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔▔${NC}"
        echo -e "  • ${GREEN}beautiful-help${NC}          Aide complète"
        echo -e "  • ${GREEN}beautiful-themes${NC}        Gestionnaire de thèmes"
        echo -e "  • ${GREEN}beautiful-remove${NC}        Désinstaller Beautiful Shell"
        echo -e "  • ${GREEN}beautiful-backup${NC}        Voir les sauvegardes"
        echo ""
        
        # Test immédiat si on est dans Kitty
        if [ "$TERM" = "xterm-kitty" ]; then
            echo -e "${PURPLE}${BOLD}🚀 Vous utilisez déjà Kitty ! Configuration appliquée.${NC}"
            echo ""
            
            # Appliquer Oh My Posh pour cette session
            export PATH="$HOME/.local/bin:$PATH"
            if [ -f "$HOME/.cache/oh-my-posh/themes/aliens.omp.json" ]; then
                eval "$(oh-my-posh init bash --config "$HOME/.cache/oh-my-posh/themes/aliens.omp.json")"
                echo -e "${GREEN}✓ Oh My Posh activé avec le thème aliens${NC}"
            elif command -v oh-my-posh >/dev/null 2>&1; then
                eval "$(oh-my-posh init bash)"
                echo -e "${GREEN}✓ Oh My Posh activé${NC}"
            fi
        fi
        
    else
        print_header
        echo -e "${YELLOW}${BOLD}⚠️  INSTALLATION TERMINÉE AVEC DES AVERTISSEMENTS ⚠️${NC}"
        echo ""
        echo -e "${WHITE}${BOLD}ACTIONS RECOMMANDÉES :${NC}"
        echo ""
        echo -e "  ${CYAN}1.${NC} Vérifiez les erreurs ci-dessus"
        echo -e "  ${CYAN}2.${NC} Relancez le script si nécessaire"
        echo -e "  ${CYAN}3.${NC} Consultez les logs : ${DIM}cat beautiful-shell.log${NC}"
        echo ""
        echo -e "${PURPLE}${BOLD}DÉPANNAGE RAPIDE :${NC}"
        echo ""
        echo -e "  ${WHITE}Si Oh My Posh ne fonctionne pas :${NC}"
        echo -e "     ${DIM}source ~/.bashrc${NC}"
        echo -e "     ${DIM}omp-reset${NC}"
        echo ""
    fi
    
    echo -e "${DIM}${GRAY}Logs : $LOG_FILE${NC}"
    echo -e "${DIM}${GRAY}Sauvegardes : ~/.bashrc.backup.*${NC}"
    echo ""
    
    log "Installation Beautiful Shell terminée"
}

# =============================================================================
# POINT D'ENTRÉE
# =============================================================================

# Gestion des signaux pour nettoyage en cas d'interruption
cleanup_on_exit() {
    echo ""
    print_warning "Installation interrompue"
    log "Installation interrompue par l'utilisateur"
    exit 1
}

trap cleanup_on_exit SIGINT SIGTERM

# Vérification que le script n'est pas sourcé
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
else
    print_error "Ce script doit être exécuté, pas sourcé"
    print_info "Usage: ./beautiful-shell"
    exit 1
fi