local mod = 'SUPER'
local function sc(...) return table.concat({...}, ' + ') end

local h = 'code:44'
local s = 'code:47'
local n = 'code:46'
local t = 'code:45'

-- Focus
hl.bind(sc(mod, h), hl.dsp.focus({ direction = "left" }))
hl.bind(sc(mod, s), hl.dsp.focus({ direction = "right" }))
hl.bind(sc(mod, n), hl.dsp.focus({ direction = "up" }))
hl.bind(sc(mod, t), hl.dsp.focus({ direction = "down" }))

-- Move window
hl.bind(sc(mod, 'SHIFT', h), hl.dsp.window.move({ direction = "left" }))
hl.bind(sc(mod, 'SHIFT', s), hl.dsp.window.move({ direction = "right" }))
hl.bind(sc(mod, 'SHIFT', n), hl.dsp.window.move({ direction = "up" }))
hl.bind(sc(mod, 'SHIFT', t), hl.dsp.window.move({ direction = "down" }))

-- Workspaces
for i = 1, 10 do
	local key = i % 10
	hl.bind(sc(mod, key),          hl.dsp.focus({ workspace = i }))
	hl.bind(sc(mod, 'SHIFT', key), hl.dsp.window.move({ workspace = i }))
end
