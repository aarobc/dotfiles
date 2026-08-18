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
    -- mount the whole repo, not just root_dir: in a monorepo a server's root is often a subpackage while node_modules
    -- is hoisted above it, and anything outside the mount simply does not exist as far as the server is concerned
    local mount = vim.fs.root(root, '.git') or root
    local argv = {
      'docker', 'run', '--rm', '-i',
      -- rootful docker: without this, whatever the server writes into the project lands owned by root
      '--user', ('%d:%d'):format(vim.uv.getuid(), vim.uv.getgid()),
      -- linting is entirely local; no server here has any business dialing out
      '--network', 'none',
      -- vscode-languageserver polls process.kill(clientPid, 0) and quits when it fails, as a private pid ns guarantees
      '--pid=host',
      '-v', mount .. ':' .. mount,
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

-- Vue 3 tooling is split: vue_ls owns the template and style blocks, while TypeScript inside a .vue file comes from
-- vtsls hosting @vue/typescript-plugin. This is "hybrid mode"; takeover mode is gone as of vue_ls v3.
-- The location is resolved by tsserver inside the container, so it is a container path, not a host one.
local VUE_PLUGIN = {
  name = '@vue/typescript-plugin',
  location = '/usr/local/lib/node_modules/@vue/language-server',
  languages = { 'vue' },
  configNamespace = 'typescript',
  -- required because autoUseWorkspaceTsdk is on below: global plugins are otherwise skipped for a workspace
  -- TypeScript, and tsserver then lints the whole .vue file as raw TS -- ~70 bogus errors from the template block
  enableForWorkspaceTypeScriptVersions = true,
}

-- vtsls wraps tsserver. filetypes and the monorepo-aware, deno-excluding root_dir come from nvim-lspconfig's vtsls.lua.
vim.lsp.config('vtsls', {
  cmd = dockerized({ 'vtsls', '--stdio' }),
  -- lspconfig's list, plus vue: vtsls must attach to .vue buffers for the plugin above to do anything
  filetypes = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact', 'vue' },
  settings = {
    -- prefer the project's typescript over the copy baked into the image: only the repo is bind-mounted, so jumping
    -- into a bundled lib.dom.d.ts would hand nvim a container path the host cannot open
    vtsls = {
      autoUseWorkspaceTsdk = true,
      tsserver = { globalPlugins = { VUE_PLUGIN } },
    },
    typescript = {
      -- the point of gd: land on the real .ts/.js implementation, never a .d.ts
      preferGoToSourceDefinition = true,
      -- automatic type acquisition fetches @types from npm, and the container runs --network none
      disableAutomaticTypeAcquisition = true,
    },
    javascript = { preferGoToSourceDefinition = true },
  },
})

-- everything else about vue_ls -- the mandatory tsserver/request forwarding to vtsls, and its retry on a slow
-- attach -- comes from nvim-lspconfig's lsp/vue_ls.lua. Only the command is ours.
vim.lsp.config('vue_ls', {
  cmd = dockerized({ 'vue-language-server', '--stdio' }),
})

vim.lsp.enable({ 'eslint', 'vtsls', 'vue_ls' })

-- builtin gd is a regex search for a local declaration; this is the real thing. CTRL-] does it too, via 'tagfunc'.
-- <C-t> would normally pop the tagstack, but it moves a split down here, so come back with <C-o> or :pop.
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if client and client:supports_method('textDocument/definition') then
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = ev.buf, silent = true, desc = 'go to definition' })
    end
  end,
})

-- Applying eslint's fixes stays a deliberate act: :EslintFixAll, never on save.
vim.api.nvim_create_user_command('EslintFixAll', function()
  vim.lsp.buf.code_action({
    context = { only = { 'source.fixAll.eslint' }, diagnostics = {} },
    apply = true,
  })
end, { desc = 'apply all auto-fixable eslint problems in this buffer' })
