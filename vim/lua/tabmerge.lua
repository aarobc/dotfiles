-- :Tabmerge [tabnr | $] [top|bottom|left|right] -- merge another tab's windows into this one, then close it.
-- No tabnr: the tab right, else left. Location defaults to top. Replaces vim-scripts/Tabmerge (2008).

local M = {}

-- prefixes are unique on the first letter, so a plain prefix match is enough
local PLACES = {
  top = 'topleft',
  bottom = 'botright',
  left = 'leftabove vertical',
  right = 'rightbelow vertical',
}

-- these insert ahead of the previous window, so feed them in reverse to keep source order
local PREPENDS = {
  ['topleft'] = true,
  ['leftabove vertical'] = true,
}

local function err(msg)
  vim.notify('Tabmerge: ' .. msg, vim.log.levels.ERROR)
end

-- nothing to merge is not misuse, and raising would abort the calling mapping
local function warn(msg)
  vim.notify('Tabmerge: ' .. msg, vim.log.levels.WARN)
end

local function resolve_place(arg)
  local want = arg:lower()
  for name, cmd in pairs(PLACES) do
    if name:sub(1, #want) == want then
      return cmd
    end
  end
end

---@param tabnr string|number|nil tab to merge in, or '$' for the last one
---@param where string|nil top|bottom|left|right
function M.merge(tabnr, where)
  local place = PLACES.top
  if where then
    place = resolve_place(where)
    if not place then
      return err('invalid location: ' .. where)
    end
  end

  local cur = vim.fn.tabpagenr()
  local last = vim.fn.tabpagenr('$')

  local target
  if tabnr == nil then
    if cur < last then
      target = cur + 1
    elseif cur > 1 then
      target = cur - 1
    else
      return warn('already only one tab')
    end
  elseif tabnr == '$' then
    target = last
  else
    target = tonumber(tabnr)
    if not target then
      return err('not a tab number: ' .. tostring(tabnr))
    end
  end

  if target == cur then
    return err("can't merge with the current tab")
  elseif target < 1 or target > last then
    return err('no such tab number: ' .. target)
  end

  local bufs = vim.fn.tabpagebuflist(target)
  if PREPENDS[place] then
    bufs = vim.fn.reverse(bufs)
  end

  -- sbuffer must split rather than reuse an existing window
  local save_switchbuf = vim.o.switchbuf
  vim.o.switchbuf = ''
  local ok, e = pcall(function()
    for _, buf in ipairs(bufs) do
      vim.cmd(place .. ' sbuffer ' .. buf)
    end
    vim.cmd('tabclose ' .. target)
  end)
  vim.o.switchbuf = save_switchbuf

  if not ok then
    err(tostring(e))
  end
end

function M.setup()
  vim.api.nvim_create_user_command('Tabmerge', function(opts)
    local tabnr, where
    for _, arg in ipairs(opts.fargs) do
      if arg == '$' or arg:match('^%d+$') then
        tabnr = arg
      else
        where = arg
      end
    end
    M.merge(tabnr, where)
  end, { nargs = '*', desc = 'Merge another tab page into this one' })
end

return M
