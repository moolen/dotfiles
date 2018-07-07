local gears = require("gears")
local awful = require("awful")
local config = require("config")
local util = require("util")
local revelation = require("revelation")

local keybindings = {}

keybindings.globalkeys = gears.table.join(
    -- Layout hotkeys
    awful.key({ config.modkey,           }, "space",  function () awful.layout.inc(config.layouts,  1)  end),
    awful.key({ config.modkey, "Shift"   }, "space",  function () awful.layout.inc(config.layouts, -1)  end),
    -- Tag hotkeys
    awful.key({ config.modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ config.modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    -- revelation 
    awful.key({ config.modkey,           }, "e",      revelation),
    -- By direction client focus
    awful.key({ config.modkey }, "j",
        function()
            awful.client.focus.bydirection("down")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ config.modkey }, "k",
        function()
            awful.client.focus.bydirection("up")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ config.modkey, "Shift"   }, "q",      awesome.quit),
    awful.key({ config.modkey }, "h",
        function()
            awful.client.focus.bydirection("left")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ config.modkey }, "l",
        function()
            awful.client.focus.bydirection("right")
            if client.focus then client.focus:raise() end
        end),
    awful.key({ config.modkey, config.altkey }, "1", function () util.run_once("setxkbmap us") end),
    awful.key({ config.modkey, config.altkey }, "2", function () util.run_once("setxkbmap de") end),
    -- Program Shortcuts
    awful.key({ config.modkey,           }, "Return", function () util.run_once(config.terminal) end),
    awful.key({ config.modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    -- Prompt
    awful.key({ config.modkey }, "r", function () awful.util.spawn(config.run_menu) end),
    awful.key({ config.altkey, "Shift"   }, "l",      function () awful.tag.incmwfact( 0.05)     end),
    awful.key({ config.altkey, "Shift"   }, "h",      function () awful.tag.incmwfact(-0.05)     end),
    
    -- ALSA volume control
    awful.key({ config.altkey }, "Up",
        function ()
            awful.util.spawn("amixer -q set Master 10%+")
        end),
    awful.key({ config.altkey }, "Down",
        function ()
            awful.util.spawn("amixer -q set Master 10%-")
        end),
    awful.key({ config.altkey }, "m",
        function ()
            awful.util.spawn("amixer -q set Master playback toggle")
        end)
)

keybindings.clientkeys = gears.table.join(
    awful.key({ config.modkey,           }, "o",      awful.client.movetoscreen),
    awful.key({ config.modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ config.modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ config.modkey}, "F4",      function (c) c:kill() end,
              {description = "close", group = "client"}),
    awful.key({ config.modkey, "Shift" }, "Left", function(c)
        local curtag = c:tags()[1].index
        local maxtags = #tags.names
        if curtag > 1 then
            curtag = curtag-1
        else
            curtag = maxtags
        end
        c:move_to_tag(awful.screen.focused().tags[curtag])

    end, {description = "move client -1 tag", group = "client"}),
    awful.key({ config.modkey, "Shift" }, "Right", function(c)
        local curtag = c:tags()[1].index
        local maxtags = #tags.names
        if curtag < maxtags then
            curtag = curtag+1
        else
            curtag = 1
        end
        c:move_to_tag(awful.screen.focused().tags[curtag])
    end, {description = "move client +1 tag", group = "client"}),
    awful.key({ config.modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ config.modkey, }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

keybindings.clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ config.modkey }, 1, awful.mouse.client.move),
    awful.button({ config.modkey }, 3, awful.mouse.client.resize)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 5 do
    keybindings.globalkeys = gears.table.join(keybindings.globalkeys,
        -- View tag only.
        awful.key({ config.modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Move client to tag.
        awful.key({ config.modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"})
    )
end

keybindings.tasklist_buttons = gears.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            c.minimized = false
            if not c:isvisible() and c.first_tag then
                c.first_tag:view_only()
            end
            client.focus = c
            c:raise()
        end
    end)
)

return keybindings
