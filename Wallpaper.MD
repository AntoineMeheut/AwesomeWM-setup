# Changer le fond d'écran avec AwesomeWM

AwesomeWM gère le fond d'écran via le module `gears.wallpaper`, mais beaucoup de
gens préfèrent utiliser un outil externe comme `feh` ou `nitrogen`. Voici les
différentes approches.

## Méthode native : le thème

Dans une configuration AwesomeWM par défaut, le fond d'écran est défini par la
variable `theme.wallpaper` de ton fichier de thème, par exemple
`~/.config/awesome/themes/default/theme.lua` :

```lua
theme.wallpaper = "/home/utilisateur/Images/mon-fond.jpg"
```

C'est le `rc.lua` qui lit cette valeur, généralement via une fonction
`set_wallpaper` :

```lua
local function set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- Si c'est une fonction, on l'appelle avec l'écran
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end
```

Après avoir modifié `theme.wallpaper`, recharge la config avec `Mod+Ctrl+R`.

## Méthode native : directement dans `rc.lua`

Tu peux aussi appeler `gears.wallpaper` directement sans passer par le thème :

```lua
local gears = require("gears")

gears.wallpaper.maximized("/home/utilisateur/Images/mon-fond.jpg", s, false)
```

Le module propose plusieurs modes d'affichage :

- `gears.wallpaper.maximized(chemin, ecran, ignore_aspect)` — remplit l'écran.
- `gears.wallpaper.fit(chemin, ecran, fond)` — adapte sans déformer.
- `gears.wallpaper.centered(chemin, ecran, fond, echelle)` — centre l'image.
- `gears.wallpaper.tiled(chemin, ecran, decalage)` — répète l'image en mosaïque.
- `gears.wallpaper.set("#1a1a1a")` — applique une couleur unie.

Le paramètre `ecran` (`s`) est important si tu as plusieurs moniteurs : la
fonction doit être appliquée à chaque écran, ce que gère déjà la fonction
`set_wallpaper` connectée au signal `request::wallpaper` ou
`property::geometry`.

## Méthode externe : `feh`

`feh` est l'outil le plus répandu. Tu peux l'appeler depuis ton `rc.lua` :

```lua
awful.spawn.with_shell("feh --bg-scale /home/utilisateur/Images/mon-fond.jpg")
```

Quelques modes utiles de `feh` :

- `--bg-scale` — étire l'image pour remplir l'écran.
- `--bg-fill` — remplit en rognant, sans déformer.
- `--bg-max` — affiche l'image en entier avec des bandes.
- `--bg-center` — centre l'image.
- `--bg-tile` — répète l'image en mosaïque.

Astuce : `feh` enregistre la dernière commande dans `~/.fehbg`. Tu peux donc
simplement appeler ce script au démarrage :

```lua
awful.spawn.with_shell("~/.fehbg")
```

## Méthode externe : `nitrogen`

`nitrogen` offre une interface graphique pour choisir ton fond d'écran. Tu le
lances une fois manuellement (`nitrogen`), tu sélectionnes ton image, puis tu
restaures ce choix au démarrage depuis `rc.lua` :

```lua
awful.spawn.with_shell("nitrogen --restore")
```

## Quelle méthode choisir ?

La méthode native (`gears.wallpaper` ou `theme.wallpaper`) est la plus
intégrée : pas de dépendance externe, et le fond se réapplique automatiquement
au changement de résolution ou de moniteur.

`feh` ou `nitrogen` sont pratiques si tu veux gérer le fond d'écran
indépendamment d'AwesomeWM, ou le partager avec d'autres environnements
légers.

---

**Rappel** : `awful.spawn` ne passe pas par le shell (pas d'expansion de `~`),
tandis que `awful.spawn.with_shell` l'accepte. Pour appeler `~/.fehbg` ou une
commande avec `~`, utilise bien `with_shell`.