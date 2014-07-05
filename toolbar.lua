local wibox = require("wibox")
local beautiful = require("beautiful")
local awful = require("awful")
local widgets = require("widgets")
--local rpic = require("widgets.random_pic")
local toolbar = {}
function toolbar.init()

-- {{{ Wibox
markup = widgets.markup

-- ALSA volume
volicon = wibox.widget.imagebox(beautiful.widget_vol)
voliconbg = wibox.widget.background(volicon, beautiful.alt_bg)
volumewidget = widgets.alsa({
	channel = 'Master',
	settings = function()
		if volume_now.status == "off" then
			volicon:set_image(beautiful.widget_vol_mute)
		elseif tonumber(volume_now.level) == 0 then
			volicon:set_image(beautiful.widget_vol_no)
		elseif tonumber(volume_now.level) <= 50 then
			volicon:set_image(beautiful.widget_vol_low)
		elseif tonumber(volume_now.level) <= 75 then
			volicon:set_image(beautiful.widget_vol)
		else
			volicon:set_image(beautiful.widget_vol_high)
		end

		widget:set_text("" .. volume_now.level .. "%")
	end
})
volumewidgetbg = wibox.widget.background(volumewidget, beautiful.alt_bg)

-- MPD
mpdicon = wibox.widget.imagebox(beautiful.widget_music)
mpdicon:buttons(awful.util.table.join(awful.button({ }, 1, function () awful.util.spawn_with_shell(musicplr) end)))
mpdwidget = widgets.mpd({
	music_dir = '/media/m/music/',
	settings = function()
		if mpd_now.state == "play" then
			artist = " " .. mpd_now.artist .. "   "
			title  = mpd_now.title  .. " "
			mpdicon:set_image(beautiful.widget_music_on)
		elseif mpd_now.state == "pause" then
			artist = "mpd "
			title  = "paused "
			mpdicon:set_image(beautiful.widget_music)
		else
			artist = ""
			title  = ""
			mpdicon:set_image(beautiful.widget_music)
		end

		widget:set_markup('<span font="' .. beautiful.tasklist_font .. '">' .. markup(beautiful.mpd_text, artist) .. title .. '</span>')
			end
})
mpdwidgetbg = mpdwidget

-- MEM
memwidget = widgets.mem({
	list_length = 20,
})
memicon = wibox.widget.imagebox(beautiful.widget_mem)
memicon:connect_signal("mouse::enter", function () memwidget.show_notification() end)
memicon:connect_signal("mouse::leave", function () memwidget.hide_notification() end)

-- CPU
cpuwidget = widgets.cpu({
	list_length = 20,
})
cpuicon = wibox.widget.imagebox(beautiful.widget_cpu)
cpuicon:connect_signal("mouse::enter", function () cpuwidget.show_notification() end)
cpuicon:connect_signal("mouse::leave", function () cpuwidget.hide_notification() end)

-- Coretemp
tempicon = wibox.widget.imagebox(beautiful.widget_temp)
tempwidget = widgets.temp({
sensor = "Core 0",
	critical = 75
})

-- Textclock
clockicon = wibox.widget.imagebox(beautiful.widget_clock)
-- mytextclock = awful.widget.textclock(" %a %d %b  %H:%M")
mytextclock = awful.widget.textclock(" %H:%M")

-- calendar
widgets.calendar:attach(mytextclock)

-- Battery
baticon = wibox.widget.imagebox(beautiful.widget_battery)
batwidget = widgets.bat({
	 settings = function()
		if bat_now.on_bat == "no" then
			baticon:set_image(beautiful.widget_ac)
		 	widget:set_bg(beautiful.bg)
		 	widget:set_fg(beautiful.fg)
		elseif bat_now.lo_bat == 'yes' then
			baticon:set_image(beautiful.widget_battery_empty)
		 	widget:set_bg(beautiful.error)
		 	widget:set_fg(beautiful.bg)
		elseif tonumber(bat_now.perc) <= 25 then
			baticon:set_image(beautiful.widget_battery_low)
		 	widget:set_bg(beautiful.fg)
		 	widget:set_fg(beautiful.bg)
		else
			baticon:set_image(beautiful.widget_battery)
		 	widget:set_bg(beautiful.bg)
		 	widget:set_fg(beautiful.fg)
		end
		widget.widget:set_markup(string.format("%-4s",bat_now.perc .. "%"))
	end
})

-- Separators
spr = wibox.widget.textbox(' ')
sep  = wibox.widget.textbox(' ')

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
					awful.button({ }, 1, awful.tag.viewonly),
					awful.button({ modkey }, 1, awful.client.movetotag),
					awful.button({ }, 3, awful.tag.viewtoggle),
					awful.button({ modkey }, 3, awful.client.toggletag),
					awful.button({ }, 5, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
					awful.button({ }, 4, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
					)
mycurrenttask = {}
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
	awful.button({ }, 1, function (c)
		if c == client.focus then
			c.minimized = true
		else
			-- Without this, the following
			-- :isvisible() makes no sense
			c.minimized = false
			if not c:isvisible() then
				awful.tag.viewonly(c:tags()[1])
			end
			-- This will also un-minimize
			-- the client, if needed
			client.focus = c
			c:raise()
		end
	end),
	awful.button({ }, 3, function ()
		if instance then
			instance:hide()
			instance = nil
		else
			instance = widgets.menu.clients({ width=450 })
		end
	end),
	awful.button({ }, 4, function ()
		awful.client.focus.byidx(1)
		if client.focus then client.focus:raise() end
	end),
	awful.button({ }, 5, function ()
		awful.client.focus.byidx(-1)
		if client.focus then client.focus:raise() end
	end))
	systray_toggle = widgets.systray_toggle

for s = 1, screen.count() do
	-- Create a promptbox for each screen
	mypromptbox[s] = awful.widget.prompt()
	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	mylayoutbox[s] = awful.widget.layoutbox(s)
	mylayoutbox[s]:buttons(awful.util.table.join(
						   awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
						   awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
						   awful.button({ }, 5, function () awful.layout.inc(layouts, 1) end),
						   awful.button({ }, 4, function () awful.layout.inc(layouts, -1) end)))
	-- Create a taglist widget
	mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

	-- Create a tasklist widget
	mytasklist[s] = widgets.tasklist(s, widgets.tasklist.filter.focused_and_minimized_current_tags, mytasklist.buttons)

	-- Create the wibox
	mywibox[s] = awful.wibox({ position = "top", screen = s, height = 18 })

	-- Widgets that are aligned to the left
	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(spr)
	left_layout:add(mytaglist[s])
	left_layout:add(mypromptbox[s])
	left_layout:add(spr)

	-- Widgets that are aligned to the right
	local right_layout = wibox.layout.fixed.horizontal()
	right_layout:add(spr)
	right_layout:add(sep)
	right_layout:add(mpdicon)
	right_layout:add(mpdwidgetbg)
	right_layout:add(sep)
	right_layout:add(voliconbg)
	right_layout:add(volumewidgetbg)
	right_layout:add(sep)
	if s == 1 then right_layout:add(systray_toggle(s)) end
	right_layout:add(sep)
	right_layout:add(memicon)
	right_layout:add(memwidget)
	right_layout:add(sep)
	right_layout:add(cpuicon)
	right_layout:add(cpuwidget)
	right_layout:add(tempicon)
	right_layout:add(tempwidget)
	right_layout:add(sep)
	right_layout:add(baticon)
	right_layout:add(batwidget)
	right_layout:add(sep)
	right_layout:add(mytextclock)
	right_layout:add(spr)
	right_layout:add(mylayoutbox[s])

	-- Now bring it all together (with the tasklist in the middle)
	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	layout:set_middle(mytasklist[s])
	layout:set_right(right_layout)

	mywibox[s]:set_widget(layout)
end
-- }}}

