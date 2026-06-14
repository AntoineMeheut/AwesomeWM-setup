# Guide complet d'AwesomeWM sur Ubuntu

**Awesome** est un gestionnaire de fenêtres (window manager) pour X très configurable, rapide et léger, entièrement pilotable au clavier. Sa particularité : il se configure et s'étend avec le langage **Lua**, ce qui en fait un véritable *framework* de bureau plutôt qu'un simple gestionnaire de fenêtres. Il s'adresse aux utilisateurs avancés qui veulent un contrôle fin de leur environnement graphique.

Ce guide couvre l'installation et l'utilisation d'Awesome **version 4.x** (la version stable actuelle est la **4.3**) sur Ubuntu, de la première connexion jusqu'à la personnalisation de la configuration.

> **Important — X11 uniquement.** Awesome fonctionne sous le serveur d'affichage **Xorg (X11)**, pas sous Wayland. Sur Ubuntu, qui utilise GNOME sous Wayland par défaut, vous choisirez une session « awesome » distincte au moment de la connexion (voir section 4).

---

## Table des matières

1. [Concepts clés](#1-concepts-clés)
2. [Prérequis](#2-prérequis)
3. [Installation sur Ubuntu](#3-installation-sur-ubuntu)
4. [Lancer Awesome](#4-lancer-awesome)
5. [Premiers pas : découvrir le bureau par défaut](#5-premiers-pas--découvrir-le-bureau-par-défaut)
6. [Raccourcis clavier essentiels](#6-raccourcis-clavier-essentiels)
7. [La configuration : le fichier rc.lua](#7-la-configuration--le-fichier-rclua)
8. [Personnalisations courantes](#8-personnalisations-courantes)
9. [Tester sa configuration sans risque](#9-tester-sa-configuration-sans-risque)
10. [Compléter son environnement](#10-compléter-son-environnement)
11. [Dépannage](#11-dépannage)
12. [Aide-mémoire](#12-aide-mémoire)
13. [Ressources](#13-ressources)

---

## 1. Concepts clés

Awesome introduit quelques notions qui le distinguent d'un bureau classique :

- **Pavage (tiling)** : par défaut, les fenêtres se rangent automatiquement les unes à côté des autres sans se recouvrir, occupant tout l'écran. Awesome gère aussi le mode flottant (comme un bureau classique).
- **Tags plutôt que bureaux virtuels** : au lieu de « bureaux » fixes, Awesome utilise des **tags** (étiquettes). Une fenêtre peut être présente sur plusieurs tags à la fois, et vous pouvez afficher plusieurs tags simultanément.
- **Clients** : c'est le nom donné aux fenêtres des applications.
- **Layouts (dispositions)** : la règle qui décide comment les fenêtres sont arrangées (en pavage, en colonnes, plein écran, flottant, etc.). On change de layout à la volée.
- **Wibar / wibox** : la barre d'état (en haut de l'écran par défaut) et, plus généralement, les surfaces graphiques où l'on place des **widgets**.
- **Modkey** : la touche de modification utilisée pour la plupart des raccourcis. Par défaut, c'est **Mod4**, c'est-à-dire la touche **Super** (la touche « Windows », entre Ctrl et Alt).
- **Tout en Lua** : la configuration est un programme Lua. Cela rend Awesome extrêmement souple, mais une erreur de syntaxe peut empêcher le démarrage (voir le dépannage).

---

## 2. Prérequis

- Une installation d'Ubuntu fonctionnelle.
- Le serveur graphique **Xorg** (installé par défaut). Vous utiliserez une **session X11**, pas Wayland.
- Des droits d'administration (`sudo`) pour installer les paquets.
- Un éditeur de texte (nano, vim, gedit…) pour modifier la configuration.

---

## 3. Installation sur Ubuntu

Awesome est disponible dans les dépôts officiels d'Ubuntu.

```bash
sudo apt update
sudo apt install awesome
```

Pour disposer d'extensions et de widgets supplémentaires (modules tiers comme *vicious*, thèmes, etc.), installez aussi le paquet complémentaire :

```bash
sudo apt install awesome-extra
```

Vérifiez la version installée :

```bash
awesome --version
```

L'installation place notamment :
- l'exécutable `awesome` ;
- la configuration par défaut dans `/etc/xdg/awesome/rc.lua` ;
- les thèmes dans `/usr/share/awesome/themes/` ;
- un fichier de session `/usr/share/xsessions/awesome.desktop` qui fait apparaître « awesome » dans le menu de session de l'écran de connexion.

---

## 4. Lancer Awesome

### Méthode 1 — Depuis l'écran de connexion (recommandée)

C'est la méthode la plus simple sur Ubuntu.

1. Déconnectez-vous (ou redémarrez).
2. Sur l'écran de connexion, sélectionnez votre nom d'utilisateur.
3. Cherchez le **sélecteur de session** : sur GNOME (GDM), c'est une petite **roue dentée** ⚙️ en bas à droite ; sur d'autres gestionnaires (LightDM), c'est un menu en haut.
4. Choisissez **awesome** (et non « Ubuntu » ou « Ubuntu sur Wayland »).
5. Saisissez votre mot de passe et connectez-vous.

Vous arrivez alors sur le bureau Awesome.

### Méthode 2 — Sans gestionnaire de connexion (startx)

Si vous démarrez X manuellement, indiquez à X de lancer Awesome en ajoutant cette ligne à votre fichier `~/.xinitrc` :

```bash
exec awesome
```

Puis lancez la session graphique :

```bash
startx
```

---

## 5. Premiers pas : découvrir le bureau par défaut

À la première connexion, vous voyez une **barre (wibar) en haut** de l'écran :

- **En haut à gauche** : le logo Awesome (un menu s'ouvre en cliquant dessus), puis les chiffres **1 à 9** : ce sont vos **tags**. Cliquez sur un chiffre pour basculer dessus.
- **Au centre** : la liste des fenêtres ouvertes sur le tag courant.
- **En haut à droite** : l'horloge et une **icône de layout** (cliquable pour changer de disposition).

Faites quelques essais immédiats (rappel : **Mod4** = touche Super/Windows) :

- **Mod4 + Entrée** : ouvre un terminal (`xterm` par défaut).
- Ouvrez-en plusieurs : ils se rangent automatiquement en pavage.
- **Mod4 + Espace** : passe d'un layout à l'autre (pavage, flottant, plein écran…).
- **Mod4 + r** : affiche une invite **Run:** dans la barre pour lancer un programme (avec complétion par Tab).
- **Mod4 + s** : affiche l'**aide complète** des raccourcis (appuyez sur une touche pour la refermer). C'est le réflexe à avoir pour tout découvrir.
- **Mod4 + Maj + c** : ferme la fenêtre active.

---

## 6. Raccourcis clavier essentiels

Voici les raccourcis de la configuration par défaut. La touche **Mod4** est la touche **Super (Windows)**.

| Raccourci | Action |
|---|---|
| `Mod4 + Entrée` | Ouvrir un terminal |
| `Mod4 + r` | Invite de lancement de commande (Run) |
| `Mod4 + s` | Afficher l'aide de tous les raccourcis |
| `Mod4 + Maj + c` | Fermer la fenêtre active |
| `Mod4 + j` / `Mod4 + k` | Changer la fenêtre ayant le focus |
| `Mod4 + Espace` | Layout suivant |
| `Mod4 + Maj + Espace` | Layout précédent |
| `Mod4 + f` | Mettre la fenêtre en plein écran |
| `Mod4 + h` / `Mod4 + l` | Réduire / agrandir la zone principale |
| `Mod4 + Maj + h` / `Mod4 + Maj + l` | Modifier le nombre de fenêtres dans la zone principale |
| `Mod4 + 1`…`Mod4 + 9` | Aller au tag 1 à 9 |
| `Mod4 + Maj + 1`…`9` | Envoyer la fenêtre active vers le tag 1 à 9 |
| `Mod4 + Gauche` / `Mod4 + Droite` | Tag précédent / suivant |
| `Mod4 + w` | Ouvrir le menu principal d'Awesome |
| `Mod4 + Ctrl + r` | **Recharger** la configuration d'Awesome |
| `Mod4 + Maj + q` | Quitter Awesome |
| `Mod4 + clic droit (Button3)` | Redimensionner une fenêtre à la souris |

> Astuce : tous ces raccourcis sont définis dans le fichier de configuration et peuvent être modifiés (section 8).

---

## 7. La configuration : le fichier rc.lua

Toute la configuration d'Awesome tient dans un fichier Lua nommé **`rc.lua`**.

### Copier la configuration par défaut

On ne modifie jamais le fichier système : on en copie une version personnelle dans son dossier utilisateur.

```bash
mkdir -p ~/.config/awesome
cp /etc/xdg/awesome/rc.lua ~/.config/awesome/rc.lua
```

À partir de maintenant, c'est ce fichier `~/.config/awesome/rc.lua` qu'Awesome utilisera.

### Structure générale du fichier

Le `rc.lua` par défaut charge plusieurs **bibliothèques** clés que vous retrouverez partout dans la documentation :

- **`gears`** : utilitaires (fichiers, formes, couleurs, minuteries…).
- **`awful`** : le cœur du framework (raccourcis, tags, layouts, règles, lancement de programmes…).
- **`wibox`** : le système de barres et de widgets.
- **`beautiful`** : la gestion des thèmes.
- **`naughty`** : les notifications.
- **`menubar`** : le menu d'applications.

Le fichier enchaîne ensuite : chargement du thème, définition du terminal et de la modkey, liste des layouts, création de la barre et des widgets, définition des raccourcis clavier/souris, puis les règles appliquées aux fenêtres.

### Vérifier la configuration et la recharger

**Avant** de recharger, vérifiez qu'il n'y a pas d'erreur de syntaxe Lua :

```bash
awesome -k
```

Si la sortie indique que la configuration est correcte, rechargez Awesome **sans vous déconnecter** avec **`Mod4 + Ctrl + r`**. Vos modifications sont alors appliquées immédiatement.

> Conseil : faites une sauvegarde avant chaque grosse modification : `cp ~/.config/awesome/rc.lua ~/.config/awesome/rc.lua.bak`.

---

## 8. Personnalisations courantes

Toutes les modifications ci-dessous se font dans `~/.config/awesome/rc.lua` (ou le thème), suivies d'un `awesome -k` puis `Mod4 + Ctrl + r`.

### Changer le terminal, l'éditeur et la modkey

Près du début du fichier, repérez et adaptez ces lignes :

```lua
terminal = "alacritty"            -- votre terminal préféré
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Pour utiliser Alt comme modkey à la place de Super :
-- modkey = "Mod1"
modkey = "Mod4"
```

### Changer de thème

Awesome fournit quatre thèmes : **default**, **sky**, **xresources** et **zenburn**. Modifiez la ligne `beautiful.init` :

```lua
beautiful.init(gears.filesystem.get_themes_dir() .. "zenburn/theme.lua")
```

Pour personnaliser un thème en profondeur, copiez-le dans votre dossier et pointez dessus :

```bash
cp -r /usr/share/awesome/themes/default ~/.config/awesome/theme
```

```lua
beautiful.init(os.getenv("HOME") .. "/.config/awesome/theme/theme.lua")
```

### Changer le fond d'écran

Le fond d'écran est géré par le thème. Dans votre fichier de thème (`theme.lua`), modifiez :

```lua
theme.wallpaper = "/chemin/vers/mon-image.png"
```

### Nommer les tags et leur attribuer un layout

Repérez la création des tags (par défaut nommés « 1 » à « 9 ») et remplacez-la pour donner des noms parlants et un layout par tag :

```lua
-- Chaque écran a sa propre table de tags.
local names = { "web", "code", "term", "média", "5", "6", "7", "8", "9" }
local l = awful.layout.suit  -- alias pour gagner de la frappe
local layouts = { l.max, l.tile, l.tile, l.floating, l.tile,
                  l.tile, l.tile, l.tile, l.floating }
awful.tag(names, s, layouts)
```

La liste des layouts disponibles se trouve dans la section `awful.layout.layouts` (pavage `tile`, `tile.left`, `fair`, `spiral`, `max`, `magnifier`, `floating`, etc.). Commentez ceux que vous n'utilisez pas en ajoutant `--` en début de ligne.

### Ajouter un raccourci clavier

Pour lancer une application avec un raccourci, ajoutez une entrée à `globalkeys`. Par exemple, **Mod4 + b** pour ouvrir Firefox :

```lua
globalkeys = gears.table.join(globalkeys,
    awful.key({ modkey }, "b",
        function () awful.spawn("firefox") end,
        {description = "lancer Firefox", group = "applications"})
)
```

Le champ `description` / `group` fait apparaître votre raccourci dans l'aide affichée par **Mod4 + s**.

### Appliquer des règles aux fenêtres

Les **règles** (`awful.rules.rules`) permettent d'envoyer automatiquement une application sur un tag donné, de la rendre flottante, etc. Ajoutez une règle dans la table existante :

```lua
{ rule = { class = "firefox" },
  properties = { tag = "web" } },

{ rule = { class = "Gimp" },
  properties = { floating = true } },
```

> Pour connaître la `class` exacte d'une fenêtre, lancez `xprop` dans un terminal puis cliquez sur la fenêtre : la valeur `WM_CLASS` vous la donne.

### Ajouter un widget simple

Awesome utilise un système de widgets déclaratif. Exemple minimal : créer un texte et l'ajouter à la barre. Avant la définition de la wibar, créez le widget :

```lua
local montexte = wibox.widget.textbox()
montexte.text = " Bonjour ! "
```

Puis ajoutez-le parmi les widgets de gauche de la barre :

```lua
{ -- Widgets de gauche
    layout = wibox.layout.fixed.horizontal,
    mylauncher,
    montexte,          -- notre nouveau widget
    s.mytaglist,
    s.mypromptbox,
},
```

### Lancer des programmes au démarrage (autostart)

Pour démarrer des programmes à l'ouverture de la session, ajoutez à la **fin** de votre `rc.lua` :

```lua
awful.spawn.with_shell("picom")        -- compositeur (transparence, anti-déchirure)
awful.spawn.with_shell("nm-applet")    -- icône réseau
awful.spawn.with_shell("nitrogen --restore")  -- restaurer le fond d'écran
```

> `awful.spawn.with_shell` relance le programme à chaque rechargement de configuration. Pour éviter les doublons, on utilise souvent une petite fonction « run_once » ou le fichier `~/.xprofile` pour les démarrages uniques.

---

## 9. Tester sa configuration sans risque

Une erreur dans `rc.lua` peut empêcher Awesome de démarrer. Plutôt que de risquer votre session, testez vos changements dans une **fenêtre isolée** grâce à **Xephyr** (un serveur X imbriqué) :

```bash
sudo apt install xserver-xephyr
Xephyr :5 & sleep 1 ; DISPLAY=:5 awesome
```

Une nouvelle fenêtre s'ouvre et fait tourner une instance complète d'Awesome à l'intérieur, sans toucher à votre session réelle. Pour tester un fichier de config précis : `DISPLAY=:5 awesome -c ~/.config/awesome/rc.lua`.

---

## 10. Compléter son environnement

Un gestionnaire de fenêtres minimaliste ne fournit pas tout ce qu'un bureau complet propose. Voici les compléments les plus utiles sous Ubuntu :

- **Compositeur** : `picom` (transparence, ombres, anti-déchirure).
- **Fond d'écran** : `nitrogen` ou `feh`.
- **Lanceur d'applications** : `rofi` ou `dmenu`.
- **Verrouillage d'écran** : `i3lock`.
- **Applets de barre système** : `nm-applet` (réseau), `pasystray` ou `volumeicon` (son), `blueman-applet` (Bluetooth).
- **Gestion de l'authentification** : `policykit-1-gnome` (boîtes de dialogue d'autorisation).
- **Captures d'écran** : `flameshot` ou `scrot`.

Installation typique :

```bash
sudo apt install picom nitrogen rofi i3lock network-manager-gnome flameshot
```

---

## 11. Dépannage

**Awesome ne démarre pas / écran noir après connexion.**
C'est presque toujours une erreur dans `rc.lua`. Connectez-vous en console (Ctrl+Alt+F3), puis lancez `awesome -k` pour localiser l'erreur de syntaxe. Vous pouvez aussi consulter le journal des erreurs de session :

```bash
cat ~/.xsession-errors
```

**Repartir de la configuration par défaut.**
Sauvegardez votre fichier puis recopiez l'original :

```bash
mv ~/.config/awesome/rc.lua ~/.config/awesome/rc.lua.cassé
cp /etc/xdg/awesome/rc.lua ~/.config/awesome/rc.lua
```

Reconnectez-vous ou rechargez avec `Mod4 + Ctrl + r`.

**Je ne trouve pas la session « awesome » à la connexion.**
Vérifiez que le fichier `/usr/share/xsessions/awesome.desktop` existe (réinstallez le paquet `awesome` si besoin) et choisissez bien une session **Xorg**, pas Wayland.

**Mes raccourcis Mod4 ne fonctionnent pas.**
La touche Super peut être captée par un autre logiciel, ou la modkey a été changée dans la config. Vérifiez la valeur de `modkey` et l'absence d'autre outil de raccourcis global.

**Le fond d'écran disparaît après un rechargement.**
Ajoutez la restauration du fond (ex. `nitrogen --restore`) à l'autostart de `rc.lua`.

---

## 12. Aide-mémoire

### Fichiers et commandes utiles

| Élément | Valeur |
|---|---|
| Configuration utilisateur | `~/.config/awesome/rc.lua` |
| Configuration par défaut | `/etc/xdg/awesome/rc.lua` |
| Thèmes système | `/usr/share/awesome/themes/` |
| Vérifier la config | `awesome -k` |
| Recharger la config | `Mod4 + Ctrl + r` |
| Tester en bac à sable | `Xephyr :5 & sleep 1 ; DISPLAY=:5 awesome` |
| Envoyer une commande Lua à chaud | `awesome-client 'commande_lua'` |
| Journal des erreurs | `~/.xsession-errors` |
| Trouver la classe d'une fenêtre | `xprop` puis clic sur la fenêtre |

### Raccourcis les plus utilisés

`Mod4+Entrée` (terminal) · `Mod4+r` (lancer) · `Mod4+s` (aide) · `Mod4+Maj+c` (fermer) · `Mod4+Espace` (layout) · `Mod4+f` (plein écran) · `Mod4+1..9` (tags) · `Mod4+Ctrl+r` (recharger) · `Mod4+Maj+q` (quitter).

---

## 13. Ressources

- Site officiel : **awesomewm.org**
- Documentation stable (API 4.3) et tutoriel « My first Awesome » : **awesomewm.org/doc/**
- Documentation du fichier de configuration par défaut : *05-awesomerc.md* sur le site
- Système de widgets déclaratif : *03-declarative-layout.md* sur le site
- Conseils de migration de configuration : *17-porting-tips.md* sur le site
- Code source et signalement de bogues : **github.com/awesomeWM/awesome**
- Recettes et exemples de la communauté : **awesomewm.org/recipes/**

> **Note de version.** La version stable d'Awesome est la **4.3** (publiée en janvier 2019) ; c'est l'API décrite ici. Le développement se poursuit sur le dépôt Git (documentation « latest git version » sur le site officiel), mais la configuration 3.x est **incompatible** avec la 4.x : méfiez-vous des anciens tutoriels. Vérifiez toujours la version de votre paquet avec `awesome --version`.

---

*Bonne découverte d'Awesome ! La prise en main demande un peu d'investissement (c'est un environnement que l'on construit soi-même), mais le résultat est un bureau rapide, sobre et entièrement adapté à votre façon de travailler.*