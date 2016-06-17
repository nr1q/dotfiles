-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
      awful.rules = require("awful.rules")

-- Laouts, utilities and widgets
local lain = require("lain")

require("volume")
require('archmenu')
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local vicious = require("vicious")
local menubar = require("menubar")

-- Naughty notifier config
--naughty.config.defaults.timeout       = 5
--naughty.config.defaults.screen        = 1
--naughty.config.defaults.position      = "top_right"
naughty.config.defaults.margin        = 16
--naughty.config.defaults.height        = 16
--naughty.config.defaults.width         = 300
naughty.config.defaults.gap           = 13
--naughty.config.defaults.ontop         = true
naughty.config.defaults.font          = beautiful.font
naughty.config.defaults.fg            = beautiful.fg_focus
naughty.config.defaults.bg            = '#000000e0'
naughty.config.presets.border_color   = beautiful.border_focus
naughty.config.defaults.border_width  = 2

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

-- Themes define colours, icons, and wallpapers
config_dir = (os.getenv('HOME') .. "/.config/awesome")
themes_dir = (config_dir .. "/themes")
beautiful.init(themes_dir .. "/hnrch/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvtc -bc"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    --awful.layout.suit.tile,
    lain.layout.uselesstile,
    lain.layout.uselesstile.left,
    lain.layout.uselesstile.bottom,
    lain.layout.uselesstile.top,
    --awful.layout.suit.fair,
    --lain.layout.uselessfair,
    --lain.layout.uselessfair.horizontal,
    lain.layout.uselesspiral,
    lain.layout.uselesspiral.dwindle,
    awful.layout.suit.max,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
  names = { '  C O D E  ', '  W W W  ', '  T E R M  ', '  A / V  ', '  R A N D  ' },
  layouts = { layouts[2], layouts[1], layouts[1], layouts[1], layouts[1], layouts[1] }
}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layouts)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "apps", xdgmenu },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Widgets
-- Net
-- netwidget = wibox.widget.textbox()
-- vicious.register(netwidget, vicious.widgets.net, function(widget, args)
--     local i = "" -- Interface
--     if args["{wlp3s0 carrier}"] == 1 then
--         i = "wlp3s0"
--     elseif args["{enp2s0 carrier}"] == 1 then
--         i = "enp2s0"
--     else
--         return ""
--     end
--     return args["{" .. i .. " down_kb}"] .. '↓ ' .. args["{" .. i .." up_kb}"] .. '↑ '
-- end, 1)


-- Keyboard widget
kbdwidget = wibox.widget.textbox()
kbdwidget:set_markup("  keyboard_<span font_desc='terminus bold 10' color='#fff'>en</span>")

dbus.request_name("session", "ru.gentoo.kbdd")
dbus.add_match("session", "interface='ru.gentoo.kbdd',member='layoutChanged'")
dbus.connect_signal("ru.gentoo.kbdd", function(...)
    local data = {...}
    local layout = data[2]
    lts = {[0] = "en", [1] = "latam"}
kbdwidget:set_markup("  keyboard_<span font_desc='terminus bold 10' color='#fff'>" .. lts[layout] .. '</span>')
end)


-- Mail widget
mailWidget = wibox.widget.textbox()
mailWidgetTimer = timer({ timeout = 1800 })

function f_mailWidget()
    mailWidget:set_markup( " mail_<span font_desc='terminus bold 10' color='#fff'>" .. awful.util.pread("/usr/local/bin/maic.py") .. "</span>" )
end

mailWidgetTimer:connect_signal("timeout", f_mailWidget)
mailWidgetTimer:start()
--f_mailWidget() -- check mail now, or wait timeout event
-- TODO use this instead of the above
--mailWidget = lain.widgets.imap({server='imap.openmailbox.org',
                                --mail='nrq@openmailbox.org',
                                --password='pass Nrq/opmbx'})

