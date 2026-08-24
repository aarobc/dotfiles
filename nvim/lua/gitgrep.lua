local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local make_entry = require('telescope.make_entry')
local sorters = require('telescope.sorters')
local conf = require('telescope.config').values

local M = {}

-- resolve the root of the worktree holding the current buffer. autochdir means
-- cwd tracks the buffer, and --show-toplevel returns the *linked* worktree's
-- root, so both pickers stay scoped to the worktree you are actually editing.
local function git_root()
  local name = vim.api.nvim_buf_get_name(0)
  local dir = name ~= '' and vim.fs.dirname(name) or ''
  -- buffer names are not always real paths: plugin buffers use URIs
  -- (fugitive://, NERDTree) and a brand new file can sit in a directory that
  -- does not exist yet. vim.system raises ENOENT on a bad cwd, so fall back.
  if dir == '' or vim.fn.isdirectory(dir) == 0 then
    dir = vim.fn.getcwd()
  end
  local ok, res = pcall(function()
    return vim.system({ 'git', 'rev-parse', '--show-toplevel' },
      { cwd = dir, text = true }):wait()
  end)
  if not ok or res.code ~= 0 then
    return nil
  end
  return vim.trim(res.stdout)
end

-- grep the working tree as git sees it: tracked files plus untracked ones,
-- minus anything .gitignore excludes. git grep -n --column emits
-- file:line:col:text, which is telescope's vimgrep format. git grep has no
-- --smart-case, so fold case only when the query is all lowercase.
function M.repo()
  local root = git_root()
  if not root then
    vim.notify('gitgrep: not inside a git worktree', vim.log.levels.WARN)
    return
  end
  local opts = { cwd = root }
  pickers.new(opts, {
    prompt_title = 'Grep Repo',
    finder = finders.new_job(function(prompt)
      if not prompt or prompt == '' then
        return nil
      end
      local cmd = { 'git', 'grep', '--no-color', '--line-number', '--column',
                    '-I', '--perl-regexp', '--untracked' }
      if not prompt:match('%u') then
        table.insert(cmd, '--ignore-case')
      end
      vim.list_extend(cmd, { '-e', prompt, '--', ':/' })
      return cmd
    end, make_entry.gen_from_vimgrep(opts), nil, root),
    previewer = conf.grep_previewer(opts),
    sorter = sorters.highlighter_only(opts),
    push_cursor_on_edit = true,
  }):find()
end

-- grep every file on disk under the worktree, gitignored and hidden included.
-- .git/ dirs are pruned or you end up grepping loose objects and logs. the glob
-- is bare '.git' on purpose: a pattern containing a slash anchors to the search
-- root, which would miss nested repos (vendored checkouts and friends).
-- telescope's default vimgrep_arguments already pass --smart-case.
function M.everything()
  require('telescope.builtin').live_grep {
    cwd = git_root() or vim.fn.getcwd(),
    prompt_title = 'Grep Everything (incl. ignored)',
    additional_args = { '--no-ignore', '--hidden', '--glob=!.git' },
  }
end

return M
