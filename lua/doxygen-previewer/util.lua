local M = {}

--- notify
---@param msg string
---@param level number|string|nil
function M.notify(msg, level)
  vim.notify(msg, level or "info", {
    title = "doxygen-previewer",
  })
end

--- get previewer paths
---@param opts DoxygenPreviewerOptions
---@return { temp_root: string, temp_doxyfile: string, temp_htmldir: string}
function M.previewer_paths(opts)
  local root = vim.fs.joinpath(opts.tempdir, "doxygen-previewer")
  return {
    temp_root = root,
    temp_doxyfile = vim.fs.joinpath(root, "Doxyfile"),
    temp_htmldir = vim.fs.joinpath(root, "html"),
  }
end

--- find file patterns upward from start_dir
---@param patterns string[]
---@param start_dir string
---@return {dir:string ,match:string}?
function M.find_upward(patterns, start_dir)
  local find = function(dir)
    for _, pattern in ipairs(patterns) do
      if vim.loop.fs_access(vim.fs.joinpath(dir, pattern), "R") then
        return { dir = dir, match = pattern }
      end
    end
    return nil
  end

  local match = find(start_dir)
  if match then
    return match
  end

  for dir in vim.fs.parents(start_dir) do
    match = find(dir)
    if match then
      return match
    end
  end
  return nil
end

return M
