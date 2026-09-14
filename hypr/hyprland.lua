require("env")
require("monitors")
require("input")

-- hy3 layout (HYprland + i3): loaded from the local working tree
-- (~/code/hy3-lua/src/hy3.lua) so edits can be validated in place. Load
-- before look.lua, which selects it.
package.path = package.path .. ';' .. os.getenv('HOME') .. '/code/hy3-lua/src/?.lua'
require("hy3")

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
