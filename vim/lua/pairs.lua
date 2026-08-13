-- Autopairs. Replaces Raimondi/delimitMate: mini.pairs defaults cover its matchpairs and quotes.
-- expand_cr/expand_space below cover delimitMate_expand_cr and _expand_space, which mini.pairs has no equivalent for.

local M = {}

-- only brackets expand; quotes never did under delimitMate either
local EXPANDS = {
  ['('] = ')',
  ['['] = ']',
  ['{'] = '}',
}

-- true when the cursor sits directly between an open/close bracket pair
local function inside_pair()
  local line = vim.api.nvim_get_current_line()
  local col = vim.fn.col('.')
  local before = line:sub(col - 1, col - 1)
  local after = line:sub(col, col)
  return EXPANDS[before] ~= nil and EXPANDS[before] == after
end

-- {|} + <CR> -> closing brace pushed down, cursor on an indented blank line
local function expand_cr()
  if inside_pair() then
    return '<CR><Esc>O'
  end
  return '<CR>'
end

-- {|} + <Space> -> { | }
local function expand_space()
  if inside_pair() then
    return '<Space><Space><Left>'
  end
  return '<Space>'
end

function M.setup()
  require('mini.pairs').setup()

  -- expr mappings replace keycodes by default when set through vim.keymap.set
  vim.keymap.set('i', '<CR>', expand_cr, { expr = true, desc = 'expand pair on <CR>' })
  vim.keymap.set('i', '<Space>', expand_space, { expr = true, desc = 'expand pair on <Space>' })
end

return M
