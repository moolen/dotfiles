local awful = require("awful")
local lain = require("lain")
local gears = require("gears")
local beautiful = require("beautiful")

local config = {
    modkey = "Mod4",
    altkey = "Mod1",
    terminal = "kitty",
    change_wallpaper = "feh -z --bg-scale /home/moritz/dotfiles/wallpaper/",
    run_menu = "rofi -show run",
    revelation_charorder = "1234567890qwerasdf",
    layouts = {
        awful.layout.suit.fair,
        awful.layout.suit.spiral,
        awful.layout.suit.corner.nw,
        awful.layout.suit.tile,
        awful.layout.suit.floating,
    }
}

return config
