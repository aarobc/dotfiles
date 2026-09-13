-- diffview-plus.nvim: tabbed diff view + file history. :DiffviewOpen, :DiffviewFileHistory

local M = {}

---Windows making up the current view, in cycle order: file panel first (when
---open), then the diff windows in layout order.
---@return integer[]
local function view_wins()
  local ok, lib = pcall(require, 'diffview.lib')
  if not ok then
    return {}
  end

  local view = lib.get_current_view()
  if not view then
    return {}
  end

  local wins = {}

  if view.panel and view.panel:is_open() then
    table.insert(wins, view.panel.winid)
  end

  for _, win in ipairs(view.cur_layout and view.cur_layout.windows or {}) do
    if win:is_valid() then
      table.insert(wins, win.id)
    end
  end

  return wins
end

---@param dir integer 1 for next pane, -1 for previous.
local function cycle_panes(dir)
  return function()
    local wins = view_wins()
    if #wins == 0 then
      return
    end

    local cur = vim.api.nvim_get_current_win()
    local idx

    for i, winid in ipairs(wins) do
      if winid == cur then
        idx = i
        break
      end
    end

    -- Cursor is somewhere outside the tracked windows (e.g. a floating
    -- overlay): fall back to the first pane rather than wrapping from nothing.
    local target = idx and wins[(idx - 1 + dir) % #wins + 1] or wins[1]
    vim.api.nvim_set_current_win(target)
  end
end

---Base revision for `:Diff` with no argument: the repo's long-lived branch,
---whichever of the usual names actually exists here.
---@return string?
local function default_base()
  for _, name in ipairs({ 'master', 'main' }) do
    vim.fn.system({ 'git', 'rev-parse', '--verify', '--quiet', name })
    if vim.v.shell_error == 0 then
      return name
    end
  end
end

---@return string[]
local function branches()
  local out = vim.fn.systemlist({ 'git', 'branch', '--all', '--format=%(refname:short)' })
  if vim.v.shell_error ~= 0 then
    return {}
  end
  return out
end

function M.setup()
  local ok, diffview = pcall(require, 'diffview')
  if not ok then
    return
  end

  local actions = require('diffview.actions')

  -- <tab>/<s-tab> cycle panes instead of files; file navigation moves to
  -- ]f/[f, matching the existing ]F/[F first/last-entry maps.
  local nav = {
    { 'n', '<tab>',    cycle_panes(1),             { desc = 'Focus the next diffview pane' } },
    { 'n', '<s-tab>',  cycle_panes(-1),            { desc = 'Focus the previous diffview pane' } },
    { 'n', ']f',       actions.select_next_entry,  { desc = 'Open the diff for the next file' } },
    { 'n', '[f',       actions.select_prev_entry,  { desc = 'Open the diff for the previous file' } },
  }

  diffview.setup {
    keymaps = {
      view = nav,
      file_panel = nav,
      file_history_panel = nav,
    },
  }

  -- :Diff [rev] -- diff the working tree against `rev`, defaulting to the
  -- repo's master/main branch.
  vim.api.nvim_create_user_command('Diff', function(opts)
    local base = opts.args ~= '' and opts.args or default_base()
    if not base then
      vim.notify('Diff: no master/main branch found; pass a revision', vim.log.levels.ERROR)
      return
    end

    -- Check the rev up front: Diffview reports a bad one with a traceback.
    vim.fn.system({ 'git', 'rev-parse', '--verify', '--quiet', base .. '^{commit}' })
    if vim.v.shell_error ~= 0 then
      vim.notify(('Diff: unknown revision %s'):format(base), vim.log.levels.ERROR)
      return
    end

    vim.cmd('DiffviewOpen ' .. vim.fn.fnameescape(base))
  end, {
    nargs = '?',
    desc = 'Diffview against master/main, or the given revision',
    complete = function(lead)
      return vim.tbl_filter(function(name)
        return vim.startswith(name, lead)
      end, branches())
    end,
  })
end

return M
