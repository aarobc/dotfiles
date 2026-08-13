-- Plugins, managed by the built-in vim.pack (nvim 0.12+). Missing ones are cloned on startup, into
-- stdpath('data')/site/pack/core/opt/<name>. Unversioned entries keep whatever revision was cloned until an update.
--
--   :lua vim.pack.update()             update everything, confirm in the diff buffer
--   :lua vim.pack.update({'ale'})      update one plugin
--   :lua vim.pack.del({'ale'})         delete a plugin (drop it from the list too)
--   :lua = vim.pack.get()              list what is installed

-- Order matters: dependencies first, so plenary before telescope.
local repos = {
  'scrooloose/nerdtree',
  'echasnovski/mini.pairs',

  'vim-airline/vim-airline',
  'vim-airline/vim-airline-themes',

  'christoomey/vim-tmux-navigator',
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

  -- parsers for lua/matchtag.lua, installed by `make parsers`. Pinned to main; master is the legacy branch.
  { 'nvim-treesitter/nvim-treesitter', version = 'main' },

  -- Dropped: nvim ships these now
  -- 'dense-analysis/ale',    -> builtin LSP + vim.diagnostic (lua/lsp.lua)
  -- 'tomtom/tcomment_vim',   -> builtin gc/gcc/gbc operators (:h commenting)
  -- 'neoclide/jsonc.vim',    -> builtin jsonc filetype + syntax + ftplugin
  -- 'sheerun/vim-polyglot',  -> builtin syntax/ftplugin + treesitter
  -- 'tomasr/molokai',        -> builtin unokai colorscheme

  -- Dropped: replaced by own Lua, all of these were unmaintained
  -- 'vim-scripts/Tabmerge',  -> lua/tabmerge.lua
  -- 'wesQ3/vim-windowswap',  -> lua/windowswap.lua
  -- 'gregsexton/MatchTag',   -> lua/matchtag.lua (treesitter)
  -- 'Raimondi/delimitMate',  -> mini.pairs, configured in lua/pairs.lua
  -- 'kshenoy/vim-signature', -> dropped outright; marks are still `:marks`

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
}

-- entries are 'user/repo', or { 'user/repo', version = 'main' } / vim.version.range('1.*') to pin
local specs = {}
for _, repo in ipairs(repos) do
  if type(repo) == 'table' then
    local spec = vim.tbl_extend('force', repo, { src = 'https://github.com/' .. repo[1] })
    spec[1] = nil
    specs[#specs + 1] = spec
  else
    specs[#specs + 1] = { src = 'https://github.com/' .. repo }
  end
end

vim.pack.add(specs)
