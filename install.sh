#!/usr/bin/env bash
# =============================================================================
#  install.sh — déploiement du setup AwesomeWM « Mr. Robot » sur Ubuntu
#
#  Étapes :
#    1. apt install des dépendances (cf. INSTALL.MD §2 & §3)
#    2. backup éventuel des fichiers existants
#    3. copie dotfiles/ → ~/
#    4. génération du wallpaper noir (ImageMagick)
#    5. adaptation interface Wi-Fi / batterie au matériel local
#    6. xrdb -merge ~/.Xresources si un DISPLAY est dispo
#    7. validation awesome -k
#
#  Usage :
#    ./install.sh           # installation complète
#    ./install.sh --no-apt  # saute l'étape apt (config seule)
# =============================================================================

set -euo pipefail

# ---------- couleurs --------------------------------------------------------
if [[ -t 1 ]]; then
    GREEN=$'\033[1;32m'; YELLOW=$'\033[1;33m'; RED=$'\033[1;31m'; RESET=$'\033[0m'
else
    GREEN=""; YELLOW=""; RED=""; RESET=""
fi
info()  { printf '%s==>%s %s\n'  "$GREEN"  "$RESET" "$*"; }
warn()  { printf '%s!!%s  %s\n'  "$YELLOW" "$RESET" "$*"; }
error() { printf '%sXX%s  %s\n'  "$RED"    "$RESET" "$*" >&2; }

# ---------- pré-vérifs ------------------------------------------------------
if [[ $EUID -eq 0 ]]; then
    error "Ne lance pas ce script en root. sudo sera appelé au besoin."
    exit 1
fi

if ! command -v apt >/dev/null 2>&1; then
    error "apt introuvable : ce script cible Ubuntu / Debian."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES="$SCRIPT_DIR/dotfiles"

if [[ ! -d $DOTFILES ]]; then
    error "Dossier dotfiles/ introuvable à côté du script ($DOTFILES)."
    exit 1
fi

DO_APT=1
for arg in "$@"; do
    case "$arg" in
        --no-apt) DO_APT=0 ;;
        -h|--help)
            sed -n '2,/^# ===/p' "$0" | sed 's/^# \{0,1\}//'
            exit 0
            ;;
        *) warn "Argument inconnu : $arg" ;;
    esac
done

# ---------- 1. apt install --------------------------------------------------
if [[ $DO_APT -eq 1 ]]; then
    info "Installation des paquets via apt (sudo demandé)"
    sudo apt update
    sudo apt install -y \
        awesome awesome-extra \
        rxvt-unicode \
        fonts-terminus fonts-jetbrains-mono \
        picom feh rofi i3lock flameshot \
        irssi ranger htop neofetch \
        net-tools wireless-tools acpi pulseaudio-utils \
        network-manager-gnome \
        xserver-xephyr imagemagick
else
    warn "Étape apt sautée (--no-apt)"
fi

# ---------- 2. backups ------------------------------------------------------
STAMP="$(date +%s)"
backup_if_exists() {
    local target="$1"
    if [[ -e $target && ! -L $target ]]; then
        local bak="${target}.bak.${STAMP}"
        info "Backup : $target → $bak"
        mv "$target" "$bak"
    fi
}

backup_if_exists "$HOME/.Xresources"
backup_if_exists "$HOME/.config/awesome/rc.lua"
backup_if_exists "$HOME/.config/awesome/theme/theme.lua"

# ---------- 3. copie des dotfiles -------------------------------------------
info "Copie des fichiers de configuration vers $HOME"
mkdir -p "$HOME/.config/awesome/theme"

cp "$DOTFILES/.Xresources"                             "$HOME/.Xresources"
cp "$DOTFILES/.config/awesome/rc.lua"                  "$HOME/.config/awesome/rc.lua"
cp "$DOTFILES/.config/awesome/theme/theme.lua"         "$HOME/.config/awesome/theme/theme.lua"

# ---------- 4. wallpaper noir -----------------------------------------------
info "Génération du wallpaper noir"

W=1920; H=1080
if command -v xrandr >/dev/null 2>&1 && [[ -n ${DISPLAY:-} ]]; then
    res="$(xrandr --current 2>/dev/null \
        | awk '/\*/ { print $1; exit }')"
    if [[ $res =~ ^([0-9]+)x([0-9]+)$ ]]; then
        W="${BASH_REMATCH[1]}"; H="${BASH_REMATCH[2]}"
        info "Résolution détectée : ${W}x${H}"
    fi
fi

if command -v convert >/dev/null 2>&1; then
    convert -size "${W}x${H}" xc:black "$HOME/.config/awesome/theme/black.png"
else
    warn "convert (ImageMagick) introuvable, wallpaper non généré."
fi

# ---------- 5. adaptation matériel ------------------------------------------
RC="$HOME/.config/awesome/rc.lua"

# Interface Wi-Fi : remplacer wlan0 si elle n'existe pas
if [[ ! -d /sys/class/net/wlan0 ]]; then
    WIFI_IF="$(ls -1 /sys/class/net/ 2>/dev/null | grep -E '^wl' | head -n1 || true)"
    if [[ -n $WIFI_IF ]]; then
        info "Adaptation : wlan0 → $WIFI_IF"
        sed -i "s/\"wlan0\"/\"$WIFI_IF\"/" "$RC"
    else
        warn "Aucune interface Wi-Fi détectée. Le widget Wifi restera vide."
    fi
fi

# Batterie : remplacer BAT0 si elle n'existe pas
if [[ ! -d /sys/class/power_supply/BAT0 ]]; then
    BAT="$(ls -1 /sys/class/power_supply/ 2>/dev/null | grep -E '^BAT' | head -n1 || true)"
    if [[ -n $BAT ]]; then
        info "Adaptation : BAT0 → $BAT"
        sed -i "s/\"BAT0\"/\"$BAT\"/" "$RC"
    else
        warn "Pas de batterie détectée (machine de bureau ?). Widget Bat figé."
    fi
fi

# ---------- 6. xrdb ---------------------------------------------------------
if [[ -n ${DISPLAY:-} ]] && command -v xrdb >/dev/null 2>&1; then
    info "Chargement de ~/.Xresources via xrdb -merge"
    xrdb -merge "$HOME/.Xresources"
else
    warn "Pas de DISPLAY actif : xrdb sera lancé par l'autostart AwesomeWM."
fi

# ---------- 7. validation ---------------------------------------------------
if command -v awesome >/dev/null 2>&1; then
    info "Validation de la configuration : awesome -k"
    if awesome -k; then
        info "Configuration AwesomeWM valide."
    else
        warn "awesome -k a signalé une erreur. Inspecte la sortie ci-dessus."
    fi
fi

# ---------- 8. fin ----------------------------------------------------------
cat <<EOF

${GREEN}Installation terminée.${RESET}

Étapes restantes :
  1. Déconnecte ta session graphique actuelle.
  2. Sur l'écran de connexion, choisis ⚙️ → « awesome » (session Xorg).
  3. Connecte-toi.
  4. ${GREEN}Mod4 + Entrée${RESET}  → ouvre un terminal urxvt vert.
  5. ${GREEN}Mod4 + s${RESET}       → affiche tous les raccourcis disponibles.
  6. Reproduis le screenshot (cf. INSTALL.MD §10) avec :
       urxvt -name irssi  -e irssi  &
       urxvt -name ranger -e ranger &

Test en bac à sable, sans toucher à la session courante :
  Xephyr :5 & sleep 1 ; DISPLAY=:5 awesome
EOF
