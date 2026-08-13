-- Highlight the tag matching the one under the cursor. Replaces gregsexton/MatchTag (2019), which used regex.
-- Tag names only, in MatchParen, like the original. Parsers come from nvim-treesitter; see lua/ts_parsers.lua.

local M = {}

local ns = vim.api.nvim_create_namespace('matchtag')

-- element node -> the pair of tag nodes to highlight, per grammar
local ELEMENTS = {
  element = { start_tag = true, end_tag = true }, -- html, xml, vue, svelte, php
  jsx_element = { jsx_opening_element = true, jsx_closing_element = true },
}

-- the name inside a tag node, per grammar (member_expression covers <Foo.Bar>)
local NAMES = {
  tag_name = true,
  identifier = true,
  nested_identifier = true,
  member_expression = true,
}

local function name_node(tag)
  for child in tag:iter_children() do
    if NAMES[child:type()] then
      return child
    end
  end
end

local function clear(buf)
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
end

local function highlight(buf)
  clear(buf)

  -- get_node() reads only parsed trees, and start() is deliberately not called: it would enable ts highlighting too
  -- parse in full, not the visible range: the matching end tag can be off-screen. Incremental after the first pass.
  local got, parser = pcall(vim.treesitter.get_parser, buf)
  if not got or not parser then
    return
  end
  parser:parse(true)

  local ok, node = pcall(vim.treesitter.get_node)
  if not ok or not node then
    return
  end

  -- walk out to the nearest enclosing element
  local wanted
  while node do
    wanted = ELEMENTS[node:type()]
    if wanted then
      break
    end
    node = node:parent()
  end
  if not node then
    return
  end

  -- direct children only: nested elements are their own `element` node
  local tags = {}
  for child in node:iter_children() do
    if wanted[child:type()] then
      tags[#tags + 1] = child
    end
  end
  -- self-closing or unclosed: nothing to match
  if #tags < 2 then
    return
  end

  for _, tag in ipairs(tags) do
    local name = name_node(tag)
    if name then
      local row, col, end_row, end_col = name:range()
      vim.api.nvim_buf_set_extmark(buf, ns, row, col, {
        end_row = end_row,
        end_col = end_col,
        hl_group = 'MatchParen',
      })
    end
  end
end

local group = vim.api.nvim_create_augroup('matchtag', { clear = true })

function M.attach(buf)
  -- no parser for this language (svelte, say): leave the buffer alone
  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if not ok or not parser then
    return
  end

  vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
    group = group,
    buffer = buf,
    callback = function()
      highlight(buf)
    end,
  })
  vim.api.nvim_create_autocmd({ 'BufLeave', 'WinLeave' }, {
    group = group,
    buffer = buf,
    callback = function()
      clear(buf)
    end,
  })

  highlight(buf)
end

-- same ground MatchTag covered, plus the jsx flavours it never handled
local DEFAULT_FILETYPES = {
  'html',
  'xhtml',
  'xml',
  'vue',
  'svelte',
  'php',
  'javascriptreact',
  'typescriptreact',
}

---@param filetypes string[]|nil
function M.setup(filetypes)
  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = filetypes or DEFAULT_FILETYPES,
    callback = function(args)
      M.attach(args.buf)
    end,
  })
end

return M
