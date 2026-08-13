-- ----------------------------------------------------------------------------
-- Plugins, managed by the built-in vim.pack (needs nvim 0.12+)
--
-- Missing plugins are cloned on startup. They live in
-- stdpath('data')/site/pack/core/opt/<name>
--
--   :lua vim.pack.update()             update everything, confirm in the diff buffer
--   :lua vim.pack.update({'ale'})      update one plugin
--   :lua vim.pack.del({'ale'})         delete a plugin (drop it from the list too)
--   :lua = vim.pack.get()              list what is installed
--
-- Nothing is pinned, so `add()` keeps whatever revision was cloned until an
-- explicit update. To pin, give the entry a version:
--   { src = 'https://github.com/user/repo', version = 'main' }
--   { src = 'https://github.com/user/repo', version = vim.version.range('1.*') }
-- ----------------------------------------------------------------------------

-- Order matters: dependencies first (plenary before telescope), and molokai
-- before the `colorscheme` line in the vimrc.
local repos = {
  'gregsexton/MatchTag',
  'scrooloose/nerdtree',
  'Raimondi/delimitMate',
  'wesQ3/vim-windowswap',
  'vim-scripts/Tabmerge',

  'vim-airline/vim-airline',
  'vim-airline/vim-airline-themes',

  'christoomey/vim-tmux-navigator',
  'kshenoy/vim-signature',
  'unblevable/quick-scope',
  'tpope/vim-fugitive',
  'tpope/vim-surround',
  'tpope/vim-repeat',
  'tpope/vim-obsession',
  'tommcdo/vim-fubitive',
  'nvim-lua/plenary.nvim',
  'nvim-telescope/telescope.nvim',
  'junegunn/vim-easy-align',

  'wellle/targets.vim',
  'lambdalisue/suda.vim',
  -- config data for the builtin LSP client; see lua/lsp.lua
  'neovim/nvim-lspconfig',
  'chrisbra/Colorizer',
  'lewis6991/gitsigns.nvim',

  -- Dropped: nvim ships these now
  -- 'dense-analysis/ale',    -> builtin LSP + vim.diagnostic (lua/lsp.lua)
  -- 'tomtom/tcomment_vim',   -> builtin gc/gcc/gbc operators (:h commenting)
  -- 'neoclide/jsonc.vim',    -> builtin jsonc filetype + syntax + ftplugin
  -- 'sheerun/vim-polyglot',  -> builtin syntax/ftplugin + treesitter
  -- 'tomasr/molokai',        -> builtin unokai colorscheme

  -- Commented out / disabled plugins (preserved for reference)
  -- 'pangloss/vim-javascript',
  -- 'maxmellon/vim-jsx-pretty',
  -- 'leafgarland/typescript-vim',
  -- 'StanAngeloff/php.vim',
  -- 'vim-scripts/phpfolding.vim',
  -- 'sirtaj/vim-openscad',
  -- 'klen/python-mode',
  -- 'tpope/vim-rhubarb',
  -- 'nathanaelkane/vim-indent-guides',
  -- 'nvim-treesitter/nvim-treesitter',
}

local specs = {}
for _, repo in ipairs(repos) do
  specs[#specs + 1] = { src = 'https://github.com/' .. repo }
end

vim.pack.add(specs)
