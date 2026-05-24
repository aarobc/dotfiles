-- Keybindings
local mod = "SUPER"

-- Keycodes (physical QWERTY positions, used so binds stay stable across layouts)
local apos   = "code:24"
local comma  = "code:25"
local period = "code:26"
local p      = "code:27"
local r      = "code:32"
local l      = "code:33"
local o      = "code:39"
local e      = "code:40"
local u      = "code:41"
local d      = "code:43"
local h      = "code:44"
local t      = "code:45"
local n      = "code:46"
local s      = "code:47"
local j      = "code:54"
local k      = "code:55"

local terminal = "foot"
local menu = "wofi --show run --insensitive --matching strict-contains"

local function log(msg)
	local f = io.open("/tmp/hypr_debug.log", "a")
	if f then f:write(msg .. "\n") f:close() end
end

-- Lock
hl.bind(mod .. " + " .. l, hl.dsp.exec_cmd("hyprlock"))

-- Core
hl.bind(mod .. " + Return",            hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + SHIFT + " .. apos,  hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + M",         hl.dsp.exit())
hl.bind(mod .. " + SHIFT + space",     hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + " .. e,             hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + " .. u,             hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

local hy3 = hl.plugin.hy3

-- hy3 splits
hl.bind(mod .. " + " .. d, hy3.make_group("h"))
hl.bind(mod .. " + " .. k, hy3.make_group("v"))
hl.bind(mod .. " + A",     hy3.change_focus("raise"))

-- Focus (hy3)
hl.bind(mod .. " + " .. h, hy3.move_focus("l"))
hl.bind(mod .. " + " .. s, hy3.move_focus("r"))
hl.bind(mod .. " + " .. n, hy3.move_focus("u"))
hl.bind(mod .. " + " .. t, hy3.move_focus("d"))

-- Pre-create hy3 move_window dispatchers at config-load time
local hy3_mv_l = hy3.move_window("l")
local hy3_mv_r = hy3.move_window("r")

local function get_adjacent_monitor(focused, dir)
	for _, mon in ipairs(hl.get_monitors()) do
		if (dir == "r" and mon.x == focused.x + focused.width) or
		   (dir == "l" and mon.x + mon.width == focused.x) then
			return mon
		end
	end
end


local function move_window_h(dir, fallback)
	local win = hl.get_active_window()
	if not win then return hl.dispatch(fallback) end

	local before = win.at
	hl.dispatch(fallback)

	local after = hl.get_active_window()
	if not after or after.at.x ~= before.x or after.at.y ~= before.y then return end

	local adj = get_adjacent_monitor(win.monitor, dir)
	if not adj then return end

	hl.dispatch(hl.dsp.window.move({ monitor = adj, follow = true }))
end

hl.bind(mod .. " + SHIFT + " .. h, function() move_window_h("l", hy3_mv_l) end)
hl.bind(mod .. " + SHIFT + " .. s, function() move_window_h("r", hy3_mv_r) end)
hl.bind(mod .. " + SHIFT + " .. n, hy3.move_window("u"))
hl.bind(mod .. " + SHIFT + " .. t, hy3.move_window("d"))

-- Workspaces
for i = 1, 10 do
	local key = i % 10 -- 10 maps to "0"
	hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
	hl.bind(mod .. " + SHIFT + " .. key, hy3.move_to_workspace(i))
end

-- Move current workspace to monitor
hl.bind(mod .. " + SHIFT + CONTROL + " .. h, hl.dsp.workspace.move({ monitor = "l" }))
hl.bind(mod .. " + SHIFT + CONTROL + " .. s, hl.dsp.workspace.move({ monitor = "r" }))

-- Mouse binds
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Custom scroll override (replaces default workspace scroll)
hl.bind(mod .. " + mouse_down", hl.dsp.exec_cmd("~/dotfiles/waybar/scroll.sh 0"))
hl.bind(mod .. " + mouse_up",   hl.dsp.exec_cmd("~/dotfiles/waybar/scroll.sh 1"))

-- Media keys (bindel = locked + repeating in original)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Player keys (bindl = locked only)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
