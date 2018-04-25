-- Standard awesome library
local gears = require("gears")
local timer = require("gears.timer")
local awful = require("awful")
              require("awful.autofocus")
local keybindings = require("keybindings")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local common = require("awful.widget.common")
local dpi = require("beautiful").xresources.apply_dpi
local config = require("config")
local util = require("util")
local lain = require("lain")
require("client")

tags = {
    names  = {"λ","⋚","∞","Ẅ","ω"},
}

menubar.utils.terminal = config.terminal

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", util.wallpaper_changer)
awful.screen.connect_for_each_screen(function(s)
    local sgeo = s.geometry
    local index = s.index
    util.wallpaper_changer(s)
    tags[s] = awful.tag(tags.names, s, config.layouts[1])
    
    s:connect_signal("tag::history::update", function()
        local curclients = s.selected_tag:clients()
        local val = true
        for _, c in ipairs(curclients) do
            if c.fullscreen then
                val = false
                break
            end
        end
    end)
    -- Create a tasklist widget for each screen
    local taskliststyle = {
        bg_focus = "#00000000",
        bg_normal = "#00000000",
        spacing = 0
    }
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, keybindings.tasklist_buttons, taskliststyle)
    local taglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, nil, {
        bg_focus = "#00000000",
    })

    local volumewidget = lain.widget.alsa({
        timeout = 2,
        settings = function()
            header = " Vol "
            vlevel  = volume_now.level

            if volume_now.status == "off" then
                vlevel = vlevel .. "M "
            else
                vlevel = vlevel .. " "
            end

            widget:set_markup( "♪ " .. vlevel )
        end
    })

    local textclock = wibox.container.margin(wibox.widget.textclock("%d %b %Y | %H:%M"), 5, 7, 0, 0)

    local mybattery = lain.widget.bat({
        batteries = {"BAT0", "BAT1"},
        settings = function()
            widget:set_markup("↯ " .. bat_now.perc)
        end
    })

    local mybat = wibox.container.margin(mybattery.widget, 10, 5, 0, 0)

    local mymemory = lain.widget.mem({
        settings = function()
            widget:set_markup("◶ "..mem_now.used.."M")
        end
    })
    local mymem = wibox.container.margin(mymemory.widget, 10, 15, 0, 0)


    -- Create a wibox for each screen #31373a00
    s.wibar = awful.wibar({
        position = "bottom",
        screen = s,
        bg = "#00000000",
        height = 20,
    })
    -- Add widgets to the wibox
    s.wibar:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            taglist,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mybat,
            mymem,
            volumewidget,
            textclock,
        },
    }
end)
