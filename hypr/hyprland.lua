require("env")
require("monitors")
require("input")

-- sway-emulation layout (custom hl.layout registered as 'lua:sway' in
-- ~/code/hy3-lua/layout.lua). Load before look.lua, which selects it.
package.path = package.path .. ';' .. os.getenv('HOME') .. '/code/hy3-lua/?.lua'
require("layout")

require("look")
require("rules")

require("binds")
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
