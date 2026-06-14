-- =============================================================================
--  ~/.config/awesome/rc.lua — setup « Mr. Robot » sur AwesomeWM 4.x
--
--  Reproduit le screenshot du projet : urxvt vert phosphore, tags nommés,
--  wibar avec widgets vicious (Wifi, CPU, RAM, Vol, Bat) et autostart
--  (picom, nm-applet, feh, xrdb).
-- =============================================================================

-- Empêche `luarocks` de se mettre en travers s'il est installé sur la machine
pcall(require, "luarocks.loader")

-- Bibliothèques standard
local gears     = require("gears")
local awful     = require("awful")
                  require("awful.autofocus")
local wibox     = require("wibox")
local beautiful = require("beautiful")
local naughty   = require("naughty")
local menubar   = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
                      require("awful.hotkeys_popup.keys")

-- Widgets vicious (paquet awesome-extra)
local vicious   = require("vicious")

-- =============================================================================
-- Gestion d'erreurs
-- =============================================================================

if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title  = "Erreur au démarrage d'AwesomeWM",
                     text   = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true
        naughty.notify({ preset = naughty.config.presets.critical,
                         title  = "Erreur AwesomeWM",
                         text   = tostring(err) })
        in_error = false
    end)
end

-- =============================================================================
-- Thème et variables globales
-- =============================================================================

beautiful.init(gears.filesystem.get_configuration_dir() .. "theme/theme.lua")

terminal   = "urxvt"
editor     = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor
modkey     = "Mod4"  -- touche Super (Windows)

-- Layouts disponibles (court : on s'en tient au pavage)
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.max,
    awful.layout.suit.floating,
}

-- =============================================================================
-- Menu principal (clic gauche sur le logo)
-- =============================================================================

local myawesomemenu = {
    { "hotkeys",     function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "manual",      terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart",     awesome.restart },
    { "quit",        function() awesome.quit() end },
}

local mymainmenu = awful.menu({
    items = {
        { "awesome",       myawesomemenu, beautiful.awesome_icon },
        { "open terminal", terminal },
    },
})

local mylauncher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu  = mymainmenu,
})

menubar.utils.terminal = terminal

-- =============================================================================
-- Widgets de la wibar
-- =============================================================================

local mytextclock = wibox.widget.textclock(" %H:%M ")

-- Indicateur de langue (statique : on se contente de "en")
local kbd_widget = wibox.widget.textbox(" en ")

-- WiFi : adapter `wlan0` à votre interface (`iwconfig` ou `ip link`).
local wifi_widget = wibox.widget.textbox()
vicious.register(wifi_widget, vicious.widgets.wifi,
    " Wifi: Li: ${link} Si: ${sign} ", 5, "wlan0")

-- CPU
local cpu_widget = wibox.widget.textbox()
vicious.register(cpu_widget, vicious.widgets.cpu, " CPU $1% ", 3)

-- RAM
local mem_widget = wibox.widget.textbox()
vicious.register(mem_widget, vicious.widgets.mem, " RAM $2/$3MB ", 5)

-- Volume (PulseAudio, canal Master)
local vol_widget = wibox.widget.textbox()
vicious.register(vol_widget, vicious.widgets.volume, " Vol $1 ", 2, "Master")

-- Batterie : adapter `BAT0` (`ls /sys/class/power_supply/`).
local bat_widget = wibox.widget.textbox()
vicious.register(bat_widget, vicious.widgets.bat, " Bat $2% ", 30, "BAT0")

-- Séparateur visuel
local function make_sep() return wibox.widget.textbox(" | ") end

-- =============================================================================
-- Wibar par écran
-- =============================================================================

local taglist_buttons = gears.table.join(
    awful.button({ },        1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
    awful.button({ },        3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end),
    awful.button({ },        4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ },        5, function(t) awful.tag.viewprev(t.screen) end)
)

local tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal("request::activate", "tasklist", { raise = true })
        end
    end),
    awful.button({ }, 3, function() awful.menu.client_list({ theme = { width = 250 } }) end),
    awful.button({ }, 4, function() awful.client.focus.byidx( 1) end),
    awful.button({ }, 5, function() awful.client.focus.byidx(-1) end)
)

local function set_wallpaper(s)
    if beautiful.wallpaper then
        local wp = beautiful.wallpaper
        if type(wp) == "function" then wp = wp(s) end
        gears.wallpaper.maximized(wp, s, true)
    end
end

screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)

    -- Tags nommés (§7.3 INSTALL.MD)
    local names   = { "1:main", "2:docs", "3:dist", "4:irc",
                      "5:web",  "6:imgs", "7:search" }
    local l       = awful.layout.suit
    local layouts = { l.tile, l.tile, l.tile, l.tile,
                      l.tile, l.tile, l.tile }
    awful.tag(names, s, layouts)

    -- Prompt et layoutbox
    s.mypromptbox = awful.widget.prompt()
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
        awful.button({ }, 1, function() awful.layout.inc( 1) end),
        awful.button({ }, 3, function() awful.layout.inc(-1) end),
        awful.button({ }, 4, function() awful.layout.inc( 1) end),
        awful.button({ }, 5, function() awful.layout.inc(-1) end)
    ))

    -- Taglist / tasklist
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,
    }

    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons,
    }

    -- Wibar haute
    s.mywibox = awful.wibar({ position = "top", screen = s })

    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Widgets de gauche
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- centre
        { -- Widgets de droite (§7.4 INSTALL.MD)
            layout = wibox.layout.fixed.horizontal,
            kbd_widget,  make_sep(),
            wifi_widget, make_sep(),
            cpu_widget,  make_sep(),
            mem_widget,  make_sep(),
            vol_widget,  make_sep(),
            bat_widget,
            mytextclock,
            s.mylayoutbox,
        },
    }
end)

-- =============================================================================
-- Bindings souris (sur le bureau)
-- =============================================================================

root.buttons(gears.table.join(
    awful.button({ }, 3, function() mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

-- =============================================================================
-- Raccourcis clavier globaux
-- =============================================================================

local globalkeys = gears.table.join(
    awful.key({ modkey }, "s", hotkeys_popup.show_help,
              { description = "show help", group = "awesome" }),
    awful.key({ modkey }, "Left",   awful.tag.viewprev,
              { description = "view previous", group = "tag" }),
    awful.key({ modkey }, "Right",  awful.tag.viewnext,
              { description = "view next",     group = "tag" }),
    awful.key({ modkey }, "Escape", awful.tag.history.restore,
              { description = "go back",       group = "tag" }),

    awful.key({ modkey }, "j", function() awful.client.focus.byidx( 1) end,
              { description = "focus next by index", group = "client" }),
    awful.key({ modkey }, "k", function() awful.client.focus.byidx(-1) end,
              { description = "focus previous by index", group = "client" }),
    awful.key({ modkey }, "w", function() mymainmenu:show() end,
              { description = "show main menu", group = "awesome" }),

    awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(  1) end,
              { description = "swap with next client by index", group = "client" }),
    awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx( -1) end,
              { description = "swap with previous client by index", group = "client" }),
    awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative( 1) end,
              { description = "focus the next screen", group = "screen" }),
    awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
              { description = "focus the previous screen", group = "screen" }),
    awful.key({ modkey }, "u", awful.client.urgent.jumpto,
              { description = "jump to urgent client", group = "client" }),
    awful.key({ modkey }, "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then client.focus:raise() end
        end,
        { description = "go back", group = "client" }),

    -- Standard
    awful.key({ modkey },           "Return", function() awful.spawn(terminal) end,
              { description = "open a terminal", group = "launcher" }),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              { description = "reload awesome", group = "awesome" }),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              { description = "quit awesome", group = "awesome" }),

    awful.key({ modkey },           "l",     function() awful.tag.incmwfact( 0.05) end,
              { description = "increase master width factor", group = "layout" }),
    awful.key({ modkey },           "h",     function() awful.tag.incmwfact(-0.05) end,
              { description = "decrease master width factor", group = "layout" }),
    awful.key({ modkey, "Shift"   }, "h",    function() awful.tag.incnmaster( 1, nil, true) end,
              { description = "increase the number of master clients", group = "layout" }),
    awful.key({ modkey, "Shift"   }, "l",    function() awful.tag.incnmaster(-1, nil, true) end,
              { description = "decrease the number of master clients", group = "layout" }),
    awful.key({ modkey, "Control" }, "h",    function() awful.tag.incncol( 1, nil, true) end,
              { description = "increase the number of columns", group = "layout" }),
    awful.key({ modkey, "Control" }, "l",    function() awful.tag.incncol(-1, nil, true) end,
              { description = "decrease the number of columns", group = "layout" }),
    awful.key({ modkey },           "space", function() awful.layout.inc( 1) end,
              { description = "select next", group = "layout" }),
    awful.key({ modkey, "Shift"   }, "space", function() awful.layout.inc(-1) end,
              { description = "select previous", group = "layout" }),

    awful.key({ modkey, "Control" }, "n",
        function()
            local c = awful.client.restore()
            if c then c:emit_signal("request::activate", "key.unminimize", { raise = true }) end
        end,
        { description = "restore minimized", group = "client" }),

    -- Invite "Run:"
    awful.key({ modkey }, "r",
        function() awful.screen.focused().mypromptbox:run() end,
        { description = "run prompt", group = "launcher" }),

    awful.key({ modkey }, "x",
        function()
            awful.prompt.run {
                prompt       = "Run Lua code: ",
                textbox      = awful.screen.focused().mypromptbox.widget,
                exe_callback = awful.util.eval,
                history_path = awful.util.get_cache_dir() .. "/history_eval",
            }
        end,
        { description = "lua execute prompt", group = "awesome" }),

    awful.key({ modkey }, "p", function() menubar.show() end,
              { description = "show the menubar", group = "launcher" })
)

