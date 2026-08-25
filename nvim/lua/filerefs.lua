-- "who uses this file?" -- the inverse of gd. Bound to <leader>u in init.lua.
--
-- Grepping for the filename does not work: JS imports drop the extension and often the index segment
-- ('./foo/bar' for foo/bar/index.js), and PHP does not name files at all, only classes. So this asks the
-- language server, two ways:
--
--   * tsserver knows the import graph outright and exposes it as a command, so for JS/TS/Vue we get an
--     exact answer including side-effect-only imports (`import './polyfill'`).
--   * phpactor has no such command, so we fake it: pull the file's top-level symbols out of
--     textDocument/documentSymbol and ask textDocument/references for each. Under PSR-4 a file is one
--     class, so references to that class are references to the file. The same fallback covers any other
--     server that grows a references provider.

local finders = require('telescope.finders')
local pickers = require('telescope.pickers')
local make_entry = require('telescope.make_entry')
local conf = require('telescope.config').values

local M = {}

-- vtsls, i.e. VSCode's "Find File References". Not in the LSP spec, so it is gated on the server
-- actually advertising it in executeCommandProvider.commands; client:exec_cmd checks that for us.
local FILE_REFS_CMD = 'typescript.findAllFileReferences'

-- Top-level symbols worth asking references for in the fallback. Methods and properties are deliberately
-- absent: a hit on `->save()` says nothing about which file the caller imported.
local WANTED_KINDS = {
  [vim.lsp.protocol.SymbolKind.Class] = true,
  [vim.lsp.protocol.SymbolKind.Interface] = true,
  [vim.lsp.protocol.SymbolKind.Enum] = true,
  [vim.lsp.protocol.SymbolKind.Struct] = true,
  [vim.lsp.protocol.SymbolKind.Function] = true,
  [vim.lsp.protocol.SymbolKind.Constant] = true,
}

-- namespaces are containers, not symbols anyone imports; the class we want is inside them
local TRANSPARENT_KINDS = {
  [vim.lsp.protocol.SymbolKind.Namespace] = true,
  [vim.lsp.protocol.SymbolKind.Module] = true,
  [vim.lsp.protocol.SymbolKind.Package] = true,
  [vim.lsp.protocol.SymbolKind.File] = true,
}

local function show(items, title)
  if #items == 0 then
    vim.notify('no references to this file', vim.log.levels.INFO)
    return
  end
  local opts = {}
  pickers.new(opts, {
    prompt_title = title,
    finder = finders.new_table {
      results = items,
      entry_maker = make_entry.gen_from_quickfix(opts),
    },
    previewer = conf.qflist_previewer(opts),
    sorter = conf.generic_sorter(opts),
    push_cursor_on_edit = true,
  }):find()
end

-- Locations arrive per-request and per-client, so collect into one list keyed by position. Hits inside the
-- file itself are dropped: the class' own declaration and internal uses are not somebody using the file.
local function collector(self_uri, title)
  local seen, items, pending, done = {}, {}, 0, false

  local function flush()
    if done and pending == 0 then
      table.sort(items, function(a, b)
        if a.filename ~= b.filename then return a.filename < b.filename end
        if a.lnum ~= b.lnum then return a.lnum < b.lnum end
        return a.col < b.col
      end)
      show(items, title)
    end
  end

  return {
    -- call before issuing each request, so the count cannot hit zero mid-flight
    expect = function() pending = pending + 1 end,
    add = function(locations, encoding)
      pending = pending - 1
      for _, loc in ipairs(locations or {}) do
        local uri = loc.uri or loc.targetUri
        if uri ~= self_uri then
          local range = loc.range or loc.targetSelectionRange
          local key = ('%s:%d:%d'):format(uri, range.start.line, range.start.character)
          if not seen[key] then
            seen[key] = true
            vim.list_extend(items, vim.lsp.util.locations_to_items({ loc }, encoding))
          end
        end
      end
      flush()
    end,
    -- no more requests will be issued; whatever is outstanding is all there is
    finish = function() done = true; flush() end,
  }
end

-- documentSymbol returns either a flat SymbolInformation[] or a DocumentSymbol tree, depending on the
-- server. Both are handled; the tree is descended only through namespace-ish wrappers.
local function top_level_symbols(result, out)
  out = out or {}
  for _, sym in ipairs(result or {}) do
    if sym.location then -- SymbolInformation: flat, and containerName marks the nested ones
      if WANTED_KINDS[sym.kind] and (sym.containerName or '') == '' then
        out[#out + 1] = { name = sym.name, position = sym.location.range.start }
      end
    elseif TRANSPARENT_KINDS[sym.kind] then
      top_level_symbols(sym.children, out)
    elseif WANTED_KINDS[sym.kind] then
      out[#out + 1] = { name = sym.name, position = (sym.selectionRange or sym.range).start }
    end
  end
  return out
end

function M.find()
  local bufnr = vim.api.nvim_get_current_buf()
  local uri = vim.uri_from_bufnr(bufnr)
  local title = 'File References: ' .. vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':t')

  local cmd_clients = vim.lsp.get_clients({ bufnr = bufnr, method = 'workspace/executeCommand' })
  local ref_clients = vim.lsp.get_clients({ bufnr = bufnr, method = 'textDocument/references' })
  local sym_clients = vim.lsp.get_clients({ bufnr = bufnr, method = 'textDocument/documentSymbol' })

  if #cmd_clients == 0 and #ref_clients == 0 then
    vim.notify('filerefs: no language server attached to this buffer', vim.log.levels.WARN)
    return
  end

  local sink = collector(uri, title)

  for _, client in ipairs(cmd_clients) do
    local commands = vim.tbl_get(client.server_capabilities, 'executeCommandProvider', 'commands') or {}
    if vim.tbl_contains(commands, FILE_REFS_CMD) then
      sink.expect()
      client:exec_cmd({ command = FILE_REFS_CMD, arguments = { uri } }, { bufnr = bufnr }, function(err, result)
        if err then vim.notify('filerefs: ' .. err.message, vim.log.levels.ERROR) end
        sink.add(result, client.offset_encoding)
      end)
      -- tsserver's answer is the whole import graph; asking its symbols too would only add noise
      ref_clients = vim.tbl_filter(function(c) return c.id ~= client.id end, ref_clients)
      sym_clients = vim.tbl_filter(function(c) return c.id ~= client.id end, sym_clients)
    end
  end

  -- Fallback: symbols first, then a references request per symbol. documentSymbol and references can come
  -- from different servers (phpactor does both, but a split setup is legal), so pair every symbol source
  -- with every references source.
  for _, sym_client in ipairs(sym_clients) do
    if #ref_clients > 0 then
      sink.expect() -- the symbol request itself, so the collector waits for the references it spawns
      sym_client:request('textDocument/documentSymbol', { textDocument = { uri = uri } }, function(_, result)
        local symbols = top_level_symbols(result)
        for _, sym in ipairs(symbols) do
          for _, ref_client in ipairs(ref_clients) do
            sink.expect()
            ref_client:request('textDocument/references', {
              textDocument = { uri = uri },
              position = sym.position,
              context = { includeDeclaration = false },
            }, function(err, refs)
              if err then vim.notify('filerefs: ' .. err.message, vim.log.levels.ERROR) end
              sink.add(refs, ref_client.offset_encoding)
            end, bufnr)
          end
        end
        sink.add(nil) -- settle the placeholder above now that the real requests are in flight
      end, bufnr)
    end
  end

  sink.finish()
end

vim.api.nvim_create_user_command('FileReferences', M.find, { desc = 'files referencing the current file' })

return M
