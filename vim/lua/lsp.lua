-- ----------------------------------------------------------------------------
-- LSP, used for diagnostics only (no format-on-save anywhere).
--
-- Servers run inside a container, so the host only ever needs docker. Build the
-- image once with `make langservers`; see vim/langservers/Dockerfile.
-- ----------------------------------------------------------------------------

local IMAGE = 'dotfiles/langservers'

-- Make diagnostics actually visible. nvim's defaults are signs + underline
-- only, with virtual_text off.
vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  virtual_text = { spacing = 2, prefix = '●' },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '✖',
      [vim.diagnostic.severity.WARN] = '⚠',
      [vim.diagnostic.severity.INFO] = '›',
      [vim.diagnostic.severity.HINT] = '›',
    },
  },
})

-- Show the full message for the line under the cursor, since virtual text gets
-- truncated on narrow windows.
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { silent = true })

if vim.fn.executable('docker') == 0 then
  return
end

-- Wrap a server command so it runs in IMAGE.
--
-- The project root is bind-mounted at the *same* absolute path it has on the
-- host, which means the file:// URIs nvim and the server exchange are valid on
-- both sides and need no translation.
--
-- cmd has to be a function rather than a plain argv list: only the function
-- form is handed config.root_dir. The editor's cwd is no use for this, because
-- 'autochdir' keeps moving it to the current file's directory.
local function dockerized(cmd)
  return function(dispatchers, config)
    local root = config.root_dir or assert(vim.uv.cwd())
    local argv = {
      'docker', 'run', '--rm', '-i',
      -- rootful docker: without this, anything the server writes into the
      -- project (caches, --fix output) lands owned by root.
      '--user', ('%d:%d'):format(vim.uv.getuid(), vim.uv.getgid()),
      -- linting is entirely local; no server here has any business dialing out.
      '--network', 'none',
      -- vscode-languageserver watchdogs its client: it polls
      -- process.kill(processId, 0) and exits as soon as that pid stops
      -- resolving. In a private pid namespace nvim's pid never resolves and
      -- the server shoots itself a few seconds after initialize, so share the
      -- host's namespace to keep the client visible.
      '--pid=host',
      '-v', root .. ':' .. root,
      '-w', root,
      IMAGE,
    }
    vim.list_extend(argv, cmd)
    return vim.lsp.rpc.start(argv, dispatchers)
  end
end

-- filetypes, root detection and the eslint-specific protocol handlers come from
-- nvim-lspconfig's lsp/eslint.lua; only the command and formatting are ours.
vim.lsp.config('eslint', {
  cmd = dockerized({ 'vscode-eslint-language-server', '--stdio' }),
  settings = {
    -- eslint can format, and it is not going to. Diagnostics only.
    format = false,
    run = 'onType',
  },
})

vim.lsp.enable('eslint')

-- Applying eslint's fixes stays a deliberate act: :EslintFixAll, never on save.
vim.api.nvim_create_user_command('EslintFixAll', function()
  vim.lsp.buf.code_action({
    context = { only = { 'source.fixAll.eslint' }, diagnostics = {} },
    apply = true,
  })
end, { desc = 'apply all auto-fixable eslint problems in this buffer' })