function minimizedbutton(c)
        return awful.titlebar.widget.button(c, "minimized", function() return "" end, function(c) c.minimized=true end)
end
-- {{{
function make_titlebar(c)
	c.border_color = beautiful.titlebar_focus
	-- buttons for the titlebar
	local buttons = awful.util.table.join(
		awful.button({ }, 1, function()
			client.focus = c
			c:raise()
			awful.mouse.client.move(c)
		end),
                awful.button({ }, 2, function()
                        client.focus = c
                        c:raise()
			c.maximized_horizontal = not c.maximized_horizontal
                        c.maximized_vertical   = not c.maximized_vertical
                end),
		awful.button({ }, 3, function()
			client.focus = c
			c:raise()
			awful.mouse.client.resize(c)
		end)
		)
	-- Widgets that are aligned to the left
	local left_layout = wibox.layout.fixed.horizontal()
	left_layout:add(awful.titlebar.widget.closebutton(c))
	left_layout:add(minimizedbutton(c))
	--left_layout:add(awful.titlebar.widget.maximizedbutton(c))
	-- Widgets that are aligned to the right
	local right_layout = wibox.layout.fixed.horizontal()
	right_layout:add(awful.titlebar.widget.ontopbutton(c))
	right_layout:add(awful.titlebar.widget.stickybutton(c))
	-- The title goes in the middle
	local middle_layout = wibox.layout.flex.horizontal()
	local title = awful.titlebar.widget.titlewidget(c)
	title:set_align("center")
	title:set_font(beautiful.titlebar_font)
	middle_layout:add(title)
	middle_layout:buttons(buttons)
	-- Now bring it all together
	local layout = wibox.layout.align.horizontal()
	layout:set_left(left_layout)
	layout:set_right(right_layout)
	layout:set_middle(middle_layout)

	awful.titlebar(c,{size=16}):set_widget(layout)
end
-- }}}

end
return toolbar
