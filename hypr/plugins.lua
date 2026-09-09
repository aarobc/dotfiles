-- Plugins
--
-- hyprpm builds each plugin to /var/cache/hyprpm/<user>/<repo>/<filename>.so and
-- records it in a state.toml next to it. Registering the .so here rather than
-- running `hyprpm reload -n` from autostart lets Hyprland own the load:
-- handlePluginLoads() runs immediately after this config is evaluated and reloads
-- the config whenever the registered plugin set changes. So the first pass always
-- sees an unloaded plugin, and the reload it triggers gets a pass where
-- hl.get_loaded_plugins() reports it -- which is what binds.lua branches on.
--
-- Registering the same path twice is a no-op (updateConfigPlugins compares against
-- the previous list), so this does not reload in a loop.

local M = {}

local hyprpm_dir = '/var/cache/hyprpm/' .. (os.getenv('USER') or '')

-- Returns the .so path if hyprpm has actually built the plugin, else nil.
local function built(repo, filename)
	local path = hyprpm_dir .. '/' .. repo .. '/' .. filename
	local f = io.open(path, 'r')
	if not f then return nil end
	f:close()
	return path
end

M.hy3_so = built('hy3', 'hy3.so')
if M.hy3_so then
	hl.plugin.load(M.hy3_so)
end

return M
