local state = require("themedash.state")

local M = {}

function M.capture_original()
  if not state.original then
    state.original = vim.g.colors_name or "default"
  end
end

local function apply(name)
  local ok, err = pcall(vim.cmd.colorscheme, name)
  if not ok then
    vim.notify("ThemeDash: failed to load colorscheme: " .. name .. " (" .. err .. ")", vim.log.levels.WARN)
    return false
  end
  return true
end

function M.preview(name)
  M.capture_original()
  if apply(name) then
    state.applied = name
  end
end

function M.apply(name)
  if apply(name) then
    state.applied = name
    state.original = name
  end
end

function M.revert()
  if state.original and state.original ~= "default" then
    apply(state.original)
  else
    vim.cmd("colorscheme default")
  end
end

return M
