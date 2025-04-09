local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
local tyrannical = require("tyrannical")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget

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
--beautiful.init(awful.util.get_themes_dir() .. "default-roah/theme.lua")
local theme_path = string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), "default-roah")
beautiful.init(theme_path)
-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("vim") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
  awful.layout.suit.tile,
  awful.layout.suit.floating,
  awful.layout.suit.max,
}
-- }}}

-- {{{ Helper functions
local function client_menu_toggle_fn()
  local instance = nil

  return function ()
    if instance and instance.wibox.visible then
      instance:hide()
      instance = nil
    else
      instance = awful.menu.clients({ theme = { width = 250 } })
    end
  end
end
-- }}}

-- First, set some settings
tyrannical.settings.default_layout =  awful.layout.suit.tile.left
tyrannical.settings.master_width_factor = 0.55
-- Some nerd icons for tags 
-- , , , 󰪶, 
-- Setup some tags
tyrannical.tags = {
  {
    name        = " ",                 -- Call the tag "Term -1
    init        = true,                   -- Load the tag on startup
    exclusive   = true,                   -- Refuse any other type of clients (by classes)
    screen      = {1,2},                   -- Create this tag on screen 1 and screen 2
    icon        = "/usr/share/awesome/icons_tags/terminal.png",                
    layout      = awful.layout.suit.tile, -- Use the tile layout
    selected    = true,
    --exec_once = {"bash /home/roah/.config/awesome/programs/startup.sh"},
    class       = { --Accept the following classes, refuse everything else (because of "exclusive=true")
      "xterm" , "urxvt" , "alacritty","URxvt","XTerm","konsole","terminator","btman", "shut-down", "wifi",
    }
  } ,
  {
    name        = " ",--Internet -2
    init        = true,
    exclusive   = true,
    screen      = {1,2},
    clone_on    = 2,
    icon        = "/usr/share/awesome/icons_tags/browser.png",                 -- Use this icon for the tag (uncomment with a real path)
    screen      = screen.count()>1 and 2 or 1,-- Setup on screen 2 if there is more than 1 screen, else on screen 1
    layout      = awful.layout.suit.max,      -- Use the max layout
    class = {
      "Opera"         , "Firefox"        , "btman"    , "Dillo"        , "brave-browser-nightly", "shut-down",
      "Chromium"      , "Brave-browser"        , "midori", "Midori", "wifi"     }
  } ,
  
  {
    name        = " ", --Develop -3
    init        = true,
    exclusive   = true,
    screen      = {1,2},
    icon        = "/usr/share/awesome/icons_tags/code.png",
    clone_on    = 2, -- Create a single instance of this tag on screen 1, but also show it on screen 2
    -- The tag can be used on both screen, but only one at once
    layout      = awful.layout.suit.tile                         ,
    class ={
      "Kate", "codium", "Code", "code-oss", "Code::Blocks" , "nvim", "kate4","Gedit","gedit", "btman", "shut-down", "wifi",
      }

  } ,
  {
    name        = " ",--Files -4
    init        = true,
    exclusive   = true,
    screen      = {1,2},
    clone_on    = 2,
    icon        = "/usr/share/awesome/icons_tags/files.png",
    layout      = awful.layout.suit.tile,
    class  = {
      "Thunar", "Konqueror", "Dolphin", "pcmanfm", "Org.gnome.Nautilus", "shut-down", "btman", "wifi",
    }
  } ,
  
  {
    name        = " ",--VM -5
    init        = true,
    exclusive   = true,
    screen      = {1,2},
    clone_on    = 2,
    icon        = "/usr/share/awesome/icons_tags/vm.png",
    layout      = awful.layout.suit.max,
    --exec_once = {"virtualbox"},
    class  = {
      "VirtualBox", "virtualbox", "VirtualBox Manager", "kdeconnect.app", "virtualbox manager", "VirtualBoxVM", "VirtualBox Machine","+VirtualBoxVM", "scrcpy", "btman", "shut-down", "wifi",
    }
  } ,

  {
    name        = " ",                 -- Call the tag "Media -6
    init        = false,                   -- Load the tag on startup
    exclusive   = false,                   -- Refuse any other type of clients (by classes)
    screen      = {1,2},                   -- Create this tag on screen 1 and screen 2
    icon        = "/usr/share/awesome/icons_tags/media.png",                
    layout      = awful.layout.suit.tile, -- Use the tile layout
    class       = { --Accept the following classes, refuse everything else (because of "exclusive=true")
      "vlc" , "spotify" , "kmix", "mpv", "btman", "shut-down", "wifi",
    }
  } ,
  
  {
    name        = "+", --7
    init        = false, -- This tag wont be created at startup, but will be when one of the
    -- client in the "class" section will start. It will be created on
    -- the client startup screen
    exclusive   = true,
    layout      = awful.layout.suit.tile,
    class       = {
      "Assistant"     , "Okular"         , "Evince"    , "EPDFviewer"   , "xpdf",
      "Xpdf"          ,                                        }
  } ,
  
}