-- Battery
mybattery = wibox.widget.textbox()
vicious.register(mybattery, vicious.widgets.bat, function(widget, args)
  --naughty.notify({ title = "test",
                   --text = args[1] ..' '.. args[2] })
  if args[1] == '−' and args[2] <= 7 then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = '¡Batería sin carga!',
                     text = 'Apagando…' })
    awful.util.spawn_with_shell("shutdown -h now")
  elseif args[1] == '−' and args[2] <= 14 then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = '¡Bajo nivel de batería!',
                     text = "Conecte el computador al tomacorriente\nTiempo restante: " .. args[3],
                     timeout = 20 })
  elseif args[1] == '↯' and args[2] == 100 then
    --naughty.notify({ title = 'Batera cargada',
                     --text = "Ya puede desconectar el ordenador",
                     --timeout = 20 })
  end
  return "  battery_<span font_desc='terminus bold 10' color='#fff'>" .. args[2] .. '</span>'
end, 15, "BAT0")

-- Temperature
tempwidget = wibox.widget.textbox()
vicious.register(tempwidget, vicious.widgets.thermal,
                "  temp_<span font_desc='terminus bold 10' color='#fff'>$1</span>",
                15,
                'thermal_zone0')

-- Volume
myvolume = wibox.widget.textbox()
vicious.register(myvolume, vicious.widgets.volume, function(widget, args)
  local muted = ' '
  if args[2] ~= '♫' then muted = '_muted ' end
  return "  volume_<span font_desc='terminus bold 10' color='#fff'>" .. args[1] .. muted .. '</span>'
end, 0.2, "Master")
-- }}}

-- Cheatsheet
function display_awesome_cheatsheet()
  cheatsheet_text = '\
Jargon                                                          Navigation\
    Client:               The application window                    Mod4 + j:               Focus next client\
    Tag:                  a.k.a. Desktop                            Mod4 + k:               Focus previous client\
    Mod4:                 Windows key                               Mod4 + u:               Focus first urgent client\
    Mod4 + c:             Show this cheatsheet                      Mod4 + ←:               View previous tag\
                                                                    Mod4 + →:               View next tag\
Window Manager                                                      Mod4 + 1-9:             Switch to tag 1-9\
    Mod4 + Ctrl + r:      Restart Awesome                           Mod4 + F1:              Focus screen 1\
    Mod4 + Shift + q:     Quit Awesome                              Mod4 + F2:              Focus screen 2\
    Mod4 + r:             Run prompt                                Mod4 + ESC:             Focus previously selected tag set\
    Mod4 + x:             Run Lua code prompt \
    Mod4 + Return:        Spawn a terminal in current tag       Layout Modification\
    Mod4 + w:             Open main menu                            Mod4 + Shift + k/j:     Rotate clients around\
                                                                    Mod4 + h/l:             Change master width by 5%\
Clients                                                             Mod4 + Shift + h:       Number of master windows +1\
    Mod4 + m:             Toggle the maximized state                Mod4 + Shift + l:       Number of master windows -1\
    Mod4 + n:             Minimize the focused client\
    Mod4 + Ctrl + n:      Restore the minimized client              Mod4 + Space:           Next layout\
    Mod4 + f:             Toggle fullscreen                         Mod4 + Shift + Space:   Previous layout\
    Mod4 + t:             Toggle ontop                              Mod4 + Ctrl + Space:    Toggle floating master\
    Mod4 + Shift + t:     Kill focused client                       Mod4 + Ctrl + Return:   Swap focused client with master\
    Mod4 + p:             Launcher\
\
Mouse\
    B1,B2,B3:             Mouse buttons 1-3 \
    Mod4 + B1 on tag:     Send current client to clicked tag \
    Mod4 + B1 on client:  Move window \
    Mod4 + B3 on tag:     Toggle this tag for client \
    Mod4 + B3 on client:  Resize window \
    B3 clicked on tag:    Add tag to current view \
\
click this box to close'

  naughty.notify({
    position = 'bottom_right',
    font = 'terminus 12',
    title = "Awesome WM Cheat Sheet",
    bg = '#000000e0',
    timeout = 0,
    text = cheatsheet_text,
    screen = mouse.screen
  })
