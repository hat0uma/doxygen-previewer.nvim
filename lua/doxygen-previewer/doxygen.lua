local util = require "doxygen-previewer.util"
local M = {}

--- default override options
---@param opts DoxygenPreviewerOptions
---@return table
function M.default_override_options(opts)
  local paths = util.previewer_paths(opts)
  return {
    ["OUTPUT_DIRECTORY"] = paths.temp_root,
    ["RECURSIVE"] = "YES",
    ["SHORT_NAMES"] = "NO",
    ["CASE_SENSE_NAMES"] = "NO",
    ["CREATE_SUBDIRS"] = "NO",
    ["GENERATE_HTML"] = "YES",
    ["GENERATE_LATEX"] = "NO",
    ["GENERATE_MAN"] = "NO",
    ["GENERATE_RTF"] = "NO",
    ["GENERATE_XML"] = "NO",
    ["EXTRACT_ALL"] = "YES",
  }
end

--- modify doxyfile
---@param path string
---@param options table<string,string>
function M.modify_doxyfile(path, options)
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
  local obj = vim.system({ opts.doxygen, "-g", paths.temp_doxyfile }, { text = true }):wait()
  if obj.code ~= 0 then
    error(string.format("Failed to generate doxyfile. Exited with code %d.", obj.code))
  end
end

--- generate doxygen document
---@param opts DoxygenPreviewerOptions
---@param on_exit fun(obj:SystemCompleted)
function M.generate_docs(opts, on_exit)
  local paths = util.previewer_paths(opts)
  vim.system({ opts.doxygen, paths.temp_doxyfile }, { text = true }, on_exit)
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