-- Ignore the tag "exclusive" property for the following clients (matched by classes)
tyrannical.properties.intrusive = {
  "ksnapshot"     , "pinentry"       , "gtksu"     , "kcalc"        , "xcalc"               ,
  "feh"           , "Gradient editor", "spectacle" , "Paste Special", "Background color"    ,
  "0000000kcolorchooser" , "plasmoidviewer" , "Xephyr"    , "kruler"       , "plasmaengineexplorer",
}

-- Ignore the tiled layout for the matching clients
tyrannical.properties.floating = {
  "MPlayer"      , "pinentry"        , "ksnapshot"  , "pinentry"     , "btman"          ,
  "xine"         , "feh"             , "kmix"       , "kcalc"        , "xcalc"          ,
  "yakuake"      , "Select Color$"   , "kruler"     , "kcolorchooser", "Paste Special"  ,
  "spectacle"     , "Insert Picture"  , "kcharselect", "mythfrontend" , "plasmoidviewer", "shut-down", "wifi"
}

-- Make the matching clients (by classes) on top of the default layout
tyrannical.properties.ontop = {
  "Xephyr"       , "ksnapshot"       , "spectacle", "btman", "shut-down", "wifi",
}

-- Force the matching clients (by classes) to be centered on the screen on init
tyrannical.properties.centered = {
  "kcalc"
}

-- Do not honor size hints request for those classes
tyrannical.properties.size_hints_honor = { xterm = false, URxvt = false, aterm = false, sauer_client = false, mythfrontend  = false}

-- }}}
---
myawesomemenu = {
    { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "manual", terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart", awesome.restart },
    { "quit", function() awesome.quit() end },
    }

 editormenu = {
     { "gedit",     "gedit" },
     { "micro",     terminal .. " -e micro" },
 }
 
 officemenu = {
     { "files",     "pcmanfm" },
     { "writer",    "loffice --writer" },
     { "calc",      "loffice --calc" },
     { "impress",   "loffice --impress" }
 }
 
 networkmenu = {
     { "firefox",   "firefox" },
	{ "falkon",	"falkon" },
     { "w3m",       terminal .. " -e 'w3m google.go.in'" },
     { "nw-manager", terminal .. " -e nmtui" }
 }
 
 grafixmenu = {
     { "viewnior", "viewnior" },
     { "color picker", "agave" },
     { "gimp", "gimp" },
     { "inkscape", "inkscape" }
 }
 
 termmenu = {
    { "termite", "termite" },
    { "terminator", "terminator" },
    { "sakura",    "sakura" },
    { "urxvtc",      "urxvtc" }
 }
 
multimediamenu = {
    { "deadbeef", "deadbeef" },
    { "ncmpcpp" , terminal .. " -e ncmpcpp" },
    { "pulseaudio", "pavucontrol" },
    { "vlc",    "vlc" }
 }
 
settingsmenu = {
    { "lxappearance", "lxappearance" },
 }
 
systemmenu = {
    { "software-manager", "pamac-manager" },
    { "pacman-mirrors", terminal .. " -e 'sudo pacman-mirrors -f'" },
    { "htop", terminal .. " -e htop" },
    { "kill", "xkill" }
 }

utilsmenu = {
    { "screenshot", "scrot -d5 AwSm-Scrot-%d%b%y-%M%S.png -e 'mv $f ~/shots' && viewnior ~/shots/$f" },
    { "toggleConky", "toggleAwesomeConky" },
    { "virt manager", "virt-manager" },    
    { "screengrab", "screengrab" }
 }

myexitmenu = {
	{ "logout", function() awesome.quit() end},
	{ "reboot", "systemctl reboot" },
	{ "shutdown", "systemctl poweroff" }
}
 
 mymainmenu = awful.menu({ 
                items = { 
                    { "editors", editormenu },
                    { "terms" , termmenu },
                    { "network", networkmenu },
                    { "office", officemenu },
                    { "grafix", grafixmenu },
                    { "multimedia", multimediamenu },
                    { "settings", settingsmenu },
                    { "system", systemmenu },
                    { "utils", utilsmenu },
                    { "awesome", myawesomemenu },
                    { "exit options", myexitmenu}
}                         
                         })
 
mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                      menu = mymainmenu })
---

