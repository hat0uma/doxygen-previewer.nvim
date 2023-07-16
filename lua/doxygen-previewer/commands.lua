local util = require "doxygen-previewer.util"
local config = require "doxygen-previewer.config"
local viewer = require "doxygen-previewer.viewer"
local doxygen = require "doxygen-previewer.doxygen"
local log = require "doxygen-previewer.log"

local M = {}

--- @type integer|nil
M.preview_bufnr = nil
M.preview_cwd = nil

--- start update on save
---@param opts DoxygenPreviewerOptions
---@param bufnr integer
local function start_update(opts, bufnr)
  vim.api.nvim_create_autocmd("BufWritePost", {
    callback = function()
      M.update(opts)
    end,
    group = vim.api.nvim_create_augroup("doxygen-previewer", {}),
    buffer = bufnr,
  })
end

--- generate docs and open viewer
---@param opts? DoxygenPreviewerOptions
function M.open(opts)
  opts = config.get(opts)
  if vim.fn.executable(opts.doxygen.cmd) ~= 1 then
    util.notify(string.format("%s is not executable", opts.doxygen.cmd), "error")
    return
  end
  -- create temporary dir
  local paths = util.previewer_paths(opts)
  vim.loop.fs_mkdir(paths.temp_root, 493)

  -- copy doxyfile or create default
  local bufnr = vim.api.nvim_get_current_buf()
  local doxyfile = doxygen.find_doxyfile(opts.doxygen.doxyfile_patterns, bufnr)
  if doxyfile then
    local ok = vim.loop.fs_copyfile(vim.fs.joinpath(doxyfile.dir, doxyfile.match), paths.temp_doxyfile)
    if not ok then
      error "copy failed."
      return
    end
  else
    doxygen.generate_doxyfile(opts)
  end

  -- modify doxygen options
  local options = vim.tbl_deep_extend("force", doxygen.default_override_options(opts), opts.doxygen.override_options())
  doxygen.modify_doxyfile(paths.temp_doxyfile, options)

  -- run doxygen
  M.preview_bufnr = bufnr
  M.preview_cwd = doxyfile and doxyfile.dir or opts.doxygen.fallback_cwd()
  util.notify(
    string.format("generate docs started.(cwd:%s,doxyfile:%s)", M.preview_cwd, doxyfile and doxyfile.match or "default")
  )
  local on_exit = vim.schedule_wrap(function(obj)
    log.append(obj.stdout)
    if obj.code ~= 0 then
      util.notify(string.format("doxygen exited with code %d.", obj.code), "error")
      return
    end
    util.notify "generate docs completed."
    vim.api.nvim_exec_autocmds("User", { pattern = "DoxygenGenerateCompleted" })

    -- show output
    local html = doxygen.get_html_name(M.preview_bufnr)
    viewer.openjob.run(opts, html)
    if opts.update_on_save then
      start_update(opts, M.preview_bufnr)
    end
  end)
  doxygen.generate_docs(opts, M.preview_cwd, on_exit)
end

--- update docs
---@param opts? DoxygenPreviewerOptions
function M.update(opts)
  opts = config.get(opts)
  if vim.fn.executable(opts.doxygen.cmd) ~= 1 then
    util.notify(string.format("%s is not executable", opts.doxygen.cmd), "error")
    return
  end

  if M.preview_bufnr == nil then
    util.notify "Buffer in preview does not exist."
    return
  end

  --- run doxygen
  local on_exit = vim.schedule_wrap(function(obj)
    log.append(obj.stdout)
    if obj.code ~= 0 then
      util.notify(string.format("doxygen exited with code %d.", obj.code), "error")
      return
    end
    vim.api.nvim_exec_autocmds("User", { pattern = "DoxygenGenerateCompleted" })

    --- update
    local html = doxygen.get_html_name(M.preview_bufnr)
    viewer.updatejob.run(opts, html)
  end)
  doxygen.generate_docs(opts, M.preview_cwd, on_exit)
end

function M.stop()
  M.preview_bufnr = nil
  M.preview_cwd = nil
  viewer.openjob.stop()
  viewer.updatejob.stop()
end

function M.log()
  log.open()
end

function M.setup()
  vim.api.nvim_create_user_command("DoxygenOpen", M.open, {})
  vim.api.nvim_create_user_command("DoxygenUpdate", M.update, {})
  vim.api.nvim_create_user_command("DoxygenStop", M.stop, {})
  vim.api.nvim_create_user_command("DoxygenLog", M.log, {})
end

return M
