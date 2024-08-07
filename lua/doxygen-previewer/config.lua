local M = {}

--- @class DoxygenPreviewerOptions
M.defaults = {
  --- Path to output doxygen results
  tempdir = vim.fn.stdpath("cache"),
  --- If true, update automatically when saving.
  update_on_save = true,
  --- doxygen settings section
  doxygen = {
    --- doxygen executable
    cmd = "doxygen",
    --- doxyfile pattern.
    --- Search upward from the parent directory of the file to be previewed and use the first match.
    --- The directory matching the pattern is used as the cwd when doxygen is run.
    --- If not matched, doxygen's default settings will be used. (see `doxygen -g -`)
    doxyfile_patterns = {
      "Doxyfile",
      "doc/Doxyfile",
    },
    --- If the pattern in `doxyfile_patterns` setting is not found, use this parameter as cwd when running doxygen.
    fallback_cwd = function()
      return vim.fs.dirname(vim.api.nvim_buf_get_name(0))
    end,
    --- doxygen options to override.
    --- By default, to reduce execution time, override the setting so that only files with the same name and different extension (for C/C++ headers) as the file to be previewed are generated.
    --- Also, other options related to generation are overridden by default.
    ---@return table
    override_options = function()
      return {
        -- include .h,.c,cpp
        ["INPUT"] = ".",
        ["FILE_PATTERNS"] = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t:r") .. ".*",
        ["EXCLUDE_PATTERNS"] = table.concat({ "*/.git/*", "*/.svn/*", "*/node_modules/*" }, " "),
        ["SEARCH_INCLUDES"] = "NO",
        ["EXTRACT_ALL"] = "YES",
        ["RECURSIVE"] = "YES",
      }
    end,
  },
}

--- @type DoxygenPreviewerOptions
M.options = {}

--- get config
---@param opts? DoxygenPreviewerOptions
---@return DoxygenPreviewerOptions
function M.get(opts)
  return vim.tbl_deep_extend("force", M.options, opts or {})
end

--- setup
---@param opts? DoxygenPreviewerOptions
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
