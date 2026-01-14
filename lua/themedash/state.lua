local M = {
  themes = {},
  index = 1,
  original = nil,
  applied = nil,
}

function M.reset()
  M.themes = {}
  M.index = 1
  M.original = nil
  M.applied = nil
end

return M
