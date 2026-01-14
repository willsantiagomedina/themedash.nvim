# ThemeDash.nvim

ThemeDash.nvim is a minimal floating dashboard for previewing and switching between installed Neovim colorschemes.

## Requirements
- Neovim 0.9+
- No external dependencies

## Install

### lazy.nvim
```lua
{
  "willsantiagomedina/themedash.nvim",
}
```

### packer.nvim
```lua
use({
  "willsantiagomedina/themedash.nvim",
})
```

## Usage
- `:ThemeDash` opens the floating dashboard.
- Moving selection previews the theme instantly.
- `Enter` applies the theme permanently.
- `Esc` or `q` cancels and restores the original theme.
- `:ThemeDashInstall` prompts for a GitHub repo and adds it to your lazy.nvim spec.

### Dev helper
- `:ThemeDashReload` reloads the plugin modules (useful while iterating).
- `:ThemeDashToggle` opens or cancels the dashboard.

## Config
ThemeDash has a minimal sizing hook:

```lua
require("themedash").setup({
  width = 0.8,      -- percent (0-1) or absolute columns
  height = 0.7,     -- percent (0-1) or absolute lines
  list_width = 0.35, -- percent of total width for the list
  keymap = nil,      -- set to a string like "<leader>th" to enable a default toggle mapping
  lazy_spec_path = vim.fn.stdpath("config") .. "/lua/plugins/editor.lua",
  auto_sync = true,  -- run :Lazy sync after adding a repo
})
```

### ThemeDashInstall
ThemeDash can add a colorscheme repo to lazy.nvim for you:

```vim
:ThemeDashInstall
```

It accepts `owner/repo` or full GitHub URLs, then runs `:Lazy sync` by default.

## Keybindings (buffer-local)
- `j` / `k` or `↓` / `↑` : move selection
- `Enter` : apply theme
- `Esc` / `q` : cancel and revert

## Notes
- ThemeDash only previews installed colorschemes.
- Closing the window without confirming restores the original theme.
