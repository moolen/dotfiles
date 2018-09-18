local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local gears = require("gears")
local module_path = (...):match ("(.+/)[^/]+$") or ""

local internet = {}
local function worker(args)
  local args = args or {}
  local widget = wibox.widget.background()
  local timeout = args.timeout or 5


  local function net_update()
    connected = false
    awful.spawn.easy_async("bash -o pipefail -c \"ping -c 1 8.8.8.8 | grep 'min/avg' | cut -d '/' -f 5 | xargs printf '%.0fms' 2>&1\"",
      function(out, err, reason, exit_code)

        local widget_text = out
        if exit_code == 1 then
          widget_text = "⨯"
        end

        local internet_widget = wibox.widget {
          {
            text = widget_text,
            widget = wibox.widget.textbox,
            align = "center",
            resize = false,
          },
          layout = wibox.container.margin(brightness_icon, 0, 0, 2)
        }
        widget:set_widget(internet_widget)
      end)

    return true
  end

  net_update()
  gears.timer.start_new(timeout, net_update)

  return widget
end
return setmetatable(internet, {__call = function(_,...) return worker(...) end})

-- vim: set ts=2 sw=2 sts=2:
