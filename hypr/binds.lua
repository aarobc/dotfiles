-- Keybindings
local mod = "SUPER"

-- Key codes
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

-- Helper to check for hy3 plugin
local hy3 = hl.plugin.hy3

-- Lock
hl.bind(mod .. " + " .. l, hl.dsp.exec_cmd("hyprlock"))

-- Core
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + SHIFT + " .. apos, hl.dsp.window.close())
hl.bind(mod .. " + SHIFT + M", hl.dsp.exit())
hl.bind(mod .. " + SHIFT + space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + " .. e, hl.dsp.exec_cmd(menu))
hl.bind(mod .. " + " .. u, hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

-- Layout (hy3)
if hy3 then
    hl.bind(mod .. " + " .. d, hy3.make_group("h"))
    hl.bind(mod .. " + " .. k, hy3.make_group("v"))
    hl.bind(mod .. " + A", hy3.change_focus("raise"))

    -- Focus (hy3)
    hl.bind(mod .. " + " .. h, hy3.move_focus("l"))
    hl.bind(mod .. " + " .. s, hy3.move_focus("r"))
    hl.bind(mod .. " + " .. n, hy3.move_focus("u"))
    hl.bind(mod .. " + " .. t, hy3.move_focus("d"))

    -- Move window (hy3)
    hl.bind(mod .. " + SHIFT + " .. h, hy3.move_window("l"))
    hl.bind(mod .. " + SHIFT + " .. s, hy3.move_window("r"))
    hl.bind(mod .. " + SHIFT + " .. n, hy3.move_window("u"))
    hl.bind(mod .. " + SHIFT + " .. t, hy3.move_window("d"))
else
    -- Fallback to standard dispatchers if hy3 is not loaded
    hl.bind(mod .. " + " .. h, hl.dsp.focus("l"))
    hl.bind(mod .. " + " .. s, hl.dsp.focus("r"))
    hl.bind(mod .. " + " .. n, hl.dsp.focus("u"))
    hl.bind(mod .. " + " .. t, hl.dsp.focus("d"))
end

-- Workspaces
for i = 1, 9 do
    hl.bind(mod .. " + " .. tostring(i), hl.dsp.focus({ workspace = tostring(i) }))
    if hy3 then
        hl.bind(mod .. " + SHIFT + " .. tostring(i), hy3.move_to_workspace(tostring(i)))
    else
        hl.bind(mod .. " + SHIFT + " .. tostring(i), hl.dsp.window.move({ workspace = tostring(i) }))
    end
end
hl.bind(mod .. " + 0", hl.dsp.focus({ workspace = "10" }))
if hy3 then
    hl.bind(mod .. " + SHIFT + 0", hy3.move_to_workspace("10"))
else
    hl.bind(mod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = "10" }))
end

-- Monitor movement
hl.bind(mod .. " + SHIFT + CONTROL + " .. h, hl.dsp.exec_cmd("hyprctl dispatch movecurrentworkspacetomonitor l"))
hl.bind(mod .. " + SHIFT + CONTROL + " .. s, hl.dsp.exec_cmd("hyprctl dispatch movecurrentworkspacetomonitor r"))

-- Mouse Binds
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Scroll
hl.bind(mod .. " + mouse_down", hl.dsp.exec_cmd("~/dotfiles/waybar/scroll.sh 0"))
hl.bind(mod .. " + mouse_up",   hl.dsp.exec_cmd("~/dotfiles/waybar/scroll.sh 1"))

-- Media Keys
local media_keys = {
    XF86AudioRaiseVolume  = "wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+",
    XF86AudioLowerVolume  = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-",
    XF86AudioMute         = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle",
    XF86AudioMicMute      = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle",
    XF86MonBrightnessUp   = "brightnessctl -e4 -n2 set 5%+",
    XF86MonBrightnessDown = "brightnessctl -e4 -n2 set 5%-",
    XF86AudioNext         = "playerctl next",
    XF86AudioPause        = "playerctl play-pause",
    XF86AudioPlay         = "playerctl play-pause",
    XF86AudioPrev         = "playerctl previous"
}

for key, cmd in pairs(media_keys) do
    local opts = { locked = true }
    if key:find("AudioRaise") or key:find("AudioLower") or key:find("MonBrightness") then
        opts.repeating = true
    end
    hl.bind(key, hl.dsp.exec_cmd(cmd), opts)
end
