local awful = require("awful")
local naughty = require("naughty")
local beautiful = require("beautiful")
local config = require("config")

local util = {}

util.run_once = function(cmd)
    findme = cmd
    firstspace = cmd:find(" ")
    if firstspace then
        findme = cmd:sub(0, firstspace-1)
    end
    awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

util.wallpaper_changer = function(_)
    util.run_once(config.change_wallpaper)
end

-- Wibar transparent/opaque function
util.check_wibar = function(obj, s)

end



return util
