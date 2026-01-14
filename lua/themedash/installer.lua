local M = {}

local function normalize_repo(input)
  if not input or input == "" then
    return nil
  end

  local repo = input
  repo = repo:gsub("^https?://github.com/", "")
  repo = repo:gsub("^git@github.com:", "")
  repo = repo:gsub("#.*$", "")
  repo = repo:gsub("%?.*$", "")
  repo = repo:gsub("%.git$", "")
  repo = repo:gsub("/$", "")

  if not repo:find("/") then
    return nil
  end
  return repo
end

local function insert_spec(lines, spec_lines)
  for i = #lines, 1, -1 do
    if lines[i]:match("^%s*}%s*$") then
      local before = vim.list_slice(lines, 1, i - 1)
      local after = vim.list_slice(lines, i, #lines)
      for _, l in ipairs(spec_lines) do
        table.insert(before, l)
      end
      for _, l in ipairs(after) do
        table.insert(before, l)
      end
      return before
    end
  end
  return nil
end

local function remove_spec(lines, spec_lines)
  local i = 1
  while i <= #lines do
    local match = true
    for j = 1, #spec_lines do
      if lines[i + j - 1] ~= spec_lines[j] then
        match = false
        break
      end
    end
    if match then
      for _ = 1, #spec_lines do
        table.remove(lines, i)
      end
      if lines[i] == "" then
        table.remove(lines, i)
      end
      return lines
    end
    i = i + 1
  end
  return nil
end

local function has_colorscheme(path)
  local vim_colors = vim.fn.globpath(path, "colors/*.vim", false, true)
  local lua_colors = vim.fn.globpath(path, "colors/*.lua", false, true)
  return (#vim_colors + #lua_colors) > 0
end

local function validate_install(name)
  local repo = name:match("/([^/]+)$") or name
  local lazy_root = vim.fn.stdpath("data") .. "/lazy"
  local plugin_path = lazy_root .. "/" .. repo
  if vim.fn.isdirectory(plugin_path) == 0 then
    return false, "plugin directory not found"
  end
  if not has_colorscheme(plugin_path) then
    return false, "no colorscheme files found under colors/"
  end
  return true
end

function M.install(repo, config)
  local name = normalize_repo(repo)
  if not name then
    vim.notify("ThemeDash: invalid repo. Use owner/repo or a GitHub URL.", vim.log.levels.WARN)
    return
  end

  local spec_path = config.lazy_spec_path
  if not spec_path or spec_path == "" then
    vim.notify("ThemeDash: lazy_spec_path not configured", vim.log.levels.ERROR)
    return
  end

  local lines = vim.fn.readfile(spec_path)
  local spec_lines = {
    "",
    "\t{",
    string.format("\t\t\"%s\",", name),
    "\t\tlazy = false,",
    "\t},",
  }

  local updated = insert_spec(lines, spec_lines)
  if not updated then
    vim.notify("ThemeDash: failed to update lazy spec file", vim.log.levels.ERROR)
    return
  end

  vim.fn.writefile(updated, spec_path)
  vim.notify("ThemeDash: added " .. name .. " to lazy spec", vim.log.levels.INFO)

  if config.auto_sync then
    local ok, err = pcall(vim.cmd, "Lazy sync")
    if not ok then
      vim.notify("ThemeDash: Lazy sync failed: " .. err, vim.log.levels.WARN)
      local cleaned = remove_spec(vim.fn.readfile(spec_path), spec_lines)
      if cleaned then
        vim.fn.writefile(cleaned, spec_path)
      end
      return
    end
    local valid, reason = validate_install(name)
    if not valid then
      vim.notify("ThemeDash: install warning for " .. name .. " (" .. reason .. ")", vim.log.levels.WARN)
      local cleaned = remove_spec(vim.fn.readfile(spec_path), spec_lines)
      if cleaned then
        vim.fn.writefile(cleaned, spec_path)
      end
    end
  end
end

return M
