-- LSP, diagnostics only, no format-on-save anywhere. Servers run in a container, so the host only needs docker.
-- Build the image with `make langservers`; see vim/langservers/Dockerfile.

local IMAGE = 'dotfiles/langservers'

-- nvim defaults to signs + underline only, with virtual_text off
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

-- full message for the current line; virtual text truncates on narrow windows
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { silent = true })

if vim.fn.executable('docker') == 0 then
  return
end

-- Run a server in IMAGE. The root is bind-mounted at its real host path, so the file:// URIs need no translation.
-- cmd must be a function, not an argv list: only that form gets root_dir, and 'autochdir' makes cwd useless here.
local function dockerized(cmd)
  return function(dispatchers, config)
    local root = config.root_dir or assert(vim.uv.cwd())
    local argv = {
      'docker', 'run', '--rm', '-i',
      -- rootful docker: without this, whatever the server writes into the project lands owned by root
      '--user', ('%d:%d'):format(vim.uv.getuid(), vim.uv.getgid()),
      -- linting is entirely local; no server here has any business dialing out
      '--network', 'none',
      -- vscode-languageserver polls process.kill(clientPid, 0) and quits when it fails, as a private pid ns guarantees
      '--pid=host',
      '-v', root .. ':' .. root,
      '-w', root,
      IMAGE,
    }
    vim.list_extend(argv, cmd)
    return vim.lsp.rpc.start(argv, dispatchers)
  end
end

-- filetypes, root detection and eslint's protocol handlers come from nvim-lspconfig; only cmd and formatting are ours
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
