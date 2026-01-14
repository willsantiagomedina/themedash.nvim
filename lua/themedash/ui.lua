local state = require("themedash.state")
local preview = require("themedash.preview")
local utils = require("themedash.utils")

local M = {}

local ns = vim.api.nvim_create_namespace("ThemeDash")

local function build_preview_lines()
  return {
    "-- ThemeDash.nvim Preview",
    "local function greet(name)",
    "  if name then",
    "    print(\"Hello, \" .. name)",
    "  end",
    "end",
    "",
    "greet(\"Neovim\")",
    "",
    "-- Keys: j/k or arrows to move",
    "-- Enter applies, Esc/q cancels",
  }
end

local function set_list_lines(bufnr)
  utils.safe_set_lines(bufnr, state.themes)
end

local function highlight_selection(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  local line = state.index - 1
  vim.api.nvim_buf_add_highlight(bufnr, ns, "ThemeDashSelected", line, 0, -1)
end

local function highlight_preview_hints(bufnr, total_lines)
  vim.api.nvim_buf_add_highlight(bufnr, ns, "ThemeDashHint", total_lines - 2, 0, -1)
  vim.api.nvim_buf_add_highlight(bufnr, ns, "ThemeDashHint", total_lines - 1, 0, -1)
end

local function clamp_index(idx)
  if idx < 1 then
    return 1
  end
  if idx > #state.themes then
    return #state.themes
  end
  return idx
end

local function set_cursor(winid)
  vim.api.nvim_win_set_cursor(winid, { state.index, 0 })
end

local function apply_selection()
  local name = state.themes[state.index]
  preview.apply(name)
end

local function preview_selection()
  local name = state.themes[state.index]
  preview.preview(name)
end

function M.close()
  if M.closed then
    return
  end
  M.closed = true
  if M.win_list and vim.api.nvim_win_is_valid(M.win_list) then
    vim.api.nvim_win_close(M.win_list, true)
  end
  if M.win_preview and vim.api.nvim_win_is_valid(M.win_preview) then
    vim.api.nvim_win_close(M.win_preview, true)
  end
  if M.buf_list and vim.api.nvim_buf_is_valid(M.buf_list) then
    vim.api.nvim_buf_delete(M.buf_list, { force = true })
  end
  if M.buf_preview and vim.api.nvim_buf_is_valid(M.buf_preview) then
    vim.api.nvim_buf_delete(M.buf_preview, { force = true })
  end
  state.reset()
end

local function cancel()
  preview.revert()
  M.close()
end

local function confirm()
  apply_selection()
  M.close()
end

local function move(delta)
  local next = clamp_index(state.index + delta)
  if next == state.index then
    return
  end
  state.index = next
  highlight_selection(M.buf_list)
  set_cursor(M.win_list)
  preview_selection()
end

local function set_keymaps(bufnr)
  local opts = { buffer = bufnr, nowait = true, silent = true }
  vim.keymap.set({ "n", "i" }, "j", function() move(1) end, opts)
  vim.keymap.set({ "n", "i" }, "k", function() move(-1) end, opts)
  vim.keymap.set({ "n", "i" }, "<Down>", function() move(1) end, opts)
  vim.keymap.set({ "n", "i" }, "<Up>", function() move(-1) end, opts)
  vim.keymap.set({ "n", "i" }, "<CR>", confirm, opts)
  vim.keymap.set({ "n", "i" }, "q", cancel, opts)
  vim.keymap.set({ "n", "i" }, "<Esc>", cancel, opts)
end

local function make_buffer()
  local bufnr = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(bufnr, "buftype", "nofile")
  vim.api.nvim_buf_set_option(bufnr, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(bufnr, "swapfile", false)
  vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
  return bufnr
end

local function resolve_dim(value, total, fallback)
  if type(value) ~= "number" then
    return fallback
  end
  if value > 0 and value <= 1 then
    return math.floor(total * value)
  end
  return math.floor(value)
end

local function open_windows(config)
  local gap = 1
  local total_w = resolve_dim(config.width, vim.o.columns, math.floor(vim.o.columns * 0.8))
  local total_h = resolve_dim(config.height, vim.o.lines, math.floor(vim.o.lines * 0.7))
  local left_w = math.max(20, math.floor(total_w * (config.list_width or 0.35)))
  local right_w = total_w - left_w - gap
  local outer_w = left_w + right_w + gap + 4
  local outer_h = total_h + 2
  local pos = utils.center(outer_w, outer_h)

  M.buf_list = make_buffer()
  M.buf_preview = make_buffer()

  M.win_list = vim.api.nvim_open_win(M.buf_list, true, {
    relative = "editor",
    row = pos.row,
    col = pos.col,
    width = left_w,
    height = total_h,
    style = "minimal",
    border = "rounded",
    title = " ThemeDash ",
    title_pos = "center",
  })

  M.win_preview = vim.api.nvim_open_win(M.buf_preview, false, {
    relative = "editor",
    row = pos.row,
    col = pos.col + left_w + gap + 2,
    width = right_w,
    height = total_h,
    style = "minimal",
    border = "rounded",
    title = " Preview ",
    title_pos = "center",
  })

  vim.api.nvim_win_set_option(M.win_list, "cursorline", true)
  vim.api.nvim_win_set_option(M.win_list, "number", false)
  vim.api.nvim_win_set_option(M.win_list, "relativenumber", false)
  vim.api.nvim_win_set_option(M.win_preview, "number", false)
  vim.api.nvim_win_set_option(M.win_preview, "relativenumber", false)
  vim.api.nvim_win_set_option(M.win_list, "winhl", "FloatBorder:ThemeDashBorder,NormalFloat:Normal,Title:ThemeDashTitle")
  vim.api.nvim_win_set_option(M.win_preview, "winhl", "FloatBorder:ThemeDashBorder,NormalFloat:Normal,Title:ThemeDashTitle")
end

local function set_autocmds()
  local group = vim.api.nvim_create_augroup("ThemeDash", { clear = true })
  vim.api.nvim_create_autocmd("WinClosed", {
    group = group,
    callback = function()
      if M.closed then
        return
      end
      local winid = tonumber(vim.fn.expand("<afile>"))
      if winid ~= M.win_list and winid ~= M.win_preview then
        return
      end
      preview.revert()
      M.close()
    end,
  })
end

function M.open(config)
  M.closed = false
  state.themes = vim.fn.getcompletion("", "color")
  table.sort(state.themes)
  if #state.themes == 0 then
    vim.notify("ThemeDash: no colorschemes found", vim.log.levels.WARN)
    return
  end

  state.index = 1
  preview.capture_original()
  open_windows(config or {})
  set_list_lines(M.buf_list)
  local preview_lines = build_preview_lines()
  utils.safe_set_lines(M.buf_preview, preview_lines)
  vim.api.nvim_buf_set_option(M.buf_preview, "filetype", "lua")
  highlight_preview_hints(M.buf_preview, #preview_lines)
  highlight_selection(M.buf_list)
  set_cursor(M.win_list)
  preview_selection()
  set_keymaps(M.buf_list)
  set_keymaps(M.buf_preview)
  set_autocmds()
end

function M.is_open()
  return (M.win_list and vim.api.nvim_win_is_valid(M.win_list))
    or (M.win_preview and vim.api.nvim_win_is_valid(M.win_preview))
end

function M.cancel()
  cancel()
end

function M.toggle(config)
  if M.is_open() then
    cancel()
    return
  end
  M.open(config)
end

return M
