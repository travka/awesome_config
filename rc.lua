-- default rc.lua for shifty
--
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("widgets.helpers").beautiful
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
-- shifty - dynamic tagging library
local shifty = require("shifty")

local widgets = require("widgets")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({ preset = naughty.config.presets.critical,
	                 title = "Oops, there were errors during startup!",
	                 text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function (err)
		-- Make sure we don't go into an endless error loop
		if in_error then return end
		in_error = true

		naughty.notify({ preset = naughty.config.presets.critical,
		                 title = "Oops, an error happened!",
		                 text = err })
		in_error = false
	end)
end
-- }}}

-- {{{ Variable definitions
naughty.config.presets.normal.opacity = beautiful.notification_opacity
naughty.config.presets.low.opacity = beautiful.notification_opacity
naughty.config.presets.critical.opacity = beautiful.notification_opacity
naughty.config.presets.normal.font = beautiful.notification_font
naughty.config.presets.low.font = beautiful.notification_font
naughty.config.presets.critical.font = beautiful.notification_font
-- localization
os.setlocale(os.getenv("LANG"))
-- common
modkey	 = "Mod4"
altkey	 = "Mod1"
terminal = "urxvt -lsp 1 -geometry 120x30" or "xterm"
editor	 = "vim" or os.getenv("EDITOR") or "vi" or "nano"
editor_cmd = terminal .. " -e " .. editor

-- user defined
browser	= "dwb"
chromium   = "chromium --enable-user-stylesheet"
chrome   = "google-chrome --enable-user-stylesheet"
firefox	= "firefox"
file_manager = "stuurman"
tmux	   = terminal .. ' -e tmux '
musicplr   = terminal .. " -e ncmpcpp"
tmux_run   = terminal .. " -e tmux new-session"
dmenu	   = "bash ~/.config/dmenu/dmenu-bind.sh"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts = {
	awful.layout.suit.floating,
	awful.layout.suit.tile,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.fair,
	awful.layout.suit.fair.horizontal,
	awful.layout.suit.spiral,
}
-- }}}

-- {{{ Autostart applications
function run_once(cmd)
  findme = cmd
  firstspace = cmd:find(" ")
  if firstspace then
	findme = cmd:sub(0, firstspace-1)
  end
  awful.util.spawn_with_shell("pgrep -u $USER -x " .. findme .. " > /dev/null || (" .. cmd .. ")")
end

--awful.util.spawn_with_shell("eval $(gnome-keyring-daemon -s --components=pkcs11,secrets,ssh,gpg)")
awful.util.spawn_with_shell("xset r rate 250 25")
awful.util.spawn_with_shell("xset b off")
run_once("compton --backend glx --paint-on-overlay --glx-no-stencil --vsync opengl-swc --unredir-if-possible -b")
run_once("unclutter")

run_once("gxkb")
run_once("dropboxd")
-- }}}



-- {{{ Wallpaper
if beautiful.wallpaper then
	for s = 1, screen.count() do
		gears.wallpaper.maximized(beautiful.wallpaper, s)
	end
else if beautiful.wallpaper_cmd then
		run_once(beautiful.wallpaper_cmd)
	end
end
-- }}}

-- Shifty configured tags.
shifty.config.tags = {
	["1:main"] = {
		layout	= awful.layout.suit.tile,
		mwfact	= 0.60,
		exclusive = false,
		position  = 1,
		init	  = true,
		screen	= 1,2,
		slave	 = true,
	},
	["2:web"] = {
		layout	  = awful.layout.suit.tile,
		mwfact	  = 0.75,
		exclusive   = false,
		--max_clients = 1,
		position	= 2,
	--	spawn	   = browser,
	},
	["3:work"] = {
		layout	= awful.layout.suit.tile,
		mwfact	= 0.75,
		exclusive = false,
		position  = 3,
		--spawn	 = mail,
		slave	 = true
	},
	["4:im"] = {
		layout	= awful.layout.suit.tile.bottom,
		exclusive = false,
		position  = 4,
		nmaster = 0,
	},
	["5:media"] = {
		layout	= awful.layout.suit.floating,
		exclusive = false,
		position  = 5,
	},

	["6:mail"] = {
                layout    = awful.layout.suit.tile,
                mwfact    = 0.75,
                exclusive   = false,
                --max_clients = 1,
                position        = 6,
        --      spawn      = browser,
	},
}

