-- Standard awesome library
local revelation = require("revelation")
local beautiful = require("beautiful")
local naughty = require("naughty")
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")

if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end

beautiful.init(gears.filesystem.get_configuration_dir().."/themes/default/theme.lua")
revelation.init()

local config  = require("config")
local keybindings = require("keybindings")
require("screen")
local util = require("util")

revelation.charorder = config.revelation_charorder
terminal = config.terminal
root.keys(keybindings.globalkeys)
-- No border for maximized clients

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
			border_color = beautiful.get().border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = keybindings.clientkeys,
            buttons = keybindings.clientbuttons,
        }
    },
    -- Add titlebars to normal clients and dialogs
    {
        rule_any = {
            type = { "normal", "dialog" }
        },
        properties = {
            titlebars_enabled = false
        }
    },
}


-- }}}
-- Signal function to execute when a new client appears.
    client.connect_signal("manage", function (c)
        -- autofocus on mouse enter
        c:connect_signal("mouse::enter", function(c)
            if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
                and awful.client.focus.filter(c) then
                client.focus = c
            end
        end)
    
        if awesome.startup and
            not c.size_hints.user_position
            and not c.size_hints.program_position then
            -- Prevent clients from being unreachable after screen count changes.
            awful.placement.no_offscreen(c)
        end
        util.check_wibar(c.screen.wibar, c.screen)
    end)
    
    client.connect_signal("unmanage", function (c)
        local s = c.screen
        local curclients = s.selected_tag:clients()
        local val = true
        for _, cl in ipairs(curclients) do
            if cl.fullscreen then
                val = false
                break
            end
        end
        util.check_wibar(s.wibar, s)
    end)
    
    client.connect_signal("property::fullscreen", function(c)
        local s = c.screen
        if c.fullscreen then
        else
            local curclients = s.selected_tag:clients()
            local val = true
            for _, cl in ipairs(curclients) do
                if cl.fullscreen then
                    val = false
                    break
                end
            end
        end
    end)
    
    client.connect_signal("property::maximized", function(c) util.check_wibar(c.screen.wibar, c.screen) end)
    client.connect_signal("property::minimized", function(c) util.check_wibar(c.screen.wibar, c.screen) end)
    
    -- No border for maximized clients
    function border_adjust(c)
        if c.maximized then -- no borders if only 1 client visible
            c.border_width = 0
        elseif #awful.screen.focused().clients > 1 then
            c.border_width = beautiful.border_width
            c.border_color = beautiful.border_focus
        end
    end

    client.connect_signal("focus", border_adjust)
    client.connect_signal("property::maximized", border_adjust)
    client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
    
    -- Add a titlebar if titlebars_enabled is set to true in the rules.
    client.connect_signal("request::titlebars", function(c)
        if not awful.rules.match(c, {class = "Chrauncher"}) then
            -- buttons for the titlebar
            local buttons = gears.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
            )
            titlebaricon = awful.titlebar.widget.iconwidget(c)
            titlebaricon.forced_height = 32
            titlebaricon.forced_width = 32
    
            local maximized = wibox.widget.imagebox(profileConfigPath.."themes/default/titlebar/maximized_focus_active3.png",false)
            c:connect_signal("focus",function()
                maximized.image = "themes/default/titlebar/maximized_focus_active3.png"
            end)
            c:connect_signal("unfocus",function()
                maximized.image = "themes/default/titlebar/normal.png"
            end)
            c:connect_signal("mouse::enter",function()
                maximized.image = "themes/default/titlebar/maximized_focus_active2.png"
            end)
            c:connect_signal("mouse::leave",function()
                maximized.image = "themes/default/titlebar/maximized_focus_active3.png"
            end)
    
            titlebartext = wibox.container.margin(awful.titlebar.widget.titlewidget(c),5)
            titlebartext.align = "left"
            awful.titlebar(c, {
                size = 28,
                bg_focus = "#000000",
                bg_normal = "#31373a",
                fg_focus = "31373aff",
                fg_normal = "#aaaaaa",
            }) : setup {
                { -- Left
                    {
                        titlebaricon,
                        layout = wibox.container.margin(titlebaricon,3,0,3)
                    },
                    buttons = buttons,
                    layout  = wibox.layout.fixed.horizontal
                },
                { -- Middle
                    { -- Title
                        titlebartext,
                        layout = wibox.container.margin(titlebartext,-1)
                    },
                    buttons = buttons,
                    layout  = wibox.layout.flex.horizontal
                },
                { -- Right
                    awful.titlebar.widget.minimizebutton(c),
                    awful.titlebar.widget.maximizedbutton(c),
                    awful.titlebar.widget.closebutton(c),
                    layout = wibox.layout.fixed.horizontal()
                },
                layout = wibox.layout.align.horizontal
            }
        end
    end)
    
