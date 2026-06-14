# Installation du setup AwesomeWM « Mr. Robot »

Ce guide détaille, **étape par étape sur Ubuntu**, comment passer d'une installation vierge à un bureau AwesomeWM identique au screenshot du projet (`atTXvEW.jpeg`) : terminal vert phosphore sur fond noir, barre supérieure avec tags nommés (`1:main … 7:search`) et statut système (Wifi / CPU / RAM / Volume / Batterie), pavage en trois colonnes (IRC à gauche, monitoring shell au centre, gestionnaire de fichiers TUI + htop à droite).

> Pour comprendre **les concepts** d'AwesomeWM (tags, layouts, modkey, wibar, etc.), reportez-vous au guide `Awesomewm.MD` du projet. Le présent fichier reste autoporteur sur la **séquence à exécuter**.

> **Important — X11 uniquement.** AwesomeWM tourne sous Xorg, pas sous Wayland. À la connexion, choisissez bien une session **Xorg**.

---

## Table des matières

1. [Pré-requis](#1-pré-requis)
2. [Installer AwesomeWM](#2-installer-awesomewm)
3. [Installer les dépendances du setup](#3-installer-les-dépendances-du-setup)
4. [Configurer urxvt en vert phosphore](#4-configurer-urxvt-en-vert-phosphore)
5. [Copier la configuration AwesomeWM](#5-copier-la-configuration-awesomewm)
6. [Créer le thème « matrix »](#6-créer-le-thème--matrix-)
7. [Modifier `rc.lua`](#7-modifier-rclua)
8. [Configurer les applications TUI](#8-configurer-les-applications-tui)
9. [Première connexion à la session AwesomeWM](#9-première-connexion-à-la-session-awesomewm)
10. [Reproduire le screenshot](#10-reproduire-le-screenshot)
11. [Tester sans risque (Xephyr)](#11-tester-sans-risque-xephyr)
12. [Dépannage rapide](#12-dépannage-rapide)

---

## 1. Pré-requis

- Une installation **Ubuntu** fonctionnelle, à jour :

  ```bash
  sudo apt update && sudo apt upgrade
  ```

- Une session **Xorg** (pas Wayland). Sur GDM ou LightDM, la roue dentée ⚙️ du sélecteur de session permet de choisir « Ubuntu sur Xorg » (à la connexion suivante, on basculera sur la session « awesome » créée par l'étape 2).
- Un accès `sudo` pour installer des paquets.
- Une connexion Internet (les widgets et `apt` en dépendent).
- Un éditeur de texte de votre choix : `nano`, `vim`, `gedit`, etc.

---

## 2. Installer AwesomeWM

```bash
sudo apt install awesome awesome-extra
```

- `awesome` fournit le gestionnaire de fenêtres lui-même et la session `awesome.desktop` qui apparaîtra dans le sélecteur de session.
- `awesome-extra` fournit notamment la bibliothèque **vicious**, indispensable pour les widgets système (CPU, RAM, batterie, Wi-Fi, volume) de la wibar.

Vérifier la version installée (4.x attendu) :

```bash
awesome --version
```

Pour les détails de la session (où la sélectionner à la connexion, comment lancer avec `startx`, etc.), voir `Awesomewm.MD` §4.

---

## 3. Installer les dépendances du setup

Un bloc unique installe tout ce qu'il faut pour reproduire le screenshot :

```bash
sudo apt install \
    rxvt-unicode \
    fonts-terminus fonts-jetbrains-mono \
    picom feh rofi i3lock flameshot \
    irssi ranger htop neofetch \
    net-tools wireless-tools acpi pulseaudio-utils \
    network-manager-gnome \
    xserver-xephyr imagemagick
```

Détail des groupes :

- **Terminal** : `rxvt-unicode` (urxvt) — léger, accepte sans douleur la palette vert phosphore via `~/.Xresources`.
- **Polices monospace** : `fonts-terminus` (police pixel rétro, fidèle à l'image), `fonts-jetbrains-mono` (alternative moderne).
- **Confort X** : `picom` (compositeur), `feh` (fond d'écran), `rofi` (lanceur), `i3lock` (verrouillage), `flameshot` (captures).
- **Applis TUI du screenshot** : `irssi` (IRC), `ranger` (file manager), `htop` (moniteur), `neofetch` (signature système).
- **Sources de données des widgets** : `net-tools` (`ifconfig`), `wireless-tools` (`iwconfig`, statut Wi-Fi), `acpi` (batterie), `pulseaudio-utils` (volume).
- **Applet réseau** : `network-manager-gnome` (icône `nm-applet` dans la barre).
- **Outils** : `xserver-xephyr` (bac à sable, voir §11), `imagemagick` (pour générer le fond d'écran noir uni).

---

## 4. Configurer urxvt en vert phosphore

Créez (ou éditez) `~/.Xresources` :

```Xresources
! Police monospace
URxvt.font:           xft:Terminus:size=11
URxvt.boldFont:       xft:Terminus:size=11:style=Bold
URxvt.letterSpace:    0
URxvt.scrollBar:      false
URxvt.internalBorder: 6

! Palette vert phosphore sur noir
URxvt.background:     #000000
URxvt.foreground:     #33ff33
URxvt.cursorColor:    #33ff33
URxvt.colorBD:        #66ff66
URxvt.colorUL:        #00aa00

! 16 couleurs : variations de vert
URxvt*color0:  #000000
URxvt*color1:  #007700
URxvt*color2:  #33ff33
URxvt*color3:  #66ff66
URxvt*color4:  #007700
URxvt*color5:  #33ff33
URxvt*color6:  #66ff66
URxvt*color7:  #aaffaa
URxvt*color8:  #006600
URxvt*color9:  #00aa00
URxvt*color10: #33ff33
URxvt*color11: #66ff66
URxvt*color12: #00aa00
URxvt*color13: #33ff33
URxvt*color14: #66ff66
URxvt*color15: #ccffcc
```

Charger les ressources dans la session X courante :

```bash
xrdb -merge ~/.Xresources
```

Vérifier :

```bash
urxvt &
```

Une fenêtre noire avec du texte vert doit s'ouvrir. Si ce n'est pas le cas, c'est que `xrdb` n'a pas été rechargé : relancez la commande ci-dessus. L'étape 7.6 ajoutera l'auto-rechargement à chaque démarrage d'AwesomeWM.

---

## 5. Copier la configuration AwesomeWM

On ne modifie jamais la config système. On copie une version personnelle :

```bash
mkdir -p ~/.config/awesome
cp /etc/xdg/awesome/rc.lua ~/.config/awesome/rc.lua
cp -r /usr/share/awesome/themes/default ~/.config/awesome/theme
```

Sauvegarde recommandée avant chaque grosse modification :

```bash
cp ~/.config/awesome/rc.lua ~/.config/awesome/rc.lua.bak
```

---

## 6. Créer le thème « matrix »

Éditez `~/.config/awesome/theme/theme.lua`. Repérez le bloc de couleurs en haut (`theme.bg_normal`, `theme.fg_normal`, etc.) et remplacez-le par celui-ci :

```lua
theme.font          = "Terminus 10"

theme.bg_normal     = "#000000"
theme.bg_focus      = "#001a00"
theme.bg_urgent     = "#003300"
theme.bg_minimize   = "#000000"
theme.bg_systray    = "#000000"

theme.fg_normal     = "#33ff33"
theme.fg_focus      = "#66ff66"
theme.fg_urgent     = "#aaffaa"
theme.fg_minimize   = "#007700"

theme.useless_gap   = dpi(2)
theme.border_width  = dpi(1)
theme.border_normal = "#003300"
theme.border_focus  = "#33ff33"
theme.border_marked = "#66ff66"

theme.wallpaper     = os.getenv("HOME") .. "/.config/awesome/theme/black.png"
```

Générer le fond d'écran noir uni :

```bash
convert -size 1920x1080 xc:black ~/.config/awesome/theme/black.png
```

(Si votre écran est plus grand, adaptez la taille.)

---

## 7. Modifier `rc.lua`

Toutes les modifications ci-dessous se font dans `~/.config/awesome/rc.lua`. Après chaque session de modifications, validez la syntaxe avec `awesome -k` puis, une fois en session AwesomeWM, rechargez avec `Mod4 + Ctrl + r`.

### 7.1 Thème, terminal, modkey

Près du haut du fichier, ajustez (ou remplacez) ces lignes :

```lua
beautiful.init(gears.filesystem.get_configuration_dir() .. "theme/theme.lua")
terminal = "urxvt"
editor   = os.getenv("EDITOR") or "nano"
modkey   = "Mod4"
```

### 7.2 Layouts

Pour coller au pavage strict du screenshot, garder une liste courte :

```lua
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.max,
    awful.layout.suit.floating,
}
```

### 7.3 Tags nommés

Dans le bloc `awful.screen.connect_for_each_screen(function(s) ... end)`, repérez la ligne `awful.tag({ "1", "2", ... }, s, awful.layout.layouts[1])` et remplacez-la par :

```lua
local names    = { "1:main", "2:docs", "3:dist", "4:irc",
                   "5:web",  "6:imgs", "7:search" }
local l        = awful.layout.suit
local layouts  = { l.tile, l.tile, l.tile, l.tile,
                   l.tile, l.tile, l.tile }
awful.tag(names, s, layouts)
```

### 7.4 Widgets système (wibar de droite)

En haut du `rc.lua`, après les autres `require`, ajoutez :

```lua
local vicious = require("vicious")

-- WiFi
local wifi_widget = wibox.widget.textbox()
vicious.register(wifi_widget, vicious.widgets.wifi,
    " Wifi: Li: ${link} Si: ${sign} ", 5, "wlan0")

-- CPU
local cpu_widget = wibox.widget.textbox()
vicious.register(cpu_widget, vicious.widgets.cpu, " CPU $1% ", 3)

-- RAM
local mem_widget = wibox.widget.textbox()
vicious.register(mem_widget, vicious.widgets.mem, " RAM $2/$3MB ", 5)

-- Volume
local vol_widget = wibox.widget.textbox()
vicious.register(vol_widget, vicious.widgets.volume, " Vol $1 ", 2, "Master")

-- Batterie
local bat_widget = wibox.widget.textbox()
vicious.register(bat_widget, vicious.widgets.bat, " Bat $2% ", 30, "BAT0")

-- Indicateur de langue (statique "en")
local kbd_widget = wibox.widget.textbox(" en ")

-- Séparateur " | "
local sep = wibox.widget.textbox(" | ")
```

> **Adapter à votre matériel** :
> - `wlan0` → nom de votre interface Wi-Fi. Listez-les avec `iwconfig` (interfaces sans-fil) ou `ip link`.
> - `BAT0` → nom de votre batterie. Listez-les avec `ls /sys/class/power_supply/`.

Puis, dans la définition `s.mywibox:setup { ... }`, **remplacez la sous-table « Widgets de droite »** par :

```lua
{ -- Widgets de droite
    layout = wibox.layout.fixed.horizontal,
    kbd_widget, sep,
    wifi_widget, sep,
    cpu_widget, sep,
    mem_widget, sep,
    vol_widget, sep,
    bat_widget,
    mytextclock,
    s.mylayoutbox,
},
```

### 7.5 Règles d'attribution aux tags

Dans la table `awful.rules.rules`, juste avant la dernière `}` qui ferme la table, insérez :

```lua
{ rule = { class = "URxvt", name = "irssi"  },
  properties = { tag = "4:irc" } },
{ rule = { class = "URxvt", name = "ranger" },
  properties = { tag = "6:imgs" } },
{ rule = { class = "firefox" },
  properties = { tag = "5:web" } },
```

Le `name` d'une fenêtre urxvt est défini par l'option `-name` au lancement (voir §10).

### 7.6 Autostart

À la **fin** du `rc.lua`, ajoutez :

```lua
local function run_once(cmd)
    awful.spawn.with_shell(string.format(
        "pgrep -u $USER -fx '%s' >/dev/null || (%s &)", cmd, cmd))
end

run_once("xrdb -merge ~/.Xresources")
run_once("picom --config /dev/null")
run_once("nm-applet")
run_once("feh --bg-fill " .. os.getenv("HOME") .. "/.config/awesome/theme/black.png")
```

`run_once` évite de relancer un programme déjà en cours à chaque rechargement de configuration.

Valider la syntaxe :

```bash
awesome -k
```

La sortie doit indiquer « configuration file syntax OK ».

---

## 8. Configurer les applications TUI

### irssi

Au premier lancement (`irssi`), tapez :

```
/set theme matrix
```

Si le thème « matrix » n'existe pas sur votre système, le rendu reste correct grâce à la palette urxvt. Vous pouvez aussi écrire un thème dans `~/.irssi/matrix.theme` (cf. doc irssi).

### ranger

Copier la configuration par défaut :

```bash
ranger --copy-config=all
```

Puis, dans `~/.config/ranger/rc.conf`, vérifier (ou ajouter) :

```
set colorscheme default
```

La palette vient ensuite de urxvt — l'ensemble apparaît en vert.

### htop

Lancer `htop`, puis :

- `F2` → **Colors** → **Monochromatic** (rendu vert uni, fidèle au screenshot).
- `F2` → **Meters** → conserver CPU(1/2) et Memory dans la colonne de droite.
- `F10` pour enregistrer.

### neofetch, df, ifconfig

Pas de configuration nécessaire — ils héritent automatiquement des couleurs du terminal.

---

## 9. Première connexion à la session AwesomeWM

1. Vérifier la syntaxe : `awesome -k`.
2. Se déconnecter de la session courante.
3. Sur l'écran de connexion (GDM/LightDM), sélectionner son utilisateur, puis cliquer sur la roue dentée ⚙️ et choisir **awesome** (et non « Ubuntu » ou « Ubuntu sur Wayland »).
4. Saisir le mot de passe.

À la première connexion :

- `Mod4 + Entrée` ouvre un terminal urxvt vert.
- `Mod4 + s` affiche la liste complète des raccourcis.
- `Mod4 + Ctrl + r` recharge la configuration sans se déconnecter.

Pour la liste exhaustive des raccourcis et leur signification, voir `Awesomewm.MD` §6.

---

## 10. Reproduire le screenshot

Avec la barre supérieure en place, ouvrez trois colonnes comme sur `atTXvEW.jpeg` :

1. Aller sur le tag IRC : `Mod4 + 4`, puis ouvrir un terminal et lancer :

   ```bash
   urxvt -name irssi -e irssi &
   ```

2. Aller sur le tag principal : `Mod4 + 1`, puis :

   ```bash
   urxvt -e bash -c "clear; df -h; echo; ifconfig; bash" &
   ```

3. Aller sur le tag médias : `Mod4 + 6`, puis :

   ```bash
   urxvt -name ranger -e ranger &
   ```

   Ouvrez un second client sur le même tag (`Mod4 + Maj + Entrée` ou simplement `Mod4 + Entrée`) et lancez `htop` dedans. Le pavage `tile` placera ranger à gauche et htop à droite — ajustez le ratio avec `Mod4 + h` / `Mod4 + l`.

Capture pour comparer avec l'image cible :

```bash
flameshot gui
```

---

## 11. Tester sans risque (Xephyr)

Pour valider une modification de `rc.lua` **sans toucher à la session réelle**, lancez AwesomeWM dans une fenêtre imbriquée :

```bash
Xephyr :5 & sleep 1 ; DISPLAY=:5 awesome
```

Une fenêtre s'ouvre avec une instance complète d'AwesomeWM dedans. Fermez-la quand vous avez fini de tester. Pour tester un fichier de config spécifique :

```bash
DISPLAY=:5 awesome -c ~/.config/awesome/rc.lua
```

---

## 12. Dépannage rapide

| Symptôme | Cause probable / vérification |
|---|---|
| Écran noir après connexion | Erreur Lua dans `rc.lua`. Basculez en console (`Ctrl + Alt + F3`), lancez `awesome -k` et lisez `~/.xsession-errors`. Voir aussi `Awesomewm.MD` §11. |
| Widget Wi-Fi vide | Mauvais nom d'interface dans `vicious.register(... "wlan0")`. Trouvez le bon nom avec `iwconfig` ou `ip link` (souvent `wlp3s0`). |
| Widget batterie vide | Mauvais identifiant `BATx`. Lister : `ls /sys/class/power_supply/`. |
| Widget volume figé à 0 | PulseAudio absent ou mauvais nom de canal. Tester `pactl list sinks short`, ajuster `"Master"` si besoin. |
| Couleurs urxvt pas vertes | `~/.Xresources` pas chargé. Lancer manuellement `xrdb -merge ~/.Xresources` puis relancer urxvt. L'autostart §7.6 doit régler le problème pour les sessions suivantes. |
| Pas de session « awesome » à la connexion | Vérifier `/usr/share/xsessions/awesome.desktop` (réinstaller le paquet `awesome` au besoin) et choisir une session **Xorg**. |
| Fond d'écran disparaît au rechargement | Vérifier que la ligne `feh --bg-fill ...` figure dans l'autostart §7.6 et que `~/.config/awesome/theme/black.png` existe. |

---

## Pour aller plus loin

- **Concepts, raccourcis, sections par section** : `Awesomewm.MD` (dans ce projet).
- Documentation officielle : [awesomewm.org/doc/](https://awesomewm.org/doc/)
- Recettes et exemples communautaires : [awesomewm.org/recipes/](https://awesomewm.org/recipes/)

> **Note de version.** Ce guide cible AwesomeWM **4.x** (4.3 stable sur Ubuntu). Les configurations 3.x sont **incompatibles** — méfiez-vous des anciens tutoriels.