-- Tags 1..7 (on a 7 tags nommés, donc on ne crée que 7 bindings)
for i = 1, 7 do
    globalkeys = gears.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then tag:view_only() end
            end,
            { description = "view tag #" .. i, group = "tag" }),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then awful.tag.viewtoggle(tag) end
            end,
            { description = "toggle tag #" .. i, group = "tag" }),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then client.focus:move_to_tag(tag) end
                end
            end,
            { description = "move focused client to tag #" .. i, group = "tag" }),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then client.focus:toggle_tag(tag) end
                end
            end,
            { description = "toggle focused client on tag #" .. i, group = "tag" })
    )
end

root.keys(globalkeys)

-- =============================================================================
-- Raccourcis clavier / souris pour les clients (fenêtres)
-- =============================================================================

local clientkeys = gears.table.join(
    awful.key({ modkey }, "f",
        function(c) c.fullscreen = not c.fullscreen; c:raise() end,
        { description = "toggle fullscreen", group = "client" }),
    awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end,
              { description = "close", group = "client" }),
    awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
              { description = "toggle floating", group = "client" }),
    awful.key({ modkey, "Control" }, "Return",
        function(c) c:swap(awful.client.getmaster()) end,
        { description = "move to master", group = "client" }),
    awful.key({ modkey }, "o", function(c) c:move_to_screen() end,
              { description = "move to screen", group = "client" }),
    awful.key({ modkey }, "t", function(c) c.ontop = not c.ontop end,
              { description = "toggle keep on top", group = "client" }),
    awful.key({ modkey }, "n", function(c) c.minimized = true end,
              { description = "minimize", group = "client" }),
    awful.key({ modkey }, "m",
        function(c) c.maximized = not c.maximized; c:raise() end,
        { description = "(un)maximize", group = "client" })
)

local clientbuttons = gears.table.join(
    awful.button({ },        1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
    end),
    awful.button({ modkey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.resize(c)
    end)
)

-- =============================================================================
-- Règles d'attribution
-- =============================================================================

awful.rules.rules = {
    -- Règles par défaut
    {
        rule = { },
        properties = {
            border_width     = beautiful.border_width,
            border_color     = beautiful.border_normal,
            focus            = awful.client.focus.filter,
            raise            = true,
            keys             = clientkeys,
            buttons          = clientbuttons,
            screen           = awful.screen.preferred,
            placement        = awful.placement.no_overlap + awful.placement.no_offscreen,
        },
    },

    -- Fenêtres rendues flottantes par défaut
    {
        rule_any = {
            instance = { "DTA", "copyq", "pinentry" },
            class = {
                "Arandr", "Blueman-manager", "Gpick", "Kruler",
                "MessageWin", "Sxiv", "Tor Browser", "Wpa_gui",
                "veromix", "xtightvncviewer",
            },
            name = { "Event Tester" },
            role = { "AlarmWindow", "ConfigManager", "pop-up" },
        },
        properties = { floating = true },
    },

    -- Titlebars ajoutées sur les fenêtres normales et boîtes de dialogue
    {
        rule_any = { type = { "normal", "dialog" } },
        properties = { titlebars_enabled = false },
    },

    -- Règles spécifiques au setup « Mr. Robot » (§7.5 INSTALL.MD)
    { rule = { class = "URxvt", name = "irssi"  },
      properties = { tag = "4:irc" } },
    { rule = { class = "URxvt", name = "ranger" },
      properties = { tag = "6:imgs" } },
    { rule = { class = "firefox" },
      properties = { tag = "5:web" } },
}

-- =============================================================================
-- Signaux clients
-- =============================================================================

client.connect_signal("manage", function(c)
    if awesome.startup
       and not c.size_hints.user_position
       and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
end)

client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus",   function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)

-- =============================================================================
-- Autostart (§7.6 INSTALL.MD)
-- =============================================================================

local function run_once(cmd)
    awful.spawn.with_shell(string.format(
        "pgrep -u $USER -fx '%s' >/dev/null || (%s &)", cmd, cmd))
end

run_once("xrdb -merge ~/.Xresources")
run_once("picom --config /dev/null")
run_once("nm-applet")
run_once("feh --bg-fill " .. os.getenv("HOME") .. "/.config/awesome/theme/black.png")

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