mymainmenu = awful.menu({ items = { { "Roah OS", myawesomemenu, },
                                    { "open terminal", terminal },
                                    { "Settings", settingsmenu, },
                                    { "Utils", utilsmenu, },
                                    { "Editors", editormenu, },
                                    { "Power options", myexitmenu, }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create a wibox for each screen and add it
-- @TAGLIST_BUTTON@
local taglist_buttons = awful.util.table.join(
  awful.button({ }, 1, function(t) t:view_only() end),
  awful.button({ modkey }, 1, function(t)
      if client.focus then
        client.focus:move_to_tag(t)
      end
  end),
  awful.button({ }, 3, awful.tag.viewtoggle),
  awful.button({ modkey }, 3, function(t)
      if client.focus then
        client.focus:toggle_tag(t)
      end
  end),
  awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
  awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

-- @TASKLIST_BUTTON@
local tasklist_buttons = awful.util.table.join(
  awful.button({ }, 1, function (c)
      if c == client.focus then
        c.minimized = true
      else
        -- Without this, the following
        -- :isvisible() makes no sense
        c.minimized = false
        if not c:isvisible() and c.first_tag then
          c.first_tag:view_only()
        end
        -- This will also un-minimize
        -- the client, if needed
        client.focus = c
        c:raise()
      end
  end),
  awful.button({ }, 3, client_menu_toggle_fn()),
  awful.button({ }, 4, function ()
      awful.client.focus.byidx(1)
  end),
  awful.button({ }, 5, function ()
      awful.client.focus.byidx(-1)
end))

-- @DOC_WALLPAPER@
local function set_wallpaper(s)
  -- Wallpaper
  if beautiful.wallpaper then
    local wallpaper = beautiful.wallpaper
    -- If wallpaper is a function, call it with the screen
    if type(wallpaper) == "function" then
      wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)
  end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

-- @DOC_FOR_EACH_SCREEN@
awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
                            awful.button({ }, 1, function () awful.layout.inc(awful.layout.layouts, 1) end),
                            awful.button({ }, 3, function () awful.layout.inc(awful.layout.layouts, -1) end),
                            awful.button({ }, 4, function () awful.layout.inc(awful.layout.layouts, 1) end),
                            awful.button({ }, 5, function () awful.layout.inc(awful.layout.layouts, -1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, tasklist_buttons)

    -- @DOC_WIBAR@
    -- Create the top wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, bg=beautiful.bg_normal.."95", height = "20"})
  
    -- @DOC_SETUP_WIDGETS@
    -- Add widgets to the wibox
    s.mywibox:setup {
      layout = wibox.layout.align.horizontal,
      { -- Left widgets
        layout = wibox.layout.align.horizontal,
	--mylauncher,
	wibox.widget.imagebox("/home/roah/Downloads/r.png"),
	wibox.widget.textbox(" |  "),
        s.mytaglist,
        s.mypromptbox,
      },
      {
       layout = wibox.layout.align.horizontal,
       mykeyboardlayout,-- Middle widget
      },
      { -- Right widgets
        layout = wibox.layout.fixed.horizontal,        
	wibox.widget.textbox(" |  "),
        mytextclock,
	wibox.widget.textbox(" |  "),
	wibox.widget.systray(),
        --s.mylayoutbox
      },
    }
    -- Create the bottom wibox
    s.mywibox = awful.wibar({ position = "bottom", screen = s, bg=beautiful.bg_normal.."00", height = "15"})
  
    -- @DOC_SETUP_WIDGETS@
    -- Add widgets to the wibox
    s.mywibox:setup {
          layout = wibox.layout.align.horizontal,
          { -- Left widgets
            layout = wibox.layout.align.horizontal,
    	s.mytasklist,
          },
          {
           layout = wibox.layout.align.horizontal,
           mykeyboardlayout,-- Middle widget
          },
          { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            s.mylayoutbox
          },
        }
end)
-- }}}
-- {{{ Mouse bindings
-- @DOC_ROOT_BUTTONS@
root.buttons(awful.util.table.join(
               awful.button({ }, 3, function () mymainmenu:toggle() end),
               awful.button({ }, 4, awful.tag.viewnext),
               awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
-- @DOC_GLOBAL_KEYBINDINGS@
globalkeys = awful.util.table.join(


---
  awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
    {description="show help", group="awesome"}),
  awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
    {description = "view previous", group = "tag"}),
  awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
    {description = "view next", group = "tag"}),
  awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
    {description = "go back", group = "tag"}),

  awful.key({ modkey,           }, "j",
    function ()
      awful.client.focus.byidx( 1)
    end,
    {description = "focus next by index", group = "client"}
  ),
  awful.key({ modkey,           }, "k",
    function ()
      awful.client.focus.byidx(-1)
    end,
    {description = "focus previous by index", group = "client"}
  ),

  -- Layout manipulation
  awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
    {description = "swap with next client by index", group = "client"}),
  awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
    {description = "swap with previous client by index", group = "client"}),
  awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
    {description = "focus the next screen", group = "screen"}),
  awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
    {description = "focus the previous screen", group = "screen"}),
  awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
    {description = "jump to urgent client", group = "client"}),
  awful.key({ modkey,           }, "Tab",
    function ()
      awful.client.focus.history.previous()
      if client.focus then
        client.focus:raise()
      end
    end,
    {description = "go back", group = "client"}),

  -- Standard program/hotkeys/shortcutsB

