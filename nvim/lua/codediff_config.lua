-- codediff.nvim: VSCode-style side-by-side diffs with char-level highlights. :CodeDiff, :CodeDiff history
--
-- The diff view opens in its own tab, so the shared <Tab>/<S-Tab> window
-- cycling (vim/shared/mappings.vim) already moves between its panes, and
-- ]f/[f / ]c/[c are codediff's defaults for files/hunks. g? lists the rest.

local M = {}

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
  local ok, codediff = pcall(require, 'codediff')
  if not ok then
    return
  end

  codediff.setup {}

  -- :Diff [rev] -- diff the working tree against `rev`, defaulting to the
  -- repo's master/main branch.
  vim.api.nvim_create_user_command('Diff', function(opts)
    local base = opts.args ~= '' and opts.args or default_base()
    if not base then
      vim.notify('Diff: no master/main branch found; pass a revision', vim.log.levels.ERROR)
      return
    end

    vim.fn.system({ 'git', 'rev-parse', '--verify', '--quiet', base .. '^{commit}' })
    if vim.v.shell_error ~= 0 then
      vim.notify(('Diff: unknown revision %s'):format(base), vim.log.levels.ERROR)
      return
    end

    vim.cmd('CodeDiff ' .. vim.fn.fnameescape(base))
  end, {
    nargs = '?',
    desc = 'CodeDiff against master/main, or the given revision',
    complete = function(lead)
      return vim.tbl_filter(function(name)
        return vim.startswith(name, lead)
      end, branches())
    end,
  })
end

return M
