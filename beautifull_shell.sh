#!/bin/bash

# =============================================================================
# BEAUTIFUL SHELL - Installation complète Terminal + Oh My Posh + Kitty
# Version finale corrigée - Compatible toutes distributions Linux
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
# FONCTIONS D'AFFICHAGE (DÉFINIES EN PREMIER)
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
# =============================================================================
# KITTY TERMINAL CONFIGURATION - BEAUTIFUL SHELL
# =============================================================================

# Police et taille
font_family      JetBrainsMonoNerdFont-Regular
bold_font        JetBrainsMonoNerdFont-Bold
italic_font      JetBrainsMonoNerdFont-Italic
bold_italic_font JetBrainsMonoNerdFont-BoldItalic
font_size        11.0

# Apparence
background_opacity         0.95
confirm_os_window_close    0

# Thème Catppuccin Mocha
foreground           #cdd6f4
background           #1e1e2e
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
echo -e "  ${CYAN}🚀${NC} ${WHITE}Ready to code   ${GRAY}→${NC}  Tapez '${YELLOW}beautiful-help${NC}' pour plus de commandes"

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

# Autres fonctions à suivre...
# [Le reste du fichier sera dans la partie 2 à cause de la limite de taille]

EOF

    print_success "Configuration Beautiful Shell créée"
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
    
    echo ""
    echo -e "${GREEN}${BOLD}🎉 BEAUTIFUL SHELL INSTALLÉ ! 🎉${NC}"
    echo ""
    echo -e "${CYAN}Redémarrez votre session ou tapez : source ~/.bashrc${NC}"
    echo ""
    
    log "Installation Beautiful Shell terminée"
}

# =============================================================================
# POINT D'ENTRÉE
# =============================================================================

# Vérification que le script n'est pas sourcé
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
else
    print_error "Ce script doit être exécuté, pas sourcé"
    exit 1
fi