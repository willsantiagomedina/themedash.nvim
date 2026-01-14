if vim.g.loaded_themedash == 1 then
  return
end
vim.g.loaded_themedash = 1

require("themedash").setup()

vim.api.nvim_create_user_command("ThemeDash", function()
  require("themedash").open()
end, { desc = "Open ThemeDash colorscheme picker" })

vim.api.nvim_create_user_command("ThemeDashToggle", function()
  require("themedash").toggle()
end, { desc = "Toggle ThemeDash colorscheme picker" })

vim.api.nvim_create_user_command("ThemeDashInstall", function()
  vim.ui.input({ prompt = "GitHub repo (owner/repo or URL): " }, function(input)
    if not input or input == "" then
      return
    end
    require("themedash").install(input)
  end)
end, { desc = "Install a colorscheme via lazy.nvim" })

vim.api.nvim_create_user_command("ThemeDashReload", function()
  local modules = {
    "themedash",
    "themedash.ui",
    "themedash.preview",
    "themedash.state",
    "themedash.utils",
    "themedash.installer",
  }
  for _, name in ipairs(modules) do
    package.loaded[name] = nil
  end
  local cfg = vim.g.themedash_config
  require("themedash").setup(cfg)
  vim.notify("ThemeDash reloaded", vim.log.levels.INFO)
end, { desc = "Reload ThemeDash modules" })