---- Start of Customized--Custom global keys for volume
  awful.key({ "Control" }, ".", function () awful.util.spawn("amixer -q sset Master 2%+", false) end,
    {description = "volume increase", group = "Customized launchers /volume"}),
  awful.key({"Control" }, ",", function () awful.util.spawn("amixer -q sset Master 2%-", false) end,
    {description = "volume decrease", group = "Customized launchers /volume"}),
  awful.key({"Control" }, "m", function () awful.util.spawn("amixer -q sset Master toggle", false) end,
    {description = "volume mute/unmute", group = "Customized launchers /volume"}),
----
  awful.key({ modkey,           }, "e", function () awful.spawn("pcmanfm") end,
    {description = "open file manager", group = "Customized launchers"}),
    
  awful.key({ modkey,           }, "b", function () awful.spawn("brave-browser-nightly") end,
    {description = "open brave", group = "Customized launchers"}),
    
  awful.key({ modkey,           }, "c", function () awful.spawn("alacritty --class 'nvim' -e nvim") end,
    {description = "open nvim(editor)", group = "Customized launchers"}),
    
  awful.key({ modkey, "Shift"   }, "b", function () awful.spawn("alacritty --class 'btman' -e btman") end,
    {description = "open bluetooth", group = "Customized launchers"}),
    
  awful.key({ modkey, "Shift"   }, "n", function () awful.spawn("alacritty --class 'wifi' -e wifi") end,
    {description = "open wifi", group = "Customized launchers"}),
  --awful.key({ modkey,           }, "c", function () awful.spawn("alacritty --class 'nvim' -e nvim") end,
    --{description = "open nvim(editor)", group = "Customized launchers"}),
    
  awful.key({ modkey, "Shift"   }, "v", function () awful.spawn("virtualbox") end,
    {description = "open virtaulbox manager", group = "Customized launchers"}),
    
  awful.key({ modkey,           }, "d", function () awful.spawn("rofi -show") end,
    {description = "open rofi", group = "Customized launchers"}),
  awful.key({ modkey, "Shift"   }, "s", function () awful.spawn("spectacle") end,
    {description = "open screenshot tool", group = "Customized launchers"}),
    
  awful.key({ modkey, "Shift"   }, "c", function () awful.spawn("scrcpy") end,
    {description = "open scrcpy", group = "Customized launchers"}),
    
  awful.key({ modkey, "Shift"   }, "p", function () awful.spawn("alacritty --class 'shut-down' -e shut-down") end,
    {description = "power menu", group = "Customized launchers"}),

  awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
    {description = "open a terminal", group = "launcher"}),
    
  awful.key({ modkey, "Control" }, "r", awesome.restart,
    {description = "reload awesome", group = "awesome"}),
    
  awful.key({ modkey, "Shift"   }, "q", awesome.quit,
    {description = "quit awesome", group = "awesome"}),

  awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
    {description = "increase master width factor", group = "layout"}),
  awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
    {description = "decrease master width factor", group = "layout"}),
  awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
    {description = "increase the number of master clients", group = "layout"}),
  awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
    {description = "decrease the number of master clients", group = "layout"}),
  awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
    {description = "increase the number of columns", group = "layout"}),
  awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
    {description = "decrease the number of columns", group = "layout"}),
  awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
    {description = "select next layout", group = "layout"}),
  awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
    {description = "select previous", group = "layout"}),

  awful.key({ modkey, "Control" }, "n",
    function ()
      local c = awful.client.restore()
      -- Focus restored client
      if c then
        client.focus = c
        c:raise()
      end
    end,
    {description = "restore minimized", group = "client"}),

  -- Prompt
 -- awful.key({ modkey },            "p",     function () awful.screen.focused().mypromptbox:run() end,
 -- {description = "run prompt", group = "launcher"}),

  awful.key({ modkey, "control" }, ";",
    function ()
      awful.prompt.run {
        prompt       = "Run Lua code: ",
        textbox      = awful.screen.focused().mypromptbox.widget,
        exe_callback = awful.util.eval,
        history_path = awful.util.get_cache_dir() .. "/history_eval"
      }
    end,
    {description = "lua execute prompt", group = "awesome"}),
  -- Menubar
  awful.key({ modkey }, "r", function() menubar.show() end,
    {description = "show the menubar", group = "launcher"})
)