end
-- End Cheatsheet

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create a wibox for each screen and add it
mywibox = {}
mynewbox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
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
                                                  instance = awful.menu.clients({ width=250 })
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

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })
    mynewbox[s] = awful.wibox({ position = "bottom", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    --left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mailWidget)
    right_layout:add(tempwidget)
    right_layout:add(mybattery)
    right_layout:add(kbdwidget)
    right_layout:add(myvolume)
    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    local bottom = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_right(right_layout)
    bottom:set_middle(mytasklist[s])

    mywibox[s]:set_widget(layout)
    mynewbox[s]:set_widget(bottom)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
    -- commented to avoid tag change on mouse scroll
    --awful.button({ }, 4, awful.tag.viewnext),
    --awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "F1", function () awful.screen.focus(1) end),
    awful.key({ modkey,           }, "F2", function () awful.screen.focus(2) end),

    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    -- terminal without transparency
    awful.key({ modkey, "Shift"   }, "Return", function () awful.util.spawn(terminal .. ' -depth 0') end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    --awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    --awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    -- Mail fetching
    awful.key({ modkey, "Control" }, "h",     function() mailWidgetTimer:emit_signal("timeout") end),

    -- Screensaver
    awful.key({ }, "XF86ScreenSaver",         function () awful.util.spawn('electricsheep') end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Cheatsheet
    awful.key({ modkey },            "c",     function () display_awesome_cheatsheet() end),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),

    -- Volume
    awful.key({ }, "XF86AudioRaiseVolume", function ()
        awful.util.spawn("amixer set Master 2dB+", false) end),
    awful.key({ }, "XF86AudioLowerVolume", function ()
        awful.util.spawn("amixer set Master 2dB-", false) end),
    awful.key({ }, "XF86AudioMute", function ()
        awful.util.spawn("amixer sset Master toggle", false) end),

     -- Brightness
     --awful.key({  }, "XF86MonBrightnessDown", function ()
        --awful.util.spawn("xbacklight -dec 2") end),
     --awful.key({  }, "XF86MonBrightnessUp", function ()
        --awful.util.spawn("xbacklight -inc 2") end),

    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.movetotag(tag)
                     end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      local tag = awful.tag.gettags(client.focus.screen)[i]
                      if client.focus and tag then
                          awful.client.toggletag(tag)
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule       = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },

    { rule_any   = { class = { "MPlayer", "pinentry", "gimp",
                               "ProjectGeneratorSimple" } },
      properties = { floating = true } },

    { rule       = { class = "URxvt" },
      properties = { border_width = 2,
                     size_hints_honor = false },
      callback   = function(client)
        --local w_area = screen[ client.screen ].workarea
        --naughty.notify({title = "blah", text = w_area.width/2 })
        client:geometry( {x=33, y=47, width=1300, height=540} )
      end },

    { rule       = { class = "Xombrero" },
      properties = { floating = true },
      callback   = function(client)
        client:geometry( {x=33, y=47, width=1300, height=640} )
      end },

    { rule       = { class = "chromium" },
      properties = { tag = tags[1][2],
                   border_width = 0 } },
    { rule       = { role = "Browser", class = "chromium" },
      properties = { floating = false, maximized = true } },
    { rule       = { role = "pop-up", class = "chromium" },
      properties = { floating = true } },

}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    c:connect_signal("mouse::enter", function(c)
        -- Enable sloppy focus
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
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

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)


-- more on clients and signals:
-- https://awesome.naquadah.org/doc/api/modules/client.html#Tables
-- http://awesome.naquadah.org/wiki/Signals#tag

--client.connect_signal("new", function(c)
    --naughty.notify({title = "blah", text = client.name })
--end)

-- opacity personalization
client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
    --naughty.notify({timeout = 10, title = c.name, text = c.class })
    --naughty.notify({timeout = 10, title = c.name, text = c.role })
    --naughty.notify({timeout = 10, title = c.name, text = c.ontop })
    --if c.class ~= "URxvt" then
        c.opacity = 1.0
    --end
end)
client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
    if c.class ~= "MPlayer" and c.name ~= "Electric Sheep" and
       c.class ~= "Gimp" and c.role ~= "gimp-image-window" and
       c.class ~= "Vlc" then
        if c.class ~= "URxvt" then
            c.opacity = 0.66
        else
            c.opacity = 0.77
        end
    end
end)

-- no borders on maximized terminals
client.connect_signal("property::maximized", function(c)
    if c.class == "URxvt" and c.maximized then
        c.border_width = 0
    end
end)
client.connect_signal("property::floating", function(c)
    if c.class == "URxvt" then
        c.border_width = 2
    end
end)

-- }}}

-- vim: foldmethod=marker :foldlevel=0
