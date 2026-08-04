hl.config({
	plugin = {
		hy3 = {
			node_collapse_policy = 0,
			group_inset = 0,
			autotile = {
				ephemeral_groups = true,
				enable = false,
				trigger_width = -1,
				trigger_height = 0
			}
		}
	}
})

local mod = 'SUPER'
local function sc(...) return table.concat({...}, ' + ') end

local d = 'code:43'
local k = 'code:55'
local h = 'code:44'
local s = 'code:47'
local n = 'code:46'
local t = 'code:45'
local hy3 = hl.plugin.hy3

-- hy3 splits
hl.bind(sc(mod, d),   hy3.make_group('h'))
hl.bind(sc(mod, k),   hy3.make_group('v'))
hl.bind(sc(mod, 'A'), hy3.change_focus('raise'))

-- Focus (hy3)
hl.bind(sc(mod, h), hy3.move_focus('l'))
hl.bind(sc(mod, s), hy3.move_focus('r'))
hl.bind(sc(mod, n), hy3.move_focus('u'))
hl.bind(sc(mod, t), hy3.move_focus('d'))

-- Workspaces
for i = 1, 10 do
	local key = i % 10
	hl.bind(sc(mod, key),          hl.dsp.focus({ workspace = i }))
	hl.bind(sc(mod, 'SHIFT', key), hy3.move_to_workspace(i))
end

local function same_workspace(w1, w2)
	if not w1 or not w2 then return false end
	if w1.workspace == w2.workspace then return true end
	local t1 = type(w1.workspace)
	local t2 = type(w2.workspace)
	local id1 = (t1 == 'table' or t1 == 'userdata') and w1.workspace.id or w1.workspace
	local id2 = (t2 == 'table' or t2 == 'userdata') and w2.workspace.id or w2.workspace
	if id1 and id2 and id1 == id2 then return true end
	local name1 = (t1 == 'table' or t1 == 'userdata') and w1.workspace.name
	local name2 = (t2 == 'table' or t2 == 'userdata') and w2.workspace.name
	if name1 and name2 and name1 == name2 then return true end
	return false
end

local function get_adjacent_monitor(focused, dir)
	for _, mon in ipairs(hl.get_monitors()) do
		if (dir == 'r' and mon.x == focused.x + focused.width) or
		   (dir == 'l' and mon.x + mon.width == focused.x) then
			return mon
		end
	end
end

local function is_window_a_column(win)
	if not win or win.floating then return false end
	for _, w in ipairs(hl.get_windows()) do
		if w.address ~= win.address and not w.floating and same_workspace(w, win) then
			local is_left = w.at.x + w.size.x - 10 <= win.at.x
			local is_right = w.at.x >= win.at.x + win.size.x - 10
			if not (is_left or is_right) then
				return false
			end
		end
	end
	return true
end

local function is_window_at_extreme(win, dir)
	if type(win) == "string" and type(dir) == "table" then
		win, dir = dir, win
	end
	if not win or win.floating or (dir ~= "l" and dir ~= "r") then return false end
	if not is_window_a_column(win) then return false end
	for _, w in ipairs(hl.get_windows()) do
		if w.address ~= win.address and not w.floating and same_workspace(w, win) then
			if dir == "l" and w.at.x + w.size.x - 10 <= win.at.x then
				return false
			elseif dir == "r" and w.at.x >= win.at.x + win.size.x - 10 then
				return false
			end
		end
	end
	return true
end

local function move_window_h(dir, fallback)
	local win = hl.get_active_window()
	if not win then
		hl.dispatch(fallback)
		return
	end
	if is_window_at_extreme(win, dir) then
		local adj = get_adjacent_monitor(win.monitor, dir)
		if not adj then return end
		hl.dispatch(hy3.move_to_workspace(adj.active_workspace.name, {follow = true}))
		local target_dir = (dir == 'r') and 'l' or 'r'
		local op_dir = (dir == 'r') and 'r' or 'l'
		for i = 1, 10 do
			hl.dispatch(hy3.move_window(target_dir))
		end
		hl.dispatch(hy3.move_window(op_dir, {follow = true}))
		hl.dispatch(hl.dsp.window.move({ out_of_group = true }))
		return
	end
	hl.dispatch(fallback)
end

hl.bind(sc(mod, 'SHIFT', h), function() move_window_h('l', hy3.move_window('l')) end)
hl.bind(sc(mod, 'SHIFT', s), function() move_window_h('r', hy3.move_window('r')) end)
hl.bind(sc(mod, 'SHIFT', n), hy3.move_window('u'))
hl.bind(sc(mod, 'SHIFT', t), hy3.move_window('d'))
