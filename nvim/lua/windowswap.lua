-- Swap two windows' buffers, keeping each window's view. Replaces wesQ3/vim-windowswap (2018).
-- Tracked by window id, not the original's (tabnr, winnr), so a mark survives splits and closes elsewhere.

local M = {}

local marked = nil ---@type integer|nil window id

local function view_of(win)
  return vim.api.nvim_win_call(win, vim.fn.winsaveview)
end

local function place(win, buf, view)
  vim.api.nvim_win_set_buf(win, buf)
  vim.api.nvim_win_call(win, function()
    vim.fn.winrestview(view)
  end)
end

function M.mark()
  marked = vim.api.nvim_get_current_win()
end

function M.swap()
  if not marked then
    vim.notify('windowswap: no window marked to swap', vim.log.levels.WARN)
    return
  end
  if not vim.api.nvim_win_is_valid(marked) then
    marked = nil
    vim.notify('windowswap: the marked window is gone', vim.log.levels.WARN)
    return
  end

  local cur = vim.api.nvim_get_current_win()
  if cur == marked then
    marked = nil
    return
  end

  local cur_buf, cur_view = vim.api.nvim_win_get_buf(cur), view_of(cur)
  local marked_buf, marked_view = vim.api.nvim_win_get_buf(marked), view_of(marked)

  place(marked, cur_buf, cur_view)
  place(cur, marked_buf, marked_view)
  marked = nil
end

-- mark on first use, swap on second
function M.easy()
  if marked and vim.api.nvim_win_is_valid(marked) then
    M.swap()
  else
    M.mark()
  end
end

function M.has_mark()
  return marked ~= nil and vim.api.nvim_win_is_valid(marked)
end

function M.clear()
  marked = nil
end

return M
