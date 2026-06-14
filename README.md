<p align="center">
    <img src="https://socialify.git.ci/AntoineMeheut/AwesomeWM-setup/image?custom_description=AwesomeWM+MR.Robot+Setup+%21&description=1&language=1&name=1&pattern=Circuit+Board&theme=Dark" alt="AntoineMeheut" width="700" height="300" />
</p>

<div align="center">
  <img src="https://img.shields.io/github/stars/AntoineMeheut/AwesomeWM-setup" />
</div>

<br/>

# Setup AwesomeWM « Mr. Robot »

Ce dépôt contient tout le nécessaire pour reproduire sur **Ubuntu** le bureau
AwesomeWM montré dans `atTXvEW.jpeg` : terminal urxvt vert phosphore sur fond
noir, tags nommés `1:main` … `7:search`, wibar avec widgets système (Wi-Fi,
CPU, RAM, Volume, Batterie) et pavage strict trois colonnes (irssi / df+ifconfig
/ ranger+htop).

L'installation est entièrement automatisée par le script **`install.sh`**.

> Pour les concepts d'AwesomeWM (tags, layouts, modkey, wibar…), voir
> `Awesomewm.MD`. Pour la procédure manuelle, étape par étape, voir
> `INSTALL.MD`. Ce README se concentre sur l'utilisation du script.

---

## Table des matières