-- @DOC_CLIENT_KEYBINDINGS@
clientkeys = awful.util.table.join(
  awful.key({ modkey,           }, "f",
    function (c)
      c.fullscreen = not c.fullscreen
      c:raise()
    end,
    {description = "toggle fullscreen", group = "client"}),
  awful.key({ modkey,           }, "q",      function (c) c:kill()                         end,
    {description = "close", group = "client"}),
  awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
    {description = "toggle floating", group = "client"}),
  awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
    {description = "move to master", group = "client"}),
  awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
    {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- @DOC_NUMBER_KEYBINDINGS@
-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 0, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

-- @DOC_CLIENT_BUTTONS@
clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
-- @DOC_RULES@
awful.rules.rules = {
    -- @DOC_GLOBAL_RULE@
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- @DOC_FLOATING_RULE@
    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
        },
        class = {
          "Arandr",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Wpa_gui",
          "pinentry",
          "veromix",
          "xtightvncviewer"},

        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- @DOC_DIALOG_RULE@
    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
-- @DOC_MANAGE_HOOK@
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and
      not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- @DOC_TITLEBARS@
-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
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

    awful.titlebar(c) : setup {
        { -- Left
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "left",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.

client.connect_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end
end)

-- @DOC_BORDER@
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Window Gaps
beautiful.useless_gap = 5

--Appearance stuff
beautiful.notification_opacity = '100'
beautiful.notification_icon_size = 100
beautiful.notification_bg = '#1a1a1a'
beautiful.notification_fg = '#d4be98'


-- Autostart
--awful.spawn.with_shell("xfce4-power-manager")
--awful.spawn.with_shell("nitrogen --restore")
--awful.spawn.with_shell("picom")
awful.spawn.with_shell("kdeconnect-indicator")
awful.spawn.with_shell("xcompmgr")
awful.spawn.with_shell("bash ~/.config/awesome/programs/startup.sh")
awful.spawn.with_shell("alacritty -e sudo pacman -Sy")
awful.spawn.with_shell("alacritty -e xrandr --output Virtual1 --mode 1920x1080")

