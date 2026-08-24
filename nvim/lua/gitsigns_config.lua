-- gitsigns.nvim: diff markers in the sign column, hunk nav, staging.
-- Named gitsigns_config so it can't shadow the plugin's own `gitsigns` module.

local M = {}

function M.setup()
  local ok, gs = pcall(require, 'gitsigns')
  if not ok then
    return
  end

  gs.setup {
    -- per buffer, so these mappings only exist where git actually applies
    on_attach = function(buf)
      local function map(mode, lhs, rhs, opts)
        opts = vim.tbl_extend('force', { buffer = buf, silent = true }, opts or {})
        vim.keymap.set(mode, lhs, rhs, opts)
      end

      -- ]c and [c stay the builtin diff motions while in diff mode
      map('n', ']c', function()
        if vim.wo.diff then
          return ']c'
        end
        vim.schedule(function()
          gs.nav_hunk('next')
        end)
        return '<Ignore>'
      end, { expr = true, desc = 'next git hunk' })

      map('n', '[c', function()
        if vim.wo.diff then
          return '[c'
        end
        vim.schedule(function()
          gs.nav_hunk('prev')
        end)
        return '<Ignore>'
      end, { expr = true, desc = 'previous git hunk' })

      -- stage_hunk toggles, so the same key stages and unstages
      map('n', '<leader>hs', gs.stage_hunk, { desc = 'stage hunk' })
      map('n', '<leader>hr', gs.reset_hunk, { desc = 'reset hunk' })
      map('v', '<leader>hs', function()
        gs.stage_hunk { vim.fn.line('.'), vim.fn.line('v') }
      end, { desc = 'stage selected lines' })
      map('v', '<leader>hr', function()
        gs.reset_hunk { vim.fn.line('.'), vim.fn.line('v') }
      end, { desc = 'reset selected lines' })

      map('n', '<leader>hp', gs.preview_hunk, { desc = 'preview hunk' })
      map('n', '<leader>hb', function()
        gs.blame_line { full = true }
      end, { desc = 'blame line' })
      map('n', '<leader>hd', gs.diffthis, { desc = 'diff against index' })

      -- ih works as a text object: vih, dih, ...
      map({ 'o', 'x' }, 'ih', gs.select_hunk, { desc = 'git hunk' })
    end,
  }
end

return M
