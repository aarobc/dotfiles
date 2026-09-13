require("env")
require("monitors")
require("input")

-- hy3 layout (HYprland + i3): published LuaRocks package, installed in the
-- local tree (`luarocks --local install hy3`). Load before look.lua, which
-- selects it.
package.path = package.path .. ';' .. os.getenv('HOME') .. '/.luarocks/share/lua/5.4/?.lua'
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
