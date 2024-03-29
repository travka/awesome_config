
--[[
                                                  
     Licensed under GNU General Public License v2 
      * (c) 2013,      Luke Bonham                
      * (c) 2010-2012, Peter Hofmann              
                                                  
--]]
local settings = require("widgets.settings")

local debug  = require("debug")

local awful = require("awful")
local capi   = { timer = timer }
local io     = { open = io.open }
local rawget = rawget

local theme_dir = settings.theme_dir
-- Lain helper functions for internal use
local helpers = {}

helpers.beautiful = require("beautiful")
helpers.beautiful.init(awful.util.getdir("config") .. theme_dir .. "theme.lua")
helpers.font = string.match(helpers.beautiful.font, "([%a, ]+) %d+")

helpers.dir    = debug.getinfo(1, 'S').source:match[[^@(.*/).*$]]
helpers.icons_dir   = awful.util.getdir("config") .. theme_dir .. 'icons/'
helpers.scripts_dir = helpers.dir .. 'scripts/'

helpers.mono_preset = { font=helpers.beautiful.notification_monofont,
				        opacity=helpers.beautiful.notification_opacity }

-- {{{ Modules loader

function helpers.wrequire(table, key)
    local module = rawget(table, key)
    return module or require(table._NAME .. '.' .. key)
end

-- }}}

-- {{{ Read the first line of a file or return nil.

function helpers.first_line(f)
    local fp = io.open(f)
    if not fp
    then
        return nil
    end

    local content = fp:read("*l")
    fp:close()
    return content
end

-- }}}

-- {{{ Timer maker

helpers.timer_table = {}

function helpers.newtimer(name, timeout, fun, nostart)
    helpers.timer_table[name] = capi.timer({ timeout = timeout })
    helpers.timer_table[name]:connect_signal("timeout", fun)
    helpers.timer_table[name]:start()
    if not nostart then
        helpers.timer_table[name]:emit_signal("timeout")
    end
end

-- }}}

-- {{{ A map utility

helpers.map_table = {}

function helpers.set_map(element, value)
    helpers.map_table[element] = value
end

function helpers.get_map(element)
    return helpers.map_table[element]
end

-- }}}

return helpers
