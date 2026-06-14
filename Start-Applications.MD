# Lancer ses applications au démarrage avec AwesomeWM

Pour lancer automatiquement tes applications préférées au démarrage avec
AwesomeWM, tu modifies ton fichier de configuration
`~/.config/awesome/rc.lua`. Voici les principales approches.

## Méthode simple : `awful.spawn`

Tu peux ajouter directement des appels dans ton `rc.lua` :

```lua
awful.spawn("firefox")
awful.spawn("kitty")
awful.spawn.with_shell("nm-applet")
```

Le problème de cette méthode : chaque fois que tu recharges la config
(`Mod+Ctrl+R`), les applications se relancent et tu te retrouves avec des
doublons.

## Méthode recommandée : fonction `run_once`

Pour éviter ces doublons, on définit une fonction qui vérifie si le processus
tourne déjà avant de le lancer :

```lua
local function run_once(cmd)
    local findme = cmd
    local firstspace = cmd:find(" ")
    if firstspace then
        findme = cmd:sub(0, firstspace - 1)
    end
    awful.spawn.with_shell(
        string.format("pgrep -u $USER -x %s > /dev/null || (%s)", findme, cmd)
    )
end

run_once("nm-applet")
run_once("picom")
run_once("firefox")
```

Place ces appels vers la fin de ton `rc.lua`. Ainsi un rechargement de la
config ne dupliquera pas tes programmes.

## Méthode via un script externe

Beaucoup de gens préfèrent séparer l'autostart dans un script shell dédié, par
exemple `~/.config/awesome/autostart.sh` :

```bash
#!/usr/bin/env bash
run() {
    if ! pgrep -f "$1" > /dev/null; then
        "$@" &
    fi
}

run nm-applet
run picom
run firefox
```

Rends-le exécutable (`chmod +x ~/.config/awesome/autostart.sh`) puis appelle-le
depuis `rc.lua` :

```lua
awful.spawn.with_shell("~/.config/awesome/autostart.sh")
```

C'est pratique car tu gères ta liste d'applications sans toucher au Lua.

## Méthode XDG (fichiers `.desktop`)

Si tu veux profiter du standard freedesktop (les fichiers dans
`~/.config/autostart/`), installe `dex` puis ajoute dans `rc.lua` :

```lua
awful.spawn.with_shell("dex -a -e Awesome")
```

Cela lance automatiquement tout ce qui est déclaré dans les fichiers `.desktop`
d'autostart.

---

Pour un usage personnel, la fonction `run_once` ou le script externe sont les
solutions les plus souples.

Une précision utile : `awful.spawn` attend une commande sans passer par le
shell (pas d'expansion de `~`, de pipes, etc.), tandis que
`awful.spawn.with_shell` passe par le shell et accepte cette syntaxe. C'est
pourquoi le script externe utilise `with_shell`.