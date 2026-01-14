local M = {}

local defaults = {
  width = 0.8,
  height = 0.7,
  list_width = 0.35,
  keymap = nil,
  lazy_spec_path = vim.fn.stdpath("config") .. "/lua/plugins/editor.lua",
  auto_sync = true,
}

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", {}, defaults, opts or {})
  vim.g.themedash_config = M.config
  vim.api.nvim_set_hl(0, "ThemeDashSelected", { link = "Visual" })
  vim.api.nvim_set_hl(0, "ThemeDashBorder", { link = "FloatBorder" })
  vim.api.nvim_set_hl(0, "ThemeDashTitle", { link = "Title" })
  vim.api.nvim_set_hl(0, "ThemeDashHint", { link = "Comment" })
  if M.config.keymap then
    vim.keymap.set("n", M.config.keymap, function()
      require("themedash.ui").toggle(M.config)
    end, { desc = "Toggle ThemeDash" })
  end
end

function M.open()
  local cfg = M.config or vim.g.themedash_config or defaults
  require("themedash.ui").open(cfg)
end

function M.toggle()
  local cfg = M.config or vim.g.themedash_config or defaults
  require("themedash.ui").toggle(cfg)
end

function M.install(repo)
  local cfg = M.config or vim.g.themedash_config or defaults
  require("themedash.installer").install(repo, cfg)
end

return M
