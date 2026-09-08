-- Random wallpaper.
--
-- Hyprland does not draw wallpapers itself, so hyprpaper still does the work.
-- What lives here is the picking: list the directory, choose an image, hand the
-- path to hyprpaper. hyprpaper is launched on demand and the apply is retried
-- until it answers, which covers the startup race without a poll loop.

local lfs = require("lfs")

local M = {}

M.dir = os.getenv("HOME") .. "/Pictures/wallpaper"

local extensions = {
	jpg = true, jpeg = true, png = true, webp = true, bmp = true,
}

-- Single-quote for /bin/sh; embedded quotes become '\'' .
local function shellquote(s)
	return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function notify(msg)
	hl.exec_cmd("notify-send -u critical 'Wallpaper' " .. shellquote(msg))
end

-- Hyprland reaps SIGCHLD itself, so io.popen's close status is always
-- nil/"No child processes". Read the exit code off stdout instead.
local function sh_ok(cmd)
	local p = io.popen(cmd .. " >/dev/null 2>&1; echo $?")
	if not p then return false end
	local out = p:read("a") or ""
	p:close()
	return tonumber(out:match("%d+")) == 0
end

local function is_dir(path)
	return lfs.attributes(path, "mode") == "directory"
end

-- "mode" follows symlinks, so a symlinked image still reads as a file.
local function images(dir)
	local found = {}
	for entry in lfs.dir(dir) do
		local ext = entry:match("%.([^.]+)$")
		if ext and extensions[ext:lower()] then
			local path = dir .. "/" .. entry
			if lfs.attributes(path, "mode") == "file" then
				found[#found + 1] = path
			end
		end
	end
	return found
end

local function apply(path)
	-- Empty monitor field = every output. hyprctl 0.56 speaks hyprpaper's
	-- binary protocol and offers only `wallpaper` and `listactive`; the image
	-- is loaded implicitly, there is no preload/unload to manage.
	return sh_ok("hyprctl hyprpaper wallpaper " .. shellquote("," .. path))
end

local function apply_with_retry(path, attempts)
	if apply(path) then return end

	if attempts <= 0 then
		notify("hyprpaper never came up")
		return
	end

	hl.timer(function() apply_with_retry(path, attempts - 1) end,
		{ timeout = 300, type = 'oneshot' })
end

function M.set_random(dir)
	dir = dir or M.dir

	-- lfs.dir raises on a missing directory rather than returning nil
	if not is_dir(dir) then
		notify("no such directory: " .. dir)
		return
	end

	local found = images(dir)
	if #found == 0 then
		notify("no images in " .. dir)
		return
	end

	local pick = found[math.random(#found)]

	-- First attempt doubles as the liveness probe: if hyprpaper is not up yet
	-- it fails, and only then do we spawn it. Checking for the socket file
	-- instead would false-positive on the stale socket a killed hyprpaper
	-- leaves behind.
	if apply(pick) then return end

	hl.exec_cmd("uwsm-app -- hyprpaper")
	apply_with_retry(pick, 20)
end

return M
