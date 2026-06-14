---------------------------
-- Thème « matrix » pour AwesomeWM 4.x
-- Palette vert phosphore sur noir, inspirée de Mr. Robot.
---------------------------

local theme_assets = require("beautiful.theme_assets")
local xresources   = require("beautiful.xresources")
local dpi          = xresources.apply_dpi

local gfs          = require("gears.filesystem")
local default_path = "/usr/share/awesome/themes/default/"

local theme = {}

-- Polices
theme.font          = "Terminus 10"

-- Couleurs : matrice vert phosphore
theme.bg_normal     = "#000000"
theme.bg_focus      = "#001a00"
theme.bg_urgent     = "#003300"
theme.bg_minimize   = "#000000"
theme.bg_systray    = "#000000"

theme.fg_normal     = "#33ff33"
theme.fg_focus      = "#66ff66"
theme.fg_urgent     = "#aaffaa"
theme.fg_minimize   = "#007700"

-- Bordures et espacement
theme.useless_gap   = dpi(2)
theme.border_width  = dpi(1)
theme.border_normal = "#003300"
theme.border_focus  = "#33ff33"
theme.border_marked = "#66ff66"

-- Fond d'écran : noir uni (généré par install.sh)
theme.wallpaper     = os.getenv("HOME") .. "/.config/awesome/theme/black.png"

-- Icônes de layout : on réutilise celles fournies par le paquet awesome.
theme.layout_fairh      = default_path .. "layouts/fairhw.png"
theme.layout_fairv      = default_path .. "layouts/fairvw.png"
theme.layout_floating   = default_path .. "layouts/floatingw.png"
theme.layout_magnifier  = default_path .. "layouts/magnifierw.png"
theme.layout_max        = default_path .. "layouts/maxw.png"
theme.layout_fullscreen = default_path .. "layouts/fullscreenw.png"
theme.layout_tilebottom = default_path .. "layouts/tilebottomw.png"
theme.layout_tileleft   = default_path .. "layouts/tileleftw.png"
theme.layout_tile       = default_path .. "layouts/tilew.png"
theme.layout_tiletop    = default_path .. "layouts/tiletopw.png"
theme.layout_spiral     = default_path .. "layouts/spiralw.png"
theme.layout_dwindle    = default_path .. "layouts/dwindlew.png"
theme.layout_cornernw   = default_path .. "layouts/cornernww.png"
theme.layout_cornerne   = default_path .. "layouts/cornernew.png"
theme.layout_cornersw   = default_path .. "layouts/cornersww.png"
theme.layout_cornerse   = default_path .. "layouts/cornersew.png"

-- Icônes générées (logo dans le menu, indicateurs de taglist, etc.)
theme.awesome_icon = theme_assets.awesome_icon(
    dpi(16), theme.bg_focus, theme.fg_focus
)

-- Pas de thème d'icônes spécifique
theme.icon_theme = nil

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
