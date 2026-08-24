-- telescope: ctrlp replacement, worktree-safe. Named telescope_config so it
-- cannot shadow the plugin's own `telescope` module.
local telescope = require('telescope')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')

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

function M.setup()
  telescope.setup {
    defaults = {
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
