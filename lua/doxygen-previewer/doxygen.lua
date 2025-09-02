local util = require("doxygen-previewer.util")

local M = {}

--- Default override options
--- @param opts DoxygenPreviewerOptions
--- @param paths DoxygenPreviewerPaths
--- @return table<string, string>
function M.default_override_options(opts, paths)
  local bufnr = vim.api.nvim_get_current_buf()
  return {
    --- By default, to reduce execution time, override the setting so that only files with the same name and different extension (for C/C++ headers) as the file to be previewed are generated.
    -- include .h,.c,cpp
    ["INPUT"] = ".",
    ["FILE_PATTERNS"] = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":t:r") .. ".*",
    ["EXCLUDE_PATTERNS"] = table.concat({ "*/.git/*", "*/.svn/*", "*/node_modules/*" }, " "),
    ["SEARCH_INCLUDES"] = "NO",
    ["EXTRACT_ALL"] = "YES",
    ["RECURSIVE"] = "YES",

    -- The following is related to the generation destination, so it is recommended not to change it.
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

--- Find Doxyfile
--- @param doxyfile_patterns string[]
--- @param preview_file string
--- @return {dir:string,match:string}?
function M.find_doxyfile(doxyfile_patterns, preview_file)
  return util.find_upward(doxyfile_patterns, vim.fs.dirname(preview_file))
end

--- @async
--- Modify doxyfile
--- @param path string
--- @param options table<string,string>
--- @param thread thread
function M.modify_doxyfile_async(path, options, thread)
  -- convert to key=value format for writing
  local options_text = {} --- @type string[]
  for key, value in pairs(options) do
    table.insert(options_text, string.format("%s=%s\n", key, value))
  end

  -- open doxyfile
  vim.uv.fs_open(path, "a", 420, function(err, fd)
    coroutine.resume(thread, fd, err)
  end)
  local fd, err = coroutine.yield() --- @type integer?, string?
  assert(fd, err)

  -- append options to doxyfile
  -- NOTE: If multiple options with the same name are specified in doxyfile, doxygen will honor the last value
  local text = table.concat(options_text)
  vim.uv.fs_write(fd, text, -1, function(err, bytes)
    coroutine.resume(thread, bytes, err)
  end)

  -- close doxyfile
  local bytes, close_err = coroutine.yield()
  vim.uv.fs_close(fd)
  assert(bytes, close_err)
end

--- @async
--- Generate doxyfile with default settings
--- @param opts DoxygenPreviewerOptions
--- @param paths DoxygenPreviewerPaths
--- @param thread thread
--- @return vim.SystemCompleted
function M.generate_doxyfile_async(opts, paths, thread)
  vim.system({ opts.doxygen.cmd, "-g", paths.temp_doxyfile }, { text = true }, function(obj)
    coroutine.resume(thread, obj)
  end)
  return coroutine.yield() --- @type vim.SystemCompleted
end

--- @async
--- Generate doxygen document
--- @param opts DoxygenPreviewerOptions
--- @param paths DoxygenPreviewerPaths
--- @param cwd string
--- @return vim.SystemCompleted
function M.generate_docs_async(opts, paths, cwd)
  local thread = coroutine.running()
  if not thread then
    error("this function must be called in coroutine.")
  end

  -- run doxygen
  vim.system({ opts.doxygen.cmd, paths.temp_doxyfile }, { cwd = cwd, text = true }, function(obj)
    coroutine.resume(thread, obj)
  end)
  return coroutine.yield() --- @type vim.SystemCompleted
end

--- Get HTML name from source file
--- @param bufnr integer
--- @return string
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

--- @async
--- Prepare doxyfile for preview
--- @param opts DoxygenPreviewerOptions
--- @param paths DoxygenPreviewerPaths
--- @param doxygen_opts table<string,string>
--- @param user_doxyfile? string
function M.prepare_doxyfile_for_preview(opts, paths, doxygen_opts, user_doxyfile)
  local thread = coroutine.running()
  if not thread then
    error("this function must be called in coroutine.")
  end

  -- create temporary dir
  local ok, err = util.mkdir_async(paths.temp_root, 493, thread)
  if not ok and not vim.startswith(err or "", "EEXIST") then
    error("Failed to create temporary directory. " .. (err or ""))
  end

  -- if user has doxyfile, copy it to temporary directory.
  -- otherwise, generate doxyfile with default settings.
  if user_doxyfile then
    ok, err = util.copyfile_async(user_doxyfile, paths.temp_doxyfile, thread)
    if not ok then
      error("Failed to copy doxyfile. " .. (err or ""))
    end
  else
    local obj = M.generate_doxyfile_async(opts, paths, thread)
    if obj.code ~= 0 then
      error(string.format("Failed to generate doxyfile. %s", obj.stderr))
    end
  end

  -- modify doxygen options
  M.modify_doxyfile_async(paths.temp_doxyfile, doxygen_opts, thread)
end

return M
