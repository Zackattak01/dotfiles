local io = require("io")
local gears = require("gears")
local lain  = require("lain")
local awful = require("awful")
local naughty       = require("naughty")

local wibox = require("wibox")
local xresources = require("beautiful.xresources")

local math, string, os = math, string, os
local my_table = awful.util.table or gears.table -- 4.{0,1} compatibility

local dpi = xresources.apply_dpi

local icon_font = "Font Awesome 7 Free Solid"
local widget_icon_font = icon_font .. " 10"

math.randomseed(os.time())
local wallpapers = {}
local i = 1
for dir in io.popen([[ find /home/zack/pictures/wallpapers/ -mindepth 1 -maxdepth 1 ]]):lines() do
	wallpapers[i] = dir
	i = i + 1
end

function get_systray_color(image)
	local width = io.popen("file " .. image .. " | grep -Eo \"([[:digit:]]+)( x|x)\" | grep -Eo \"([[:digit:]]+)\""):read("*a")
	local hexNum = io.popen("convert " .. image .. " -format '%[hex:p{" .. width .. " ,0}]' info:-"):read("*a")

	return "#" .. string.sub(hexNum, 1, 6)
end

local theme                                     = {}
theme.dir                                       = os.getenv("HOME") .. "/.config/awesome/themes/comfy"
theme.wallpaper                                 = wallpapers[math.random(#(wallpapers))]
theme.font                                      = "Noto Sans Bold 11"
theme.fg_normal                                 = "#FEFEFE"
theme.fg_focus                                  = "#7b88d3"
theme.fg_urgent                                 = "#FEFEFE"
theme.bg_normal                                 = "alpha"
theme.bg_focus                                  = blue
theme.bg_urgent                                 = theme.bg_normal
theme.bg_systray				= get_systray_color(theme.wallpaper)
theme.alt_bg					= "#222222"
theme.notification_bg				= theme.alt_bg
theme.hotkeys_bg				= theme.alt_bg
theme.taglist_font				= icon_font
theme.taglist_fg_focus                          = "#FFFFFF"
theme.taglist_spacing 				= dpi(5)
theme.taglist_fg_focus				= "#333333"
theme.taglist_bg_focus				= "#F0F0F0"
theme.tasklist_bg_focus                         = theme.bg_normal
theme.tasklist_fg_focus                         = "#7b88d3"
theme.border_width                              = 2
theme.border_normal                             = "#3F3F3F"
theme.border_focus                              = "#6F6F6F"
theme.border_marked                             = "#CC9393"
theme.titlebar_bg_focus                         = "#3F3F3F"
theme.titlebar_bg_normal                        = "#3F3F3F"
theme.titlebar_bg_focus                         = theme.bg_focus
theme.titlebar_bg_normal                        = theme.bg_normal
theme.titlebar_fg_focus                         = theme.fg_focus
theme.useless_gap                               = 4
local markup = lain.util.markup
local separators = lain.util.separators


-- Update Counter
local update = awful.widget.watch("bash -c 'checkupdates | wc -l'", 3600,
    function(widget, stdout)
   	widget:set_markup(markup.font(widget_icon_font, "") .. " " .. markup.font(theme.font, stdout)) 
    end
)

-- Textclock
local clock = awful.widget.watch(
    "date +'%a %d %b%l:%M%P'", 1,
    function(widget, stdout)
        widget:set_markup(markup.font(widget_icon_font, "") .. " " .. markup.font(theme.font, stdout))
    end
)

-- Calendar
theme.cal = lain.widget.cal({
    attach_to = { clock },
    notification_preset = {
        font = "Noto Sans Mono Medium 10",
        fg   = theme.fg_normal,
        bg   = theme.alt_bg
    }
})




-- MEM
local mem = lain.widget.mem({
    settings = function()
        widget:set_markup(markup.font(widget_icon_font, "") .. markup.font(theme.font, " " .. mem_now.used .. "MB "))
    end
})

-- CPU
local cpuicon = wibox.widget.imagebox(theme.widget_cpu)
local cpu = lain.widget.cpu({
    settings = function()
        widget:set_markup(markup.font(widget_icon_font, --[[""--]] "") .. markup.font(theme.font, " " .. cpu_now.usage .. "% "))
    end
})

function theme.at_screen_connect(s)
    -- If wallpaper is a function, call it with the screen
    local wallpaper = theme.wallpaper
    if type(wallpaper) == "function" then
       wallpaper = wallpaper(s)
    end
    gears.wallpaper.maximized(wallpaper, s, true)

    -- All tags open with layout 1
    awful.tag(awful.util.tagnames, s, awful.layout.layouts[1])

    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(my_table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist
    {
	screen = s,
	filter = awful.widget.taglist.filter.all,
	style = 
	{
		shape = gears.shape.circle
	},
	buttons = awful.util.taglist_buttons
    }
    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = 22, bg = theme.bg_normal, fg = theme.fg_normal })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            --spr,
            s.mytaglist,
            s.mypromptbox,
            spr,
        },
        s.mytasklist, -- Middle widget	
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            dress_widget(update),
	    dress_widget(cpu.widget),
	    dress_widget(mem.widget),
	    dress_widget(clock),
	    wibox.container.margin(wibox.widget.systray(), 3, 0)
            --]]
        },
    }
end

function apply_background_and_shape(w, b)
	return wibox.container.background(w, b, gears.shape.rounded_rect)
end

function margin(w, s)
	return wibox.container.margin(w, s, s)
end

function dress_widget(w)
	local widget_margin = 10
	local widget_spacing = 4
	-- local background = "#454545"
	local background = "alpha"

	local orig_margin_w = margin(wibox.widget {w, layout = wibox.layout.align.horizontal}, widget_margin)
	local background_w = apply_background_and_shape(orig_margin_w, background)
	return margin(background_w, widget_spacing)
end

return theme