1. [Aperçu du dépôt](#1-aperçu-du-dépôt)
2. [Pré-requis](#2-pré-requis)
3. [Utilisation rapide](#3-utilisation-rapide)
4. [Options de la ligne de commande](#4-options-de-la-ligne-de-commande)
5. [Ce que fait précisément `install.sh`](#5-ce-que-fait-précisément-installsh)
6. [Première connexion à la session AwesomeWM](#6-première-connexion-à-la-session-awesomewm)
7. [Reproduire le screenshot](#7-reproduire-le-screenshot)
8. [Tester sans risque (Xephyr)](#8-tester-sans-risque-xephyr)
9. [Revenir en arrière](#9-revenir-en-arrière)
10. [Dépannage](#10-dépannage)

---

## 1. Aperçu du dépôt

```
Setup/
├── Awesomewm.MD                 Guide conceptuel d'AwesomeWM (concepts, raccourcis)
├── INSTALL.MD                   Procédure manuelle détaillée, équivalente à install.sh
├── README.MD                    Ce fichier
├── LICENSE.MD                   Licence MIT
├── atTXvEW.jpeg                 Screenshot cible (« Mr. Robot »)
├── install.sh                   Installateur automatique
└── dotfiles/                    Fichiers déployés dans ~/
    ├── .Xresources              Palette urxvt vert phosphore
    └── .config/awesome/
        ├── rc.lua               Configuration AwesomeWM 4.x complète
        └── theme/theme.lua      Thème « matrix »
```

Le script copie l'arborescence `dotfiles/` vers `$HOME` en respectant les
chemins (`dotfiles/.Xresources` → `~/.Xresources`, etc.).

---

## 2. Pré-requis

Avant de lancer le script, vérifiez que :

- Vous tournez sous **Ubuntu** (ou une dérivée Debian disposant d'`apt`).
- Vous avez les droits **`sudo`** : `install.sh` appelle `sudo apt update` et
  `sudo apt install` pour les paquets.
- Vous êtes en session **Xorg** (pas Wayland). AwesomeWM ne fonctionne pas
  sous Wayland. Sur l'écran de connexion GDM/LightDM, la roue dentée ⚙️
  permet de choisir « Ubuntu sur Xorg » avant de bouger vers la session
  « awesome » créée par l'installation.
- Vous disposez d'une **connexion Internet** (les paquets viennent des dépôts).
- Vous **ne lancez pas le script en `root`**. `install.sh` refuse de tourner
  en root et invoque `sudo` lui-même quand c'est nécessaire ; cela évite que
  les fichiers de config soient créés avec les mauvais droits dans `~/`.

---

## 3. Utilisation rapide

Depuis la racine du dépôt :

```bash
chmod +x install.sh         # une seule fois, si le bit exécutable manque
./install.sh
```

Le script effectue l'installation complète : paquets, copie des fichiers de
configuration, génération du fond d'écran noir, adaptation matérielle, puis
validation par `awesome -k`.

À la fin, déconnectez-vous et choisissez la session **awesome** sur l'écran de
connexion (voir §6).

---

## 4. Options de la ligne de commande

| Option           | Effet                                                                              |
| ---------------- | ---------------------------------------------------------------------------------- |
| *(aucune)*       | Installation complète : `apt install` + copie + wallpaper + adaptation + `xrdb`.   |
| `--no-apt`       | Saute l'étape `sudo apt install`. Pratique si les paquets sont déjà à jour ou si vous installez sur une machine sans réseau. |
| `-h`, `--help`   | Affiche l'aide en tête du script et quitte.                                        |

Exemple — redéployer la configuration après l'avoir éditée, sans toucher aux
paquets :

```bash
./install.sh --no-apt
```

---

## 5. Ce que fait précisément `install.sh`

Le script est **idempotent** : vous pouvez le relancer sans crainte. Les
fichiers existants sont systématiquement sauvegardés avant d'être remplacés.

### 5.1 Vérifications préalables

- Refus d'exécution si `EUID == 0` (root).
- Refus si la commande `apt` n'est pas trouvée.
- Vérifie que le dossier `dotfiles/` existe à côté du script.

### 5.2 Installation des paquets (sauf `--no-apt`)

`sudo apt update` puis `sudo apt install -y` du bloc complet d'`INSTALL.MD`
§2-§3 :

```
awesome awesome-extra
rxvt-unicode
fonts-terminus fonts-jetbrains-mono
picom feh rofi i3lock flameshot
irssi ranger htop neofetch
net-tools wireless-tools acpi pulseaudio-utils
network-manager-gnome
xserver-xephyr imagemagick
```

`awesome-extra` apporte notamment la bibliothèque **vicious**, indispensable
aux widgets de la wibar.

### 5.3 Sauvegardes

Si un fichier visé existe déjà (et n'est pas un lien symbolique), il est
renommé avec un suffixe horodaté :

```
~/.Xresources                       → ~/.Xresources.bak.<timestamp>
~/.config/awesome/rc.lua            → ~/.config/awesome/rc.lua.bak.<timestamp>
~/.config/awesome/theme/theme.lua   → ~/.config/awesome/theme/theme.lua.bak.<timestamp>
```

### 5.4 Copie des dotfiles

`mkdir -p ~/.config/awesome/theme` puis `cp` des trois fichiers :

| Source du dépôt                                       | Destination                                |
| ----------------------------------------------------- | ------------------------------------------ |
| `dotfiles/.Xresources`                                | `~/.Xresources`                            |
| `dotfiles/.config/awesome/rc.lua`                     | `~/.config/awesome/rc.lua`                 |
| `dotfiles/.config/awesome/theme/theme.lua`            | `~/.config/awesome/theme/theme.lua`        |

### 5.5 Génération du wallpaper noir

Le script tente de détecter la résolution courante via
`xrandr --current` ; sinon il utilise le défaut `1920×1080`. Il génère ensuite
`~/.config/awesome/theme/black.png` avec ImageMagick :

```bash
convert -size <largeur>x<hauteur> xc:black ~/.config/awesome/theme/black.png
```

### 5.6 Adaptation au matériel

Le `rc.lua` est livré avec `wlan0` et `BAT0` codés en dur. Le script vérifie
leur existence dans `/sys/class/net/` et `/sys/class/power_supply/` :

- Si `wlan0` n'existe pas et qu'une interface `wl*` est présente, il remplace
  `wlan0` par le bon nom (`sed -i` dans `rc.lua`).
- Si `BAT0` n'existe pas et qu'une batterie `BAT*` est trouvée, idem.
- En l'absence de Wi-Fi ou de batterie, un avertissement est imprimé : les
  widgets correspondants resteront vides, sans crash.

### 5.7 Chargement de `.Xresources`

Si `$DISPLAY` est défini et que `xrdb` est disponible, le script lance
immédiatement `xrdb -merge ~/.Xresources` pour que les terminaux urxvt
ouverts après l'installation utilisent la palette verte. Sinon, l'autostart
intégré au `rc.lua` s'en chargera à la prochaine ouverture de session
AwesomeWM (voir §7.6 d'`INSTALL.MD`).

### 5.8 Validation

`awesome -k` est lancé en fin de course pour valider la syntaxe Lua du
`rc.lua`. La sortie doit indiquer « configuration file syntax OK ». Une
erreur ici n'interrompt pas le script (les fichiers sont déjà déployés) mais
est imprimée en jaune.

---

## 6. Première connexion à la session AwesomeWM

1. **Déconnectez-vous** de votre session courante (Wayland ou GNOME).
2. Sur l'écran de connexion (GDM ou LightDM), sélectionnez votre utilisateur.
3. Cliquez sur la **roue dentée ⚙️** (en bas à droite sur GDM) et choisissez
   **awesome**. Vérifiez bien que c'est une session **Xorg** (pas
   « Ubuntu sur Wayland »).
4. Saisissez votre mot de passe et connectez-vous.

Une fois sur le bureau AwesomeWM :

- `Mod4 + Entrée` ouvre un terminal urxvt vert phosphore.
- `Mod4 + s` affiche le popup avec **tous les raccourcis**.
- `Mod4 + Ctrl + r` recharge la configuration **sans déconnecter** la session.
- `Mod4 + Maj + q` quitte AwesomeWM.

> Rappel : `Mod4` = touche **Super** (logo Windows), entre Ctrl et Alt.

---

## 7. Reproduire le screenshot

Sur le bureau AwesomeWM, ouvrez les trois colonnes (cf. `INSTALL.MD` §10) :

```bash
# Colonne IRC
Mod4 + 4
urxvt -name irssi -e irssi &

# Colonne monitoring (tag principal)
Mod4 + 1
urxvt -e bash -c "clear; df -h; echo; ifconfig; bash" &

# Colonne fichiers + processus
Mod4 + 6
urxvt -name ranger -e ranger &
urxvt -e htop &
```

Les règles du `rc.lua` envoient automatiquement `irssi` sur le tag `4:irc`,
`ranger` sur le tag `6:imgs` et Firefox sur le tag `5:web`. Pour ajuster la
largeur des colonnes : `Mod4 + h` / `Mod4 + l`.

Capture d'écran pour comparer à `atTXvEW.jpeg` :

```bash
flameshot gui
```

---

## 8. Tester sans risque (Xephyr)

Pour valider une modification du `rc.lua` **sans toucher à votre session
courante**, lancez AwesomeWM dans un serveur X imbriqué :

```bash
Xephyr :5 & sleep 1 ; DISPLAY=:5 awesome
```

Une fenêtre s'ouvre avec une instance complète d'AwesomeWM dedans. Fermez-la
quand vous avez fini. Pour tester un fichier de config précis :

```bash
DISPLAY=:5 awesome -c ~/.config/awesome/rc.lua
```

---

## 9. Revenir en arrière

Les sauvegardes horodatées (`*.bak.<timestamp>`) permettent de restaurer
manuellement vos anciens fichiers :

```bash
# Exemple : restaurer un ancien rc.lua
mv ~/.config/awesome/rc.lua.bak.1735680000 ~/.config/awesome/rc.lua
```

Pour repartir intégralement du `rc.lua` Ubuntu d'origine :

```bash
cp /etc/xdg/awesome/rc.lua ~/.config/awesome/rc.lua
```

Pour désinstaller AwesomeWM et retourner à GNOME :

```bash
sudo apt remove awesome awesome-extra
```

À la connexion suivante, choisissez « Ubuntu » comme session.

---

## 10. Dépannage

| Symptôme                                | Cause / vérification                                                                                                |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| `install.sh` refuse de démarrer en root | C'est volontaire. Relancez-le en utilisateur normal ; `sudo` sera appelé par le script lui-même quand nécessaire.    |
| Écran noir après connexion              | Erreur Lua dans `rc.lua`. Basculez en console (`Ctrl + Alt + F3`), lancez `awesome -k` et lisez `~/.xsession-errors`. |
| Widget Wi-Fi vide                       | Mauvais nom d'interface. Vérifiez avec `iwconfig` ou `ip link`, puis ajustez la chaîne dans `rc.lua` (cherchez `vicious.widgets.wifi`). |
| Widget batterie vide                    | Mauvais identifiant `BATx`. Listez `/sys/class/power_supply/` et ajustez `rc.lua`.                                  |
| Widget volume figé                      | PulseAudio absent ou mauvais canal. Tester `pactl list sinks short`, ajuster `"Master"` si besoin.                  |
| Couleurs urxvt pas vertes               | `~/.Xresources` pas chargé. Lancez `xrdb -merge ~/.Xresources` puis relancez urxvt. L'autostart §7.6 d'`INSTALL.MD` doit régler le problème pour les sessions suivantes. |
| Pas de session « awesome » à la connexion | Vérifiez `/usr/share/xsessions/awesome.desktop` (réinstallez `awesome` au besoin) et choisissez une session **Xorg**.       |
| Fond d'écran disparaît au rechargement  | Vérifiez que `~/.config/awesome/theme/black.png` existe et que l'autostart `feh --bg-fill …` est présent dans `rc.lua`.    |

Pour aller plus loin, consultez `INSTALL.MD` §12 et `Awesomewm.MD` §11.

---

## Licence

Distribué sous licence MIT — voir `LICENSE.MD`.
