local util = require "doxygen-previewer.util"
local M = {}

--- default override options
---@param opts DoxygenPreviewerOptions
---@return table
function M.default_override_options(opts)
  local paths = util.previewer_paths(opts)
  return {
    ["OUTPUT_DIRECTORY"] = paths.temp_root,
    ["SHORT_NAMES"] = "NO",
    ["CASE_SENSE_NAMES"] = "NO",
    ["CREATE_SUBDIRS"] = "NO",
    ["GENERATE_HTML"] = "YES",
    ["GENERATE_LATEX"] = "NO",
    ["GENERATE_MAN"] = "NO",
    ["GENERATE_RTF"] = "NO",
    ["GENERATE_XML"] = "NO",
  }
end

--- find doxyfile
---@param doxyfile_patterns string[]
---@param bufnr integer
---@return {dir:string,match:string}?
function M.find_doxyfile(doxyfile_patterns, bufnr)
  return util.find_upward(doxyfile_patterns, vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)))
end

--- modify doxyfile
---@param path string
---@param options table<string,string>
function M.modify_doxyfile(path, options)
  --  If multiple options with the same name are specified in doxyfile, doxygen will honor the last value
  local options_text = {}
  for key, value in pairs(options) do
    table.insert(options_text, string.format("%s=%s", key, value))
  end
  vim.fn.writefile(options_text, path, "a")
end

--- generate doxyfile with default settings
---@param opts DoxygenPreviewerOptions
function M.generate_doxyfile(opts)
  local paths = util.previewer_paths(opts)
  local obj = vim.system({ opts.doxygen.cmd, "-g", paths.temp_doxyfile }, { text = true }):wait()
  if obj.code ~= 0 then
    error(string.format("Failed to generate doxyfile. Exited with code %d.", obj.code))
  end
end

--- generate doxygen document
---@param opts DoxygenPreviewerOptions
---@param cwd string
---@param on_exit fun(obj:vim.SystemCompleted)
function M.generate_docs(opts, cwd, on_exit)
  local paths = util.previewer_paths(opts)
  vim.system({ opts.doxygen.cmd, paths.temp_doxyfile }, { cwd = cwd, text = true }, on_exit)
end

--- get hrtml name from source file
---@param bufnr integer
---@return string
function M.get_html_name(bufnr)
  -- escapeCharsInString
  -- TODO:unicode name encode
  local file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t")
  return file
    :gsub("_", "__")
    :gsub("%-", "-")
    :gsub(":", "_1")
    :gsub("/", "_2")
    :gsub("<", "_3")
    :gsub(">", "_4")
    :gsub("%*", "_5")
    :gsub("&", "_6")
    :gsub("|", "_7")
    :gsub("%.", "_8")
    :gsub("!", "_9")
    :gsub(",", "_00")
    :gsub(" ", "_01")
    :gsub("{", "_02")
    :gsub("}", "_03")
    :gsub("%?", "_04")
    :gsub("%^", "_05")
    :gsub("%%", "_06")
    :gsub("%(", "_07")
    :gsub("%)", "_08")
    :gsub("%+", "_09")
    :gsub("=", "_0a")
    :gsub("%$", "_0b")
    :gsub("\\", "_0c")
    :gsub("@", "_0d")
    :gsub("%]", "_0e")
    :gsub("%[", "_0f")
    :gsub("#", "_0g")
    :gsub('"', "_0h")
    :gsub("~", "_0i")
    :gsub("'", "_0j")
    :gsub(";", "_0k")
    :gsub("`", "_0l")
    :gsub("%u", function(c)
      return "_" .. c:lower()
    end) .. ".html"
end

return M
