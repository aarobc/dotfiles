-- Hyprland Lua Configuration
-- Entry point

-- Shared modules
require("env")
require("monitors")
require("input")
require("look")
require("rules")
require("binds")
require("plugins")
require("autostart")

-- Per-machine config: load every *.lua in custom/
local custom_dir = os.getenv("HOME") .. "/.config/hypr/custom"
local p = io.popen('ls "' .. custom_dir .. '"/*.lua 2>/dev/null')
if p then
	for path in p:lines() do
		dofile(path)
	end
	p:close()
end
