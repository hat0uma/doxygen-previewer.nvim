local M = {}

local log = require("doxygen-previewer.log")

--- @async
--- `mkdir` async
--- @param path string
--- @param mode integer
--- @param thread thread
--- @return boolean ok
--- @return string | nil err
function M.mkdir_async(path, mode, thread)
  vim.uv.fs_mkdir(path, mode, function(err, ok)
    coroutine.resume(thread, err, ok)
  end)
  --- @type string|nil,boolean
  local err, ok = coroutine.yield()
  return ok, err
end

--- @async
--- Copy file async
--- @param src string
--- @param dest string
--- @param thread thread
--- @return boolean ok
--- @return string | nil err
function M.copyfile_async(src, dest, thread)
  vim.uv.fs_copyfile(src, dest, function(err, ok)
    coroutine.resume(thread, err, ok)
  end)
  --- @type string|nil,boolean
  local err, ok = coroutine.yield()
  return ok, err
end

--- Start coroutine
--- @param fn async fun(...: any)
function M.start_coroutine(fn)
  local thread = coroutine.create(function()
    local ok, err = pcall(fn)
    if not ok then
      log.error("Failed to start coroutine: %s", err)
    end
  end)

  coroutine.resume(thread)
  if coroutine.status(thread) == "dead" then
    error("Failed to start coroutine.")
  end
end

--- Get previewer paths
--- @param opts DoxygenPreviewerOptions
--- @return DoxygenPreviewerPaths
function M.previewer_paths(opts)
  local root = vim.fs.joinpath(opts.tempdir, "doxygen-previewer")

  --- @class DoxygenPreviewerPaths
  local paths = {
    temp_root = root,
    temp_doxyfile = vim.fs.joinpath(root, "Doxyfile"),
    temp_htmldir = vim.fs.joinpath(root, "html"),
  }
  return paths
end

--- @param dir string
--- @return { dir: string , match: string }?
local function find(dir, patterns)
  for _, pattern in ipairs(patterns) do
    if vim.uv.fs_access(vim.fs.joinpath(dir, pattern), "R") then
      return { dir = dir, match = pattern }
    end
  end
  return nil
end

--- Find file patterns upward from start_dir
--- @param patterns string[]
--- @param start_dir string
--- @return { dir: string , match: string }?
function M.find_upward(patterns, start_dir)
  local match = find(start_dir, patterns)
  if match then
    return match
  end

  for dir in vim.fs.parents(start_dir) do
    match = find(dir, patterns)
    if match then
      return match
    end
  end
  return nil
end

return M