-- SHIFTY: application matching rules
-- order here matters, early rules will be applied first
shifty.config.apps = {
	{
		match = {
			"plugin-container",
		},
		float = true,
		fullscreen = true,
		tag = "debug"
	},
	{
		match = {
			--"Navigator",
			"Vimperator",
			--"Gran Paradiso",
			"Chromium",
		},
		tag = "2:web",
	},
	{
		match = {
			"Google Chrome",
			"vmplayer",
			"meld",
			"odeskteam"
		},
		tag = "3:work",
	},
	{
		match = {
			"Skype",
			"Pidgin",
		},
		tag = "4:im",
		nopopup = true,
	},
	{
		match = {
			"OpenOffice.*",
			"Abiword",
			"Gnumeric",
		},
		tag = "office",
	},
	{
		match = {""},
		honorsizehints = false,
		slave=true,
		buttons = awful.util.table.join(
			awful.button({}, 1, function (c) client.focus = c; c:raise() end),
			awful.button({modkey}, 1, function(c)
				client.focus = c
				c:raise()
				awful.mouse.client.move(c)
				end),
			awful.button({modkey}, 3, awful.mouse.client.resize)
			)
	},
}

-- SHIFTY: default tag creation rules
-- parameter description
--  * floatBars : if floating clients should always have a titlebar
--  * guess_name : should shifty try and guess tag names when creating
--				 new (unconfigured) tags?
--  * guess_position: as above, but for position parameter
--  * run : function to exec when shifty creates a new tag
--  * all other parameters (e.g. layout, mwfact) follow awesome's tag API
shifty.config.defaults = {
	layout = awful.layout.suit.tile,
	ncol = 1,
	mwfact = 0.60,
	guess_name = true,
	guess_position = true,
}
shifty.config.sloppy=false


-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
									{ "open terminal", terminal }
								  }
						})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
									 menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

menubar.geometry = {
   height = 18,
   width = 1680,
   x = 0,
   y = 1032
}

--require("freedesktop/freedesktop")

local toolbar = require("toolbar")
toolbar.init()

