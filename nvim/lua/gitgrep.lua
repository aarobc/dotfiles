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

-- both pickers accept a path filter, either explicitly after a ` -- `
-- separator or as bare trailing globs:
--   handleFoo -- lua vim        only *.lua and *.vim
--   handleFoo -- !test          everything except *.test
--   handleFoo -- src/* *.tsx    globs pass through untouched
--   handleFoo *.ini             same as `handleFoo -- ini`
-- after ` -- ` a bare word is read as an extension (lua -> *.lua); anything
-- containing a dot, slash or star is used verbatim; a leading ! excludes.
-- returns the pattern plus a list of { glob, exclude } entries.
-- one prompt word -> zero or more { glob, exclude } entries. brace groups are
-- expanded here rather than handed down: rg understands `*.{ts,tsx}` but git
-- pathspecs do not, and git fails silently (zero matches, no error).
local function parse_glob(word)
  local bang, body = word:match('^(!?)(.*)$')
  if body == '' then
    return {}
  end
  if not body:find('[%*%./]') then
    body = '*.' .. body
  end
  local pre, alts, post = body:match('^(.-){([^{}]*)}(.*)$')
  local bodies = { body }
  if pre then
    bodies = {}
    for alt in (alts .. ','):gmatch('([^,]*),') do
      if alt ~= '' then
        bodies[#bodies + 1] = pre .. alt .. post
      end
    end
  end
  local out = {}
  for _, b in ipairs(bodies) do
    out[#out + 1] = { glob = b, exclude = bang == '!' }
  end
  return out
end

-- without a ` -- ` separator only unmistakable globs are peeled off the end:
-- a `*.ext` / `*.{a,b}` shape, optionally negated. that keeps a query like
-- `foo bar` or an escaped `\*\.ini` whole, since neither matches.
local function looks_like_glob(word)
  return word:match('^!?%*%.[%w_%-]+$') ~= nil
      or word:match('^!?%*%.{[%w_%-,]+}$') ~= nil
end

local function split_filter(prompt)
  local pattern, filter = prompt:match('^(.-)%s+%-%-%s+(.+)$')
  if pattern and pattern ~= '' then
    local globs = {}
    for word in filter:gmatch('%S+') do
      vim.list_extend(globs, parse_glob(word))
    end
    return pattern, globs
  end

  -- peel trailing bare globs, right to left, but never the whole prompt.
  -- sliced off the string rather than a word list so whitespace inside the
  -- pattern survives -- `foo  bar` is a different regex from `foo bar`.
  local rest, globs = prompt, {}
  while true do
    local head, last = rest:match('^(.-)%s+(%S+)$')
    if not head or head:match('^%s*$') or not looks_like_glob(last) then
      break
    end
    local parsed = parse_glob(last)
    for i = #parsed, 1, -1 do
      table.insert(globs, 1, parsed[i])
    end
    rest = head
  end
  if #globs == 0 then
    return prompt, {}
  end
  return rest, globs
end

-- the filter syntax is easy to forget, so both pickers carry a one-line
-- reminder on the results border and a fuller card on <M-h>. <C-h> is not used
-- on purpose: plenty of terminals still send it as <BS>.
local HINT = 'filter:  *.ini  *.{ts,tsx}  !*.ini  -- ini vim   (M-h)'

local HELP = {
  ' path filter -- trailing globs, or a ` -- ` separator ',
  '',
  '   back *.ini           only *.ini',
  '   back *.{ini,conf}    either extension',
  '   back !*.ini          all but *.ini',
  '   back src/* *.tsx     globs used verbatim',
  '   back -- ini vim      bare words are extensions here',
  '   back -- !test        exclude works after -- too',
  '',
  ' a bare trailing glob must look like *.ext or *.{a,b};',
  ' anything else stays part of the regex.',
}

local help_win

local function close_help()
  if help_win and vim.api.nvim_win_is_valid(help_win) then
    vim.api.nvim_win_close(help_win, true)
  end
  help_win = nil
end

local function toggle_help(prompt_bufnr)
  if help_win and vim.api.nvim_win_is_valid(help_win) then
    return close_help()
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, HELP)
  vim.bo[buf].modifiable = false
  local width = 0
  for _, line in ipairs(HELP) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  -- anchored bottom-right so it never covers the prompt, and unfocusable so
  -- the picker keeps the cursor and keeps filtering while it is up
  help_win = vim.api.nvim_open_win(buf, false, {
    relative = 'editor',
    anchor = 'SE',
    row = vim.o.lines - 2,
    col = vim.o.columns,
    width = width + 1,
    height = #HELP,
    style = 'minimal',
    border = 'rounded',
    focusable = false,
    noautocmd = true,
  })
  -- closing the picker does not run picker mappings, so hang the teardown off
  -- the prompt buffer instead
  vim.api.nvim_create_autocmd({ 'BufWipeout', 'BufHidden' }, {
    buffer = prompt_bufnr,
    once = true,
    callback = close_help,
  })
end

local function attach_help(_, map)
  map({ 'i', 'n' }, '<M-h>', toggle_help)
  return true
end

-- git pathspecs. (top) anchors to the worktree root so the filter does not
-- depend on cwd; no (glob) magic on purpose -- plain wildmatch lets `*` cross
-- slashes, so `*.lua` already means "at any depth".
local function git_pathspecs(globs)
  if #globs == 0 then
    return { ':/' }
  end
  local specs, any_include = {}, false
  for _, g in ipairs(globs) do
    if g.exclude then
      specs[#specs + 1] = ':(exclude,top)' .. g.glob
    else
      specs[#specs + 1] = ':(top)' .. g.glob
      any_include = true
    end
  end
  -- an exclude-only pathspec list matches nothing; seed it with the whole tree
  if not any_include then
    table.insert(specs, 1, ':/')
  end
  return specs
end

-- rg globs. a glob with no slash matches by basename at any depth, which is
-- what a bare `*.lua` should mean here.
local function rg_globs(globs)
  local args = {}
  for _, g in ipairs(globs) do
    args[#args + 1] = '--glob=' .. (g.exclude and '!' or '') .. g.glob
  end
  return args
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
      local pattern, globs = split_filter(prompt)
      if pattern == '' then
        return nil
      end
      local cmd = { 'git', 'grep', '--no-color', '--line-number', '--column',
                    '-I', '--perl-regexp', '--untracked' }
      if not pattern:match('%u') then
        table.insert(cmd, '--ignore-case')
      end
      vim.list_extend(cmd, { '-e', pattern, '--' })
      vim.list_extend(cmd, git_pathspecs(globs))
      return cmd
    end, make_entry.gen_from_vimgrep(opts), nil, root),
    previewer = conf.grep_previewer(opts),
    sorter = sorters.highlighter_only(opts),
    results_title = HINT,
    attach_mappings = attach_help,
    push_cursor_on_edit = true,
  }):find()
end

-- grep every file on disk under the worktree, gitignored and hidden included.
-- .git/ dirs are pruned or you end up grepping loose objects and logs. the glob
-- is bare '.git' on purpose: a pattern containing a slash anchors to the search
-- root, which would miss nested repos (vendored checkouts and friends).
-- telescope's default vimgrep_arguments already pass --smart-case. this is
-- builtin live_grep re-rolled by hand: live_grep hands the entire prompt to rg
-- as one pattern, with no room for the ` -- glob` filter.
function M.everything()
  local root = git_root() or vim.fn.getcwd()
  local opts = { cwd = root }
  local base = vim.list_extend(vim.deepcopy(conf.vimgrep_arguments),
    { '--no-ignore', '--hidden', '--glob=!.git' })
  pickers.new(opts, {
    prompt_title = 'Grep Everything (incl. ignored)',
    finder = finders.new_job(function(prompt)
      if not prompt or prompt == '' then
        return nil
      end
      local pattern, globs = split_filter(prompt)
      if pattern == '' then
        return nil
      end
      local cmd = vim.deepcopy(base)
      vim.list_extend(cmd, rg_globs(globs))
      vim.list_extend(cmd, { '--', pattern })
      return cmd
    end, make_entry.gen_from_vimgrep(opts), nil, root),
    previewer = conf.grep_previewer(opts),
    sorter = sorters.highlighter_only(opts),
    results_title = HINT,
    attach_mappings = function(_, map)
      map('i', '<c-space>', require('telescope.actions').to_fuzzy_refine)
      map({ 'i', 'n' }, '<M-h>', toggle_help)
      return true
    end,
    push_cursor_on_edit = true,
  }):find()
end

return M
