local mod = 'SUPER'

local function sc(...)
	return table.concat({...}, ' + ')
end

-- Forward declarations for runtime functions defined at the bottom of the file
local log, cycle_ws_on_monitor

-- Keycodes (physical QWERTY positions, used so binds stay stable across layouts)
local apos   = 'code:24'
local comma  = 'code:25'
local period = 'code:26'
local p      = 'code:27'
local r      = 'code:32'
local l      = 'code:33'
local o      = 'code:39'
local e      = 'code:40'
local u      = 'code:41'
local d      = 'code:43'
local h      = 'code:44'
local t      = 'code:45'
local n      = 'code:46'
local s      = 'code:47'
local j      = 'code:54'
local k      = 'code:55'

local terminal = 'foot'
local menu = '~/dotfiles/scripts/launcher.sh menu'

-- Lock
hl.bind(sc(mod, l), hl.dsp.exec_cmd('hyprlock'))

-- Core
hl.bind(sc(mod, 'Return'),         hl.dsp.exec_cmd(terminal))
hl.bind(sc(mod, 'SHIFT', apos),    hl.dsp.window.close())
hl.bind(sc(mod, 'SHIFT', 'M'),     hl.dsp.exit())
hl.bind(sc(mod, 'SHIFT', 'space'), hl.dsp.window.float({ action = 'toggle' }))
hl.bind(sc(mod, e),                hl.dsp.exec_cmd(menu))
hl.bind(sc(mod, u),                hl.dsp.window.fullscreen({ mode = 'fullscreen', action = 'toggle' }))

if hl.plugin and hl.plugin.hy3 then
	require("hy3")
else
	hl.exec_cmd("notify-send 'hy3 plugin not found, loading fallback keybindings'")
	require("fallback")
end

-- Tab: cycle workspaces on focused monitor
hl.bind(sc(mod, 'Tab'),          function() cycle_ws_on_monitor(1)  end)
hl.bind(sc(mod, 'SHIFT', 'Tab'), function() cycle_ws_on_monitor(-1) end)

-- Move current workspace to monitor
hl.bind(sc(mod, 'SHIFT', 'CONTROL', h), hl.dsp.workspace.move({ monitor = 'l', once = false, visible = false }))
hl.bind(sc(mod, 'SHIFT', 'CONTROL', s), hl.dsp.workspace.move({ monitor = 'r', once = false, visible = false }))

-- Mouse binds
hl.bind(sc(mod, 'mouse:272'), hl.dsp.window.drag(),   { mouse = true })
hl.bind(sc(mod, 'mouse:273'), hl.dsp.window.resize(), { mouse = true })

-- Custom scroll override (replaces default workspace scroll)
hl.bind(sc(mod, 'mouse_down'), hl.dsp.exec_cmd('~/dotfiles/waybar/scroll.sh 0'))
hl.bind(sc(mod, 'mouse_up'),   hl.dsp.exec_cmd('~/dotfiles/waybar/scroll.sh 1'))

-- Media keys (bindel = locked + repeating in original)
hl.bind('XF86AudioRaiseVolume',  hl.dsp.exec_cmd('wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+'), { locked = true, repeating = true })
hl.bind('XF86AudioLowerVolume',  hl.dsp.exec_cmd('wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-'),      { locked = true, repeating = true })
hl.bind('XF86AudioMute',         hl.dsp.exec_cmd('wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'),     { locked = true, repeating = true })
hl.bind('XF86AudioMicMute',      hl.dsp.exec_cmd('wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle'),   { locked = true, repeating = true })
hl.bind('XF86MonBrightnessUp',   hl.dsp.exec_cmd('brightnessctl -e4 -n2 set 5%+'),                  { locked = true, repeating = true })
hl.bind('XF86MonBrightnessDown', hl.dsp.exec_cmd('brightnessctl -e4 -n2 set 5%-'),                  { locked = true, repeating = true })

-- Player keys (bindl = locked only)
hl.bind('XF86AudioNext',  hl.dsp.exec_cmd('playerctl next'),       { locked = true })
hl.bind('XF86AudioPause', hl.dsp.exec_cmd('playerctl play-pause'), { locked = true })
hl.bind('XF86AudioPlay',  hl.dsp.exec_cmd('playerctl play-pause'), { locked = true })
hl.bind('XF86AudioPrev',  hl.dsp.exec_cmd('playerctl previous'),   { locked = true })


--------------------------------------------------------------------------------
-- Helper & Logic Functions (Runtime)
--------------------------------------------------------------------------------

function log(msg)
	local f = io.open('/tmp/hypr_debug.log', 'a')
	if f then f:write(msg .. '\n') f:close() end
end

function cycle_ws_on_monitor(dir)
	local focused
	for _, mon in ipairs(hl.get_monitors()) do
		if mon.focused then focused = mon; break end
	end
	if not focused then return end

	local workspaces = {}
	for _, ws in ipairs(hl.get_workspaces()) do
		if ws.monitor == focused.name then
			table.insert(workspaces, ws)
		end
	end
	table.sort(workspaces, function(a, b) return a.id < b.id end)

	local current_id = focused.active_workspace.id
	local idx
	for i, ws in ipairs(workspaces) do
		if ws.id == current_id then idx = i; break end
	end
	if not idx or #workspaces < 2 then return end

	local next_ws = workspaces[((idx - 1 + dir) % #workspaces) + 1]
	hl.dispatch(hl.dsp.focus({ workspace = next_ws.id }))
end