-- SHIFTY: initialize shifty
-- the assignment of shifty.taglist must always be after its actually
-- initialized with awful.widget.taglist.new()
shifty.taglist = mytaglist
shifty.init()

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
	awful.button({ }, 3, function () mymainmenu:toggle() end),
	awful.button({ }, 5, awful.tag.viewnext),
	awful.button({ }, 4, awful.tag.viewprev)
))
-- }}}
-- {{{ Key bindings
globalkeys = awful.util.table.join(

	awful.key({modkey, altkey}, "s", function() awful.screen.focus_relative( 1) end),

	awful.key({ modkey, "Control"}, "t", function() systray_toggle.toggle() end),
	awful.key({ modkey, "Control"}, "s", function() run_once("xscreensaver-command -lock") end),

	awful.key({ modkey,		   }, ",",   awful.tag.viewprev	   ),
	awful.key({ modkey,		   }, ".",  awful.tag.viewnext	   ),
	awful.key({ modkey,		   }, "Escape", awful.tag.history.restore),

	-- By direction client focus
	awful.key({ modkey }, "Down",
		function()
			awful.client.focus.bydirection("down")
			if client.focus then client.focus:raise() end
		end),
	awful.key({ modkey }, "Up",
		function()
			awful.client.focus.bydirection("up")
			if client.focus then client.focus:raise() end
		end),
	awful.key({ modkey }, "Left",
		function()
			awful.client.focus.bydirection("left")
			if client.focus then client.focus:raise() end
		end),
	awful.key({ modkey }, "Right",
		function()
			awful.client.focus.bydirection("right")
			if client.focus then client.focus:raise() end
		end),

	-- By direction client swap
	awful.key({ modkey, "Shift" }, "Down",
		function()
			awful.client.swap.bydirection("down")
			if client.swap then client.swap:raise() end
		end),
	awful.key({ modkey, "Shift" }, "Up",
		function()
			awful.client.swap.bydirection("up")
			if client.swap then client.swap:raise() end
		end),
	awful.key({ modkey, "Shift" }, "Left",
		function()
			awful.client.swap.bydirection("left")
			if client.swap then client.swap:raise() end
		end),
	awful.key({ modkey, "Shift" }, "Right",
		function()
			awful.client.swap.bydirection("right")
			if client.swap then client.swap:raise() end
		end),

	-- Client resize
	awful.key({ modkey, "Control" }, "Right",	 function () awful.tag.incmwfact( 0.05)	end),
	awful.key({ modkey,	"Control" }, "Left",	 function () awful.tag.incmwfact(-0.05)	end),
	awful.key({ modkey, "Control" }, "Down", function () awful.client.incwfact(-0.05) end),
	awful.key({ modkey, "Control" }, "Up", function () awful.client.incwfact( 0.05) end),

	-- Layout tuning
	awful.key({ modkey, altkey }, "Left",	 function () awful.tag.incnmaster(-1)	  end),
	awful.key({ modkey, altkey }, "Right",	 function () awful.tag.incnmaster( 1)	  end),
	awful.key({ modkey, altkey }, "Down",	 function () awful.tag.incncol(-1)		 end),
	awful.key({ modkey, altkey }, "Up",	 function () awful.tag.incncol( 1)		 end),

	-- By direction client focus (VIM style)
	awful.key({ modkey }, "j",
		function()
			awful.client.focus.bydirection("down")
			if client.focus then client.focus:raise() end
		end),
	awful.key({ modkey }, "k",
		function()
			awful.client.focus.bydirection("up")
			if client.focus then client.focus:raise() end
		end),
	awful.key({ modkey }, "h",
		function()
			awful.client.focus.bydirection("left")
			if client.focus then client.focus:raise() end
		end),
	awful.key({ modkey }, "l",
		function()
			awful.client.focus.bydirection("right")
			if client.focus then client.focus:raise() end
		end),

	-- By direction client swap (VIM style)
	awful.key({ modkey, "Shift" }, "j",
		function()
			awful.client.swap.bydirection("down")
			if client.swap then client.swap:raise() end
		end),
	awful.key({ modkey, "Shift" }, "k",
		function()
			awful.client.swap.bydirection("up")
			if client.swap then client.swap:raise() end
		end),
	awful.key({ modkey, "Shift" }, "h",
		function()
			awful.client.swap.bydirection("left")
			if client.swap then client.swap:raise() end
		end),
	awful.key({ modkey, "Shift" }, "l",
		function()
			awful.client.swap.bydirection("right")
			if client.swap then client.swap:raise() end
		end),

	-- Client resize (VIM style)
	awful.key({ modkey, "Control" }, "l",	 function () awful.tag.incmwfact( 0.05)	end),
	awful.key({ modkey,	"Control" }, "h",	 function () awful.tag.incmwfact(-0.05)	end),
	awful.key({ modkey, "Control" }, "j", function () awful.client.incwfact(-0.05) end),
	awful.key({ modkey, "Control" }, "k", function () awful.client.incwfact( 0.05) end),

	-- Layout tuning (VIM style)
	awful.key({ modkey, altkey }, "h",	 function () awful.tag.incnmaster(-1)	  end),
	awful.key({ modkey, altkey }, "l",	 function () awful.tag.incnmaster( 1)	  end),
	awful.key({ modkey, altkey }, "j",	 function () awful.tag.incncol(-1)		 end),
	awful.key({ modkey, altkey }, "k",	 function () awful.tag.incncol( 1)		 end),


	-- Shifty: keybindings specific to shifty
	awful.key({modkey, "Shift"}, "d", shifty.del), -- delete a tag
	awful.key({modkey, "Shift"}, ",", shifty.send_prev), -- client to prev tag
	awful.key({modkey, "Shift"}, ".", shifty.send_next), -- client to next tag
	awful.key({modkey, "Shift"},
			  "n",
			  function()
				  local t = awful.tag.selected()
				  local s = awful.util.cycle(screen.count(), awful.tag.getscreen(t) + 1)
				  awful.tag.history.restore()
				  t = shifty.tagtoscr(s, t)
				  awful.tag.viewonly(t)
			  end),
	awful.key({modkey}, "a", shifty.add), -- creat a new tag
	awful.key({modkey, "Shift"}, "r", shifty.rename), -- rename a tag
	awful.key({modkey, "Shift"}, "a", -- nopopup new tag
	function()
		shifty.add({nopopup = true})
	end),

	-- Menus
	awful.key({ modkey,		   }, "w", function () mymainmenu:show() end),
	awful.key({ modkey,		   }, "i", function () instance = widgets.menu.clients_on_tag({ width=widgets.settings.screen_width, coords = {x=0, y=18}, }) end),
	awful.key({ modkey,		   }, "p", function () instance = widgets.menu.clients({ width=widgets.settings.screen_width, coords = {x=0, y=18}, }) end),
	awful.key({ modkey,"Control"}, "p", function() menubar.show() end),

	-- Layout manipulation
	awful.key({ modkey,		   }, "u", awful.client.urgent.jumpto),
	awful.key({ modkey,		   }, "Tab",
		function ()
			awful.client.focus.history.previous()
			if client.focus then
				client.focus:raise()
			end
		end),


	awful.key({ altkey,		   }, "space", function () awful.layout.inc(layouts,  1) end),
	awful.key({ altkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

	awful.key({ modkey, "Control" }, "n", awful.client.restore),

	-- Prompt
	awful.key({ modkey },			"r",	 function () mypromptbox[mouse.screen]:run() end),

	awful.key({ modkey }, "x",
			  function ()
				  awful.prompt.run({ prompt = "Run Lua code: " },
				  mypromptbox[mouse.screen].widget,
				  awful.util.eval, nil,
				  awful.util.getdir("cache") .. "/history_eval")
			  end),

	-- ALSA volume control
	awful.key({}, "#123", function () volumewidget.up() end),
	awful.key({}, "#122", function () volumewidget.down() end),
	awful.key({}, "#121", function () volumewidget.toggle() end),

	-- MPD control
	awful.key({ }, "#150", function () mpdwidget.prev_song() end),
	awful.key({ }, "#148", function () mpdwidget.next_song() end),
	awful.key({ }, "#172", function () mpdwidget.toggle() end),

	-- Copy to clipboard
	awful.key({ modkey }, "c", function () os.execute("xsel -p -o | xsel -i -b") end),

	awful.key({ modkey }, "space",  function () awful.util.spawn_with_shell(dmenu)  end),

	-- Standard program
	awful.key({ modkey,				}, "Return", function () awful.util.spawn(tmux) end),
	awful.key({ modkey,				}, "s", function () awful.util.spawn(file_manager) end),
	awful.key({ modkey, "Control"	}, "r", awesome.restart),
	awful.key({ modkey, "Control"	}, "c", function () awful.util.spawn_with_shell(chromium) end),
	awful.key({ modkey, "Control"	}, "g", function () awful.util.spawn_with_shell(chrome) end),
	awful.key({ modkey, "Control"	}, "f", function () awful.util.spawn_with_shell(firefox) end),
	awful.key({ modkey, "Shift"		}, "q", awesome.quit),

	-- Scrot stuff
	awful.key({ "Control" }, "Print",  function ()
		awful.util.spawn_with_shell("scrot -ub '%Y-%m-%d--%s_$wx$h_scrot.png' -e 'mv $f ~/images/ &amp; viewnior ~/images/$f'")
	end),
	awful.key({ altkey }, "Print",  function ()
		awful.util.spawn_with_shell("scrot -s '%Y-%m-%d--%s_$wx$h_scrot.png' -e 'mv $f ~/images/ &amp; viewnior ~/images/$f'")
	end),
	awful.key({ }, "Print",  function ()
		awful.util.spawn_with_shell("scrot '%Y-%m-%d--%s_$wx$h_scrot.png' -e 'mv $f ~/images/ &amp; viewnior ~/images/$f'")
	end)

)

clientkeys = awful.util.table.join(
	awful.key({ modkey,				}, "f",	  function (c) c.fullscreen = not c.fullscreen  end),
	awful.key({ modkey, "Shift"			}, "c",	  function (c) c:kill()						 end),
	awful.key({ modkey, "Control"	}, "space",  awful.client.floating.toggle					 ),
	awful.key({ modkey, "Control"	}, "Return", function (c) c:swap(awful.client.getmaster()) end),
	awful.key({ modkey,				}, "o",	  awful.client.movetoscreen						),
	awful.key({ modkey,				}, "t",	  function (c) c.ontop = not c.ontop			end),
	awful.key({ modkey, "Shift"		}, "t",
		function (c)
			if c.titlebar then
				awful.titlebar(c, {size = 0})
			else
				--awful.titlebar.add(c, { modkey = modkey })
				make_titlebar(c)
			end
		end),
	awful.key({ modkey, "Control", "Shift"		}, "t",
		function (c)
			awful.titlebar(c, {size = 0})
		end),
	awful.key({ modkey,				}, "n",
		function (c)
			-- The client currently has the input focus, so it cannot be
			-- minimized, since minimized clients can't have the focus.
			c.minimized = true
		end),
	awful.key({ modkey,				}, "m",
		function (c)
			c.maximized_horizontal = not c.maximized_horizontal
			c.maximized_vertical   = not c.maximized_vertical
		end)
)

-- SHIFTY: assign client keys to shifty for use in
-- match() function(manage hook)
shifty.config.clientkeys = clientkeys
shifty.config.modkey = modkey

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 12 do
	-- F-keys
--	if i>10 then
--		diff = 84
--	else
--		diff = 66
--	end
	-- num keys
	diff = 9
	globalkeys = awful.util.table.join(globalkeys,
		awful.key({ modkey }, "#" .. i + diff,
			function ()
				awful.tag.viewonly(shifty.getpos(i))
			end),
		awful.key({ modkey, "Control" }, "#" .. i + diff,
			function ()
				awful.tag.viewtoggle(shifty.getpos(i))
			end),
		awful.key({ modkey, "Shift" }, "#" .. i + diff,
			function ()
				if client.focus then
					local t = shifty.getpos(i)
					awful.client.movetotag(t)
					awful.tag.viewonly(t)
				 end
			end),
		awful.key({ modkey, "Control", "Shift" }, "#" .. i + diff,
			function ()
				if client.focus then
					awful.client.toggletag(shifty.getpos(i))
				end
			end)
	)
end

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
	-- Enable sloppy focus
	c:connect_signal("mouse::enter", function(c)
	--	if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
	--	   and awful.client.focus.filter(c) then
	--		client.focus = c
	--	end
	end)

	if not startup and not c.size_hints.user_position
	   and not c.size_hints.program_position then
		awful.placement.no_overlap(c)
		awful.placement.no_offscreen(c)
	end
	--if c.type == "dialog" then
	--make_titlebar(c)
	--end
end)

--client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
--client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- No border for maximized clients
client.connect_signal("focus",
	function(c)
		local clients = awful.client.visible(s)

		if c.maximized_horizontal == true and c.maximized_vertical == true then
			awful.titlebar(c, {size = 0})
			c.border_width = 0
			--c.border_color = beautiful.border_normal
		else
			c.border_width = beautiful.border_width
			if layout == "max" then
				awful.titlebar(c, {size = 0})
				c.border_color = beautiful.border_normal
			else
				if awful.client.floating.get(c) or awful.layout.get(c.screen) == awful.layout.suit.floating then
					--if awful.layout.get(c.screen) == awful.layout.suit.floating then
					make_titlebar(c)
				else
					awful.titlebar(c, {size = 0})
					if #clients == 1 then
						c.border_color = beautiful.border_normal
					else
						c.border_color = beautiful.border_focus
					end
				end
			end
		end
	end)
client.connect_signal("unfocus", function(c)
		if awful.client.floating.get(c) or awful.layout.get(c.screen) == awful.layout.suit.floating then
			c.border_color = beautiful.titlebar
		else
			c.border_color = beautiful.border_normal
		end
	end)
-- }}}

