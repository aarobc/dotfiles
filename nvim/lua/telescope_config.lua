-- telescope: ctrlp replacement, worktree-safe. Named telescope_config so it
-- cannot shadow the plugin's own `telescope` module.
local telescope = require('telescope')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local sorters = require('telescope.sorters')
local utils = require('telescope.utils')

local M = {}

local function create_new_file(prompt_bufnr)
  local prompt = action_state.get_current_line()
  actions.close(prompt_bufnr)
  vim.cmd('edit ' .. vim.fn.fnameescape(prompt))
end

local function clear_prompt(prompt_bufnr)
  action_state.get_current_picker(prompt_bufnr):reset_prompt()
end

-- git_files skips ignored files but blows up outside a worktree; fall back there
local function project_files()
  local ok = pcall(require('telescope.builtin').git_files, { show_untracked = true })
  if not ok then
    require('telescope.builtin').find_files()
  end
end

local function is_test_path(path)
  return ('/' .. path):find('/tests/') ~= nil
end

-- PhpStorm-style test marking: paths under a tests/ directory get a green
-- background. Re-set on ColorScheme since a scheme switch clears custom groups.
local function set_test_hl()
  vim.api.nvim_set_hl(0, 'TelescopeTestFile', { bg = '#1e3a24' })
end

-- path_display as a function replaces telescope's default formatting, so run
-- the default (cwd-relative) first, then style the result.
local function path_display(opts, path)
  local display = utils.transform_path(vim.tbl_extend('force', opts, { path_display = {} }), path)
  if is_test_path(display) then
    return display, { { { 0, #display }, 'TelescopeTestFile' } }
  end
  return display
end

-- fzy scores land in (0, 1], lower is better. Pushing test files up by 1 sinks
-- every one of them below every non-test match, still ranked among themselves.
local function file_sorter(opts)
  local sorter = sorters.get_fzy_sorter(opts)
  local score = sorter.scoring_function
  sorter.scoring_function = function(self, prompt, line, ...)
    local s = score(self, prompt, line, ...)
    if s >= 0 and is_test_path(line) then
      return s + 1
    end
    return s
  end
  return sorter
end

-- Results title tracks the selected entry's path, so a name truncated in the
-- list can still be read in full. telescope has no hook for selection changes,
-- so wrap set_selection, which every move goes through. Entries without a path
-- (help tags, etc) fall back to the picker's own title. Paths are capped at 80%
-- of the frame and cut from the left: the filename end is the part worth
-- keeping. Anything wider gets cut from the right by plenary's border instead.
local function update_results_title(picker)
  if not picker.results_title or not picker.results_border then
    return
  end
  local entry = picker._selection_entry
  local path = entry and (entry.path or entry.filename)
  local title = picker.results_title
  if path then
    title = utils.transform_path({ cwd = picker.cwd, path_display = {} }, path)
    if vim.api.nvim_win_is_valid(picker.results_win) then
      local max = math.floor(vim.api.nvim_win_get_width(picker.results_win) * 0.8)
      title = require('plenary.strings').truncate(title, max, nil, -1)
    end
  end
  picker.results_border:change_title(title)
end

-- set_selection covers moves; recalculate_layout covers resizes, which redraw
-- the border with the old title, sized for the old width.
local function track_selection_in_results_title()
  local Picker = require('telescope.pickers')._Picker
  for _, method in ipairs({ 'set_selection', 'recalculate_layout' }) do
    local orig = Picker[method]
    Picker[method] = function(self, ...)
      orig(self, ...)
      update_results_title(self)
    end
  end
end

function M.setup()
  track_selection_in_results_title()
  set_test_hl()
  vim.api.nvim_create_autocmd('ColorScheme', { callback = set_test_hl })

  telescope.setup {
    defaults = {
      path_display = path_display,
      file_sorter = file_sorter,
      layout_config = {
        width = 0.93,
      },
      mappings = {
        i = {
          ["<C-t>"] = actions.select_tab,
          ["<C-n>"] = actions.move_selection_previous,
          ["<C-f>"] = create_new_file,
          ["<C-g>"] = clear_prompt,
          ["<C-b>"] = actions.cycle_history_prev,
        },
      },
    },
  }

  vim.keymap.set('n', '<C-p>', project_files, { silent = true })
  vim.keymap.set('n', '<C-b>', '<cmd>Telescope buffers<CR>', { silent = true })
end

return M
