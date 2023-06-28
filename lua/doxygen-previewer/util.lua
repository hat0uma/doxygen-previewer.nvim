local is_windows = vim.fn.has "win32" == 1
local path_sep = is_windows and "\\" or "/"

local M = {}

--- join path elements
---@vararg string
---@return string
function M.path_join(...)
  return table.concat({ ... }, path_sep)
end

--- get previewer paths
---@param opts DoxygenPreviewerOptions
---@return DoxygenPreviewerPaths
function M.previewer_paths(opts)
  local root = M.path_join(opts.tempdir, "doxygen-previewer")
  --- @class DoxygenPreviewerPaths
  return {
    temp_root = root,
    temp_doxyfile = M.path_join(root, "Doxyfile"),
    temp_htmldir = M.path_join(root, "html"),
  }
end

return M
