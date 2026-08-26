-- LSP, diagnostics only, no format-on-save anywhere. Servers run in a container, so the host only needs docker.
-- Images build automatically on first run, via nvim/langservers/compose.yml; see also its dockerfiles/ dir.

local COMPOSE_FILE = vim.fn.stdpath('config') .. '/langservers/compose.yml'

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

-- Run a server via its compose service. The root is bind-mounted at its real host path, so the file:// URIs need no
-- translation. network_mode/pid are fixed in compose.yml; only the per-project mount, workdir and uid are dynamic.
-- cmd must be a function, not an argv list: only that form gets root_dir, and 'autochdir' makes cwd useless here.
local function dockerized(service, cmd)
  return function(dispatchers, config)
    local root = config.root_dir or assert(vim.uv.cwd())
    -- mount the whole repo, not just root_dir: in a monorepo a server's root is often a subpackage while node_modules
    -- is hoisted above it, and anything outside the mount simply does not exist as far as the server is concerned
    local mount = vim.fs.root(root, '.git') or root
    local argv = {
      'docker', 'compose', '-f', COMPOSE_FILE, 'run', '--rm', '-i',
      -- rootful docker: without this, whatever the server writes into the project lands owned by root
      '--user', ('%d:%d'):format(vim.uv.getuid(), vim.uv.getgid()),
      '-v', mount .. ':' .. mount,
      '-w', root,
      service,
    }
    vim.list_extend(argv, cmd)
    return vim.lsp.rpc.start(argv, dispatchers)
  end
end

-- filetypes, root detection and eslint's protocol handlers come from nvim-lspconfig; only cmd and formatting are ours
vim.lsp.config('eslint', {
  cmd = dockerized('js', { 'vscode-eslint-language-server', '--stdio' }),
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
  cmd = dockerized('js', { 'vtsls', '--stdio' }),
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
  cmd = dockerized('js', { 'vue-language-server', '--stdio' }),
})

-- filetypes and root detection (composer.json/.git) come from nvim-lspconfig; only cmd is ours.
-- no argv: the php service names its own command, trust flags and all, in compose.yml.
vim.lsp.config('phpactor', {
  cmd = dockerized('php', {}),
})

vim.lsp.enable({ 'eslint', 'vtsls', 'vue_ls', 'phpactor' })

-- Symbol navigation, telescope-flavoured. This is PhpStorm's "find usages": cursor on a class or a method,
-- get the list of places that use it, preview each call site, pick one. nvim 0.11+ already binds gr* to the
-- same LSP requests, but its handlers dump the answer in the quickfix list; these open a picker instead, with
-- the qflist previewer, and jump straight there when there is only one result.
--
--   gd    definition (builtin gd is a regex search for a local declaration; this is the real thing, as is
--         CTRL-] via 'tagfunc'. <C-t> would pop the tagstack, but it moves a split down here, so come back
--         with <C-o> or :pop.)
--   grr   references -- who uses this symbol
--   grc   incoming calls -- who calls this function, one hop of the call hierarchy
--   grC   outgoing calls -- what this function calls
--   gri   implementations of an interface/abstract method
--   grt   type definition, i.e. the type of the thing under the cursor rather than the thing itself
--   gO    symbols in this file
--
-- Left to nvim's defaults: grn rename, gra code action, <C-s> signature help in insert mode.
--
-- References vs incoming calls: references are every mention of the symbol, call hierarchy is only actual
-- calls, and unlike references it can be walked outward repeatedly. phpactor answers references; whether it
-- answers callHierarchy depends on the version, hence the per-capability gating below.

-- telescope is optional: without it these fall back to the builtin, quickfix-based handlers. opts are built
-- fresh per keypress because the pickers write defaults back into the table they are handed.
local function nav(picker, fallback, opts)
  return function()
    local ok, builtin = pcall(require, 'telescope.builtin')
    if ok and builtin[picker] then
      builtin[picker](vim.deepcopy(opts or {}))
    else
      fallback()
    end
  end
end

local NAV = {
  -- key, capability, telescope picker, builtin fallback, picker opts, description
  { 'gd', 'textDocument/definition', 'lsp_definitions', vim.lsp.buf.definition, nil, 'go to definition' },
  -- includeDeclaration off: the declaration is where the cursor already is, and PhpStorm leaves it out too
  { 'grr', 'textDocument/references', 'lsp_references', vim.lsp.buf.references,
    { include_declaration = false }, 'references (usages)' },
  { 'grc', 'textDocument/prepareCallHierarchy', 'lsp_incoming_calls', vim.lsp.buf.incoming_calls, nil,
    'incoming calls' },
  { 'grC', 'textDocument/prepareCallHierarchy', 'lsp_outgoing_calls', vim.lsp.buf.outgoing_calls, nil,
    'outgoing calls' },
  { 'gri', 'textDocument/implementation', 'lsp_implementations', vim.lsp.buf.implementation, nil,
    'implementations' },
  { 'grt', 'textDocument/typeDefinition', 'lsp_type_definitions', vim.lsp.buf.type_definition, nil,
    'type definition' },
  { 'gO', 'textDocument/documentSymbol', 'lsp_document_symbols', vim.lsp.buf.document_symbol, nil,
    'document symbols' },
}

-- Buffer-local, and only for the keys this server can actually answer: an unmapped key keeps nvim's default
-- (or plain vim's meaning) instead of opening an empty picker.
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then
      return
    end
    for _, m in ipairs(NAV) do
      local key, capability, picker, fallback, opts, desc = m[1], m[2], m[3], m[4], m[5], m[6]
      if client:supports_method(capability, ev.buf) then
        vim.keymap.set('n', key, nav(picker, fallback, opts), { buffer = ev.buf, silent = true, desc = desc })
      end
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
