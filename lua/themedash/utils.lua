local M = {}

function M.center(width, height)
  local columns = vim.o.columns
  local lines = vim.o.lines
  local row = math.floor((lines - height) / 2 - 1)
  local col = math.floor((columns - width) / 2)
  return { row = row, col = col }
end

function M.safe_set_lines(bufnr, lines)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end
  vim.api.nvim_buf_set_option(bufnr, "modifiable", true)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
end

return M
