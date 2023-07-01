local M = {}

--- @class DoxygenPreviewerOptions
M.defaults = {
  --- doxygen executable
  doxygen = "doxygen",

  --- viewer for display doxygen output
  --- @type "live-server"
  viewer = "live-server",

  --- project doxyfile path
  project_doxyfile = "./Doxyfile",

  --- Path to output doxygen results
  tempdir = vim.fn.stdpath "cache",

  --- override doxygen options
  ---@param bufnr integer
  ---@return table
  override_options = function(bufnr)
    return {
      -- include .h,.c,cpp
      ["INPUT"] = ".",
      ["FILE_PATTERNS"] = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t:r") .. ".*",
      ["SEARCH_INCLUDES"] = "NO",
    }
  end,

  --- viewer preset
  --- @type table<string,DoxygenViewer>
  viewers = {
    ["live-server"] = {
      open = { cmd = "live-server", args = { "{html_dir}", "--open={html_name}" } },
      update = nil,
    },
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
