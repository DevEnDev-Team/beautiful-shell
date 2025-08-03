# 🦊 Beautiful Shell

**Configuration automatisée d'un terminal moderne et élégant pour Linux**

Beautiful Shell transforme votre terminal en un environnement de développement professionnel avec Oh My Posh, Kitty Terminal et des thèmes personnalisables.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Platform](https://img.shields.io/badge/platform-Linux-orange.svg)

## ✨ Fonctionnalités

### 🎨 **Interface moderne**
- **Oh My Posh** : Prompt intelligent avec informations Git, système et contexte
- **Kitty Terminal** : Terminal GPU-accéléré avec thème Catppuccin Mocha
- **JetBrains Mono Nerd Font** : Police avec icônes et ligatures
- **19 thèmes** Oh My Posh pré-installés

### 🛠️ **Outils intégrés**
- **Gestionnaire de thèmes** interactif
- **Aliases** et raccourcis pour développeurs
- **Citations inspirantes** au démarrage
- **Sauvegarde automatique** des configurations

### 🗑️ **Désinstallation propre**
- Restauration complète du système
- Remise du terminal par défaut
- Conservation des sauvegardes

## 🚀 Installation rapide

```bash
# Télécharger le script
wget https://raw.githubusercontent.com/votre-repo/beautiful-shell/main/beautiful-shell
# ou
curl -O https://raw.githubusercontent.com/votre-repo/beautiful-shell/main/beautiful-shell

# Rendre exécutable et installer
chmod +x beautiful-shell
./beautiful-shell
```

## 📋 Distributions supportées

### ✅ **Support officiel**
- **Ubuntu** / Debian / Pop!_OS / Mint / Elementary / Zorin / KDE Neon
- **Fedora** / CentOS / RHEL / Rocky Linux / AlmaLinux
- **Arch Linux** / Manjaro / EndeavourOS / ArcoLinux
- **openSUSE** / SLES
- **Void Linux**
- **Alpine Linux**

### 🔧 **Installation manuelle**
Pour les autres distributions, le script propose une installation manuelle des composants non disponibles.

## 📖 Guide d'utilisation

### 🎯 **Commandes principales**

```bash
# Aide complète
beautiful-help          # ou bs-help

# Gestion des thèmes
beautiful-themes        # ou bs-themes
omp-list               # Lister tous les thèmes
omp-theme dracula      # Tester un thème
omp-save dracula       # Sauvegarder comme défaut

# Maintenance
beautiful-remove        # ou bs-remove
beautiful-backup        # ou bs-backup
```

### 🎨 **Gestion des thèmes**

```bash
# Voir tous les thèmes disponibles
omp-list

# Tester un thème (temporaire)
omp-theme aliens
omp-theme spaceship
omp-theme atomic

# Sauvegarder un thème (permanent)
omp-save dracula

# Gestionnaire interactif
beautiful-themes
```

### 🔧 **Autres commandes utiles**

```bash
# Navigation rapide
proj                   # Aller dans ~/Documents/Projets
util                   # Aller dans ~/Documents/Utilitaires

# Git raccourcis
gs                     # git status
ga                     # git add
gc                     # git commit
gp                     # git push
gl                     # git log --oneline -10

# Système
ll                     # ls -alF avec couleurs
ports                  # Voir les ports ouverts
myip                   # Afficher IP publique
cpu                    # Utilisation CPU
```

## ⚙️ Configuration avancée

### 🎨 **Personnaliser Kitty**
```bash
# Éditer la configuration Kitty
nano ~/.config/kitty/kitty.conf

# Recharger la configuration
kitty +kitten themes
```

### 🖌️ **Créer un thème personnalisé**
```bash
# Créer un nouveau thème Oh My Posh
nano ~/.cache/oh-my-posh/themes/mon-theme.omp.json

# L'appliquer
omp-theme mon-theme
omp-save mon-theme
```

### ⌨️ **Raccourcis Kitty**
- `Ctrl+C` / `Ctrl+V` : Copier/Coller
- `Ctrl+Shift+Enter` : Nouvelle fenêtre
- `Ctrl+Shift+]` : Fenêtre suivante
- `Ctrl+Shift+[` : Fenêtre précédente
- `Ctrl+Shift+C/V` : Copier/Coller (alternative)

## 🔍 Dépannage

### ❓ **Problèmes courants**

**Oh My Posh ne s'affiche pas :**
```bash
# Recharger la configuration
source ~/.bashrc

# Réinitialiser Oh My Posh
omp-reset

# Vérifier l'installation
oh-my-posh --version
```

**Erreur CONFIG ERROR :**
```bash
# Nettoyer et réinitialiser
omp-reset
source ~/.bashrc
```

**Polices manquantes :**
```bash
# Vérifier les polices installées
fc-list | grep -i jetbrains

# Réinstaller si nécessaire
./beautiful-shell
```

### 📋 **Vérifier l'installation**
```bash
# Tests de diagnostic
oh-my-posh --version    # Doit afficher la version
kitty --version         # Doit afficher la version
beautiful-help          # Doit afficher l'aide

# Voir les sauvegardes
beautiful-backup
```

## 🗑️ Désinstallation

Beautiful Shell peut être complètement désinstallé en restaurant l'état d'origine :

```bash
# Désinstallation complète
beautiful-remove

# Suivre les instructions et confirmer avec "CONFIRMER"
```

### ✅ **La désinstallation :**
- Supprime Oh My Posh et tous les thèmes
- Restaure le `.bashrc` d'origine depuis la sauvegarde
- Remet le terminal par défaut du système
- Restaure le raccourci `Super+T`
- Propose de supprimer Kitty et les polices (optionnel)
- Nettoie toutes les configurations Beautiful Shell

## 📁 Structure des fichiers

```
~/.local/bin/oh-my-posh              # Binaire Oh My Posh
~/.cache/oh-my-posh/themes/          # Thèmes Oh My Posh
~/.config/kitty/kitty.conf           # Configuration Kitty
~/.config/kitty/startup.sh           # Script de démarrage
~/.local/share/fonts/                # Polices Nerd Fonts
~/.bashrc.backup.*                   # Sauvegardes .bashrc
```

## 🔧 Développement

### 📝 **Contribuer**
1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/amelioration`)
3. Commit vos changements (`git commit -am 'Ajouter amélioration'`)
4. Push vers la branche (`git push origin feature/amelioration`)
5. Créer une Pull Request

### 🐛 **Reporter un bug**
Utilisez les [GitHub Issues](https://github.com/votre-repo/beautiful-shell/issues) avec :
- Version de votre distribution
- Sortie de `beautiful-shell --version`
- Description détaillée du problème
- Logs si disponibles

### ✨ **Demander une fonctionnalité**
Ouvrez une [GitHub Issue](https://github.com/votre-repo/beautiful-shell/issues) avec le label `enhancement`.

## 📊 Compatibilité testée

| Distribution | Version | Status |
|-------------|---------|--------|
| Ubuntu | 20.04+ | ✅ |
| Pop!_OS | 22.04+ | ✅ |
| Fedora | 35+ | ✅ |
| Arch Linux | Rolling | ✅ |
| Debian | 11+ | ✅ |
| Mint | 20+ | ✅ |
| Manjaro | 21+ | ✅ |
| openSUSE | Leap 15+ | ✅ |

## 🎖️ Crédits

Beautiful Shell utilise et configure ces excellents projets :

- **[Oh My Posh](https://ohmyposh.dev/)** - Prompt personnalisable cross-platform
- **[Kitty](https://sw.kovidgoyal.net/kitty/)** - Terminal GPU-accéléré
- **[JetBrains Mono](https://www.jetbrains.com/lp/mono/)** - Police pour développeurs
- **[Nerd Fonts](https://www.nerdfonts.com/)** - Police avec icônes
- **[Catppuccin](https://catppuccin.com/)** - Palette de couleurs moderne

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 💖 Support

Si Beautiful Shell vous aide dans votre workflow de développement :

- ⭐ **Star** ce projet sur GitHub
- 🐛 **Reporter** les bugs que vous trouvez
- 💡 **Proposer** des améliorations
- 📢 **Partager** avec d'autres développeurs

---

**Beautiful Shell** - *Transformez votre terminal en environnement de développement moderne* 🦊

Made with ❤️ for developers