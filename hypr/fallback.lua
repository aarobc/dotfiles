local mod = 'SUPER'
local function sc(...) return table.concat({...}, ' + ') end

local d = 'code:43'
local k = 'code:55'
local h = 'code:44'
local s = 'code:47'
local n = 'code:46'
local t = 'code:45'

-- hy3 is missing: dwindle is what we actually get, no matter what look.lua says
hl.config({ general = { layout = 'dwindle' } })

-- Focus
hl.bind(sc(mod, h), hl.dsp.focus({ direction = "left" }))
hl.bind(sc(mod, s), hl.dsp.focus({ direction = "right" }))
hl.bind(sc(mod, n), hl.dsp.focus({ direction = "up" }))
hl.bind(sc(mod, t), hl.dsp.focus({ direction = "down" }))

-- ── sway-style split arming ────────────────────────────────────────────────
-- mod+d arms a horizontal split (side by side), mod+k a vertical one
-- (stacked). Next window to land on the focused one - opened, or moved in
-- with mod+shift+<dir> - uses that orientation. Press again to disarm.
--
-- Two mechanisms, because dwindle has no permanent per-node split like sway:
--   * new windows      -> dwindle's own `layoutmsg preselect <dir>`
--   * moved-in windows -> `preselect` too, but movewindow overwrites it with
--     the movement direction whenever you move straight into your own split
--     partner (DwindleAlgorithm.cpp moveTargetInDirection), so the result is
--     measured afterwards and flipped with `togglesplit` when it came out
--     the wrong way.
--
-- Moving left/right toward a monitor edge with nothing in the way is a ladder,
-- like sway: first press promotes the window to a full-height column hugging
-- that edge, second press hands it to the next monitor. Up/down are left as
-- plain dwindle moves.

local armed -- 'h' | 'v' | nil
local TOL = 4

local function disarm()
	armed = nil
	hl.dispatch(hl.dsp.layout('preselect none'))
end

local function arm(kind)
	return function()
		if armed == kind then return disarm() end
		armed = kind
		hl.dispatch(hl.dsp.layout(kind == 'h' and 'preselect r' or 'preselect d'))
	end
end

local function ws_id(w)
	local ws = w and w.workspace
	if not ws then return nil end
	return (type(ws) == 'table' or type(ws) == 'userdata') and ws.id or ws
end

local function tiled_siblings(win)
	local out = {}
	for _, w in ipairs(hl.get_windows()) do
		if not w.floating and w.address ~= win.address and ws_id(w) == ws_id(win) then
			out[#out + 1] = w
		end
	end
	return out
end

-- nearest tiled window in `dir` that overlaps us on the other axis
local function neighbor(win, dir)
	local ax, ay, aw, ah = win.at.x, win.at.y, win.size.x, win.size.y
	local best, bestgap
	for _, w in ipairs(tiled_siblings(win)) do
		local bx, by, bw, bh = w.at.x, w.at.y, w.size.x, w.size.y
		local gap, overlap
		if dir == 'l' then
			gap, overlap = ax - (bx + bw), math.min(ay + ah, by + bh) - math.max(ay, by)
		elseif dir == 'r' then
			gap, overlap = bx - (ax + aw), math.min(ay + ah, by + bh) - math.max(ay, by)
		elseif dir == 'u' then
			gap, overlap = ay - (by + bh), math.min(ax + aw, bx + bw) - math.max(ax, bx)
		else
			gap, overlap = by - (ay + ah), math.min(ax + aw, bx + bw) - math.max(ax, bx)
		end
		if gap >= 0 and overlap > 0 and (not bestgap or gap < bestgap) then
			best, bestgap = w, gap
		end
	end
	return best
end

local function refresh(win)
	if not win then return nil end
	for _, w in ipairs(hl.get_windows()) do
		if w.address == win.address then return w end
	end
end

-- two leaves of one split share their full extent on one axis
local function orientation(a, b)
	local same_row = math.abs(a.at.y - b.at.y) < TOL and math.abs(a.size.y - b.size.y) < TOL
	local same_col = math.abs(a.at.x - b.at.x) < TOL and math.abs(a.size.x - b.size.x) < TOL
	if same_row and not same_col then return 'h' end
	if same_col and not same_row then return 'v' end
end

-- bounding box of everything tiled here; beats guessing at reserved areas
local function tiled_bounds(win)
	local x1, y1 = win.at.x, win.at.y
	local x2, y2 = win.at.x + win.size.x, win.at.y + win.size.y
	for _, w in ipairs(tiled_siblings(win)) do
		x1, y1 = math.min(x1, w.at.x), math.min(y1, w.at.y)
		x2, y2 = math.max(x2, w.at.x + w.size.x), math.max(y2, w.at.y + w.size.y)
	end
	return x1, y1, x2, y2
end

-- a column: as tall as everything tiled here
local function is_column(win)
	local _, y1, _, y2 = tiled_bounds(win)
	return math.abs(win.at.y - y1) < TOL and math.abs(win.at.y + win.size.y - y2) < TOL
end

local function at_edge(win, dir)
	local x1, _, x2, _ = tiled_bounds(win)
	if dir == 'l' then return math.abs(win.at.x - x1) < TOL end
	return math.abs(win.at.x + win.size.x - x2) < TOL
end

local function adjacent_monitor(win, dir)
	local m = win.monitor
	if not m then return nil end
	for _, o in ipairs(hl.get_monitors()) do
		if o.id ~= m.id then
			local overlaps_y = o.y < m.y + m.height and o.y + o.height > m.y
			if dir == 'l' and overlaps_y and o.x + o.width <= m.x then return o end
			if dir == 'r' and overlaps_y and o.x >= m.x + m.width then return o end
		end
	end
end

local dir_name = { l = 'left', r = 'right', u = 'up', d = 'down' }

-- lift the window out of its nested split into a root-level column hugging
-- `dir`'s edge: movetoroot, then fix the root's orientation and side
local function promote(win, dir)
	hl.dispatch(hl.dsp.layout('movetoroot'))

	local w = refresh(win)
	if w and not is_column(w) then
		hl.dispatch(hl.dsp.layout('togglesplit'))
		w = refresh(win)
	end
	if w and not at_edge(w, dir) then
		hl.dispatch(hl.dsp.layout('swapsplit'))
	end
end

local function move(dir)
	return function()
		local win = hl.get_active_window()
		local plain = hl.dsp.window.move({ direction = dir_name[dir] })

		if not win or win.floating then return hl.dispatch(plain) end

		local target = neighbor(win, dir)

		if not target and (dir == 'l' or dir == 'r') then
			-- nothing that way on this workspace
			if is_column(win) and at_edge(win, dir) then
				-- already owns the edge: hand it to the next monitor. dwindle's
				-- own fallback only fires when the focal point 1px past the
				-- window lands on another monitor, so target it by name instead
				local adj = adjacent_monitor(win, dir)
				if adj then
					hl.dispatch(hl.dsp.window.move({ monitor = adj.name, follow = true }))
				end
			else
				promote(win, dir)
			end
			return
		end

		local want = armed
		hl.dispatch(plain)

		if want then
			local moved, into = refresh(win), refresh(target)
			if moved and into and orientation(moved, into) ~= want then
				hl.dispatch(hl.dsp.layout('togglesplit'))
			end
			disarm()
		end
	end
end

hl.bind(sc(mod, d), arm('h'))
hl.bind(sc(mod, k), arm('v'))

-- opening a window consumes the preselect; keep our copy in sync
hl.on('window.open', function() if armed then disarm() end end)

-- Move window
hl.bind(sc(mod, 'SHIFT', h), move('l'))
hl.bind(sc(mod, 'SHIFT', s), move('r'))
hl.bind(sc(mod, 'SHIFT', n), move('u'))
hl.bind(sc(mod, 'SHIFT', t), move('d'))

-- Workspaces
for i = 1, 10 do
	local key = i % 10
	hl.bind(sc(mod, key),          hl.dsp.focus({ workspace = i }))
	hl.bind(sc(mod, 'SHIFT', key), hl.dsp.window.move({ workspace = i }))
end
