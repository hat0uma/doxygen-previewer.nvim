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
    --- @return string?
    fallback_cwd = function()
      local bufnr = vim.api.nvim_get_current_buf()
      return vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
    end,
    --- doxygen options to override.
    --- For details, see [Doxygen configuration](https://www.doxygen.nl/manual/config.html).
    --- Also, other options related to generation are overridden by default. see `Doxygen Options` section in README.md.
    --- If a function is specified in the value, it will be evaluated at runtime.
    --- For example:
    --- ```lua
    --- override_options = {
    ---   PROJECT_NAME = "PreviewProject",
    ---   HTML_EXTRA_STYLESHEET = vim.fn.stdpath("config") .. "/stylesheet.css"
    --- }
    --- ```
    --- @type table<string, string|fun():string>
    override_options = {},
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

--- Setup `doxygen-previewer.nvim`
--- @param opts? DoxygenPreviewerOptions
function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", M.defaults, opts or {})
end

return M
