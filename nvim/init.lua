-- Neovim entry point.
--
-- Editor-agnostic settings, mappings, autocommands and commands live in the vim
-- backup config next door (../vim/shared, symlinked to ~/.config/vim/shared) and
-- are sourced below, so there is one source of truth for both editors. Only
-- things that need neovim or a plugin belong in this file and in lua/.
--
-- Assumes a current neovim; nothing here is guarded on version.

--------------------------------------------------------------------[Plugins]---
-- managed by the built-in vim.pack, which needs nvim 0.12+; see lua/plugins.lua
require('plugins')
require('lsp')
-- own replacements for dropped plugins, and plugin config; see lua/
require('tabmerge').setup()
require('matchtag').setup()
require('pairs').setup()
require('gitsigns_config').setup()
require('diffview_config').setup()
require('telescope_config').setup()
require('filerefs') -- :FileReferences; the <leader>u mapping is down with the others

---------------------------------------------------------------------[Shared]---
-- ~/.config/vim, the sibling of stdpath('config'). Missing is not fatal: nvim
-- still starts, it just starts bare.
local shared = vim.fs.normalize(vim.fn.stdpath('config') .. '/../vim/shared')

if vim.uv.fs_stat(shared) then
  -- order matters: options.vim sets mapleader, which mappings.vim reads, and
  -- creates the 'vimrc' autocmd group that autocmds.vim hangs off
  for _, file in ipairs({ 'options.vim', 'mappings.vim', 'autocmds.vim', 'commands.vim' }) do
    vim.cmd.source(vim.fn.fnameescape(shared .. '/' .. file))
  end
else
  vim.api.nvim_echo({ { 'shared vim config not found at ' .. shared, 'WarningMsg' } }, true, {})
end

----------------------------------------------------------------[Neovim only]---
-- monokai-derived colorscheme shipped with nvim (replaces tomasr/molokai)
vim.cmd('silent! colorscheme unokai')

-- php gets the JetBrains look (jb.nvim). A colorscheme is global, not per window,
-- so this follows whichever real file buffer has focus; plugin windows (nerdtree,
-- telescope, quickfix) have a buftype and leave the current scheme alone.
--
-- jb.nvim's after/queries/php/highlights.scm is on the runtimepath for every php
-- treesitter highlight (telescope previews too), but the custom predicates it uses
-- are only registered when the jb module loads. Load it up front, or highlighting
-- php under unokai errors with "No handler for php-template-language?".
pcall(require, 'jb')
vim.api.nvim_create_autocmd({ 'BufEnter', 'FileType' }, {
  group = vim.api.nvim_create_augroup('php_colorscheme', {}),
  callback = function(args)
    if args.buf ~= vim.api.nvim_get_current_buf() or vim.bo[args.buf].buftype ~= '' then return end
    -- bufload() and friends run autocmds in a hidden 'autocmd' window; not a real focus change
    if vim.fn.win_gettype() ~= '' then return end
    local php = vim.bo[args.buf].filetype == 'php'
    -- jb's php support is treesitter-based; the parser is already in lua/ts_parsers.lua
    if php then pcall(vim.treesitter.start, args.buf) end
    local want = php and 'jb' or 'unokai'
    if vim.g.colors_name ~= want then vim.cmd('silent! colorscheme ' .. want) end
  end,
})

-- powerline/airline stuffs
vim.g.airline_powerline_fonts = 1
vim.g.airline_theme = 'murmur'
-- vim.g.airline_theme = 'powerlineish' / 'molokai' / 'luna'
-- Enable the list of buffers, showing just the filename
-- vim.g['airline#extensions#tabline#enabled'] = 1
-- vim.g['airline#extensions#tabline#fnamemod'] = ':t'

-- suda.vim save as root
vim.g.suda_smart_edit = 1

-- vim-javascript syntax plugin highlighting enable
vim.g.javascript_enable_domhtmlcss = 1
-- to prevent annoying behavior of the folding plugin
vim.g.DisableAutoPHPFolding = 1

-- eslint diagnostics come from the builtin LSP client now; see lua/lsp.lua
-- fixes are manual only: :EslintFixAll

-- autopairs and the <CR>/<Space> brace expansion inherited from delimitMate: lua/pairs.lua

------------------------------------------------------------------[Mappings]---
-- Plugin-backed keys. The plain-vim config binds the same keys to builtin
-- stand-ins; keep the two in step. Everything plugin-free is in shared/mappings.vim.
local map = vim.keymap.set

-- nerdTree
map('n', '<C-f>', '<Cmd>NERDTree<CR>', { silent = true })

-- merge tabs into single page (lua/tabmerge.lua)
map('n', '<C-w>m', '<Cmd>Tabmerge<CR>', { silent = true })

-- Start interactive EasyAlign in visual mode (e.g. vipga) or for a motion (e.g. gaip)
map('x', 'ga', '<Plug>(EasyAlign)', {})
map('n', 'ga', '<Plug>(EasyAlign)', {})
-- vim.g.easy_align_ignore_groups = { 'string' }

-- swap two windows' buffers: yank one, put it elsewhere; ww does both in turn
map('n', '<leader>yw', function() require('windowswap').mark() end, { silent = true })
map('n', '<leader>pw', function() require('windowswap').swap() end, { silent = true })
map('n', '<leader>ww', function() require('windowswap').easy() end, { silent = true })

-- grep repo contents, smart case (lua/gitgrep.lua)
-- filter paths with trailing globs (`handleFoo *.ini`, `handleFoo *.{ts,tsx}`, `handleFoo !*.ini`)
-- or, for bare extensions, after a ` -- ` separator: `handleFoo -- lua vim`, `handleFoo -- !test`
map('n', '<leader>g', function() require('gitgrep').repo() end, { silent = true })
map('n', '<leader>f', function() require('gitgrep').everything() end, { silent = true })

-- who imports this file? asks the language server, not grep; see lua/filerefs.lua
map('n', '<leader>u', function() require('filerefs').find() end, { silent = true, desc = 'files referencing this file' })
-- the per-symbol version of that -- gd/grr/grc/gri/grt/gO into telescope -- is buffer-local, in lua/lsp.lua

-----------------------------------------------------------------[Reference]---
-- tabm <number> moves tab to that location, e.g. `tabm 0` moves it to first
-- move existing window into new tab: :tabedit %
--
-- let @a = ':s/row\['\(\w*\)'\]/row->\1/g'
--
-- freedom in visual mode: :set virtualedit=all, then use Afoo to insert columns
-- toggle color codes (Colorizer): :ColorToggle
-- look into: https://github.com/chrisbra/vim_dotfiles/blob/master/plugin/CustomFoldText.vim
