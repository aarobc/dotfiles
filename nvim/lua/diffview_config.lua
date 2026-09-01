-- diffview-plus.nvim: tabbed diff view + file history. :DiffviewOpen, :DiffviewFileHistory

local M = {}

function M.setup()
  local ok, diffview = pcall(require, 'diffview')
  if not ok then
    return
  end

  diffview.setup {}
end

return M
