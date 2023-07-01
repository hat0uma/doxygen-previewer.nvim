local util = require "doxygen-previewer.util"
local config = require "doxygen-previewer.config"
local viewer = require "doxygen-previewer.viewer"
local doxygen = require "doxygen-previewer.doxygen"
local log = require "doxygen-previewer.log"

local M = {}

--- @type integer|nil
M.preview_buffer = nil

--- generate docs and open viewer
---@param opts? DoxygenPreviewerOptions
function M.open(opts)
  opts = config.get(opts)
  if vim.fn.executable(opts.doxygen) ~= 1 then
    util.notify(string.format("%s is not executable", opts.doxygen), "error")
    return
  end

  -- create temporary dir
  local paths = util.previewer_paths(opts)
  vim.loop.fs_mkdir(paths.temp_root, 493)

  -- copy doxyfile or create default
  if vim.loop.fs_access(opts.project_doxyfile, "R") then
    local success = vim.loop.fs_copyfile(opts.project_doxyfile, paths.temp_doxyfile)
    if not success then
      error "copy doxyfile failed."
      return
    end
  else
    util.notify "Doxyfile does not exist. Generate with default settings."
    doxygen.generate_doxyfile(opts)
  end

  local bufnr = vim.api.nvim_get_current_buf()
  doxygen.modify_doxyfile(
    paths.temp_doxyfile,
    vim.tbl_deep_extend("force", doxygen.default_override_options(opts), opts.override_options(bufnr))
  )

  -- run doxygen
  util.notify "generate docs started."
  M.preview_buffer = bufnr
  doxygen.generate_docs(
    opts,
    vim.schedule_wrap(function(obj)
      log.append(obj.stdout)
      if obj.code ~= 0 then
        util.notify(string.format("doxygen exited with code %d.", obj.code), "error")
        return
      end
      util.notify "generate docs completed."
      vim.api.nvim_exec_autocmds("User", { pattern = "DoxygenGenerateCompleted" })

      -- show output
      local html = doxygen.get_html_name(bufnr)
      viewer.openjob.run(opts, html)
    end)
  )
end

--- update docs
---@param opts? DoxygenPreviewerOptions
function M.update(opts)
  opts = config.get(opts)
  if vim.fn.executable(opts.doxygen) ~= 1 then
    util.notify(string.format("%s is not executable", opts.doxygen), "error")
  end

  if M.preview_buffer == nil then
    util.notify "Buffer in preview does not exist."
    return
  end

  --- run doxygen
  util.notify "generate docs started."
  doxygen.generate_docs(
    opts,
    vim.schedule_wrap(function(obj)
      if obj.code ~= 0 then
        util.notify(string.format("doxygen exited with code %d.", obj.code), "error")
        return
      end
      util.notify "generate docs completed."
      vim.api.nvim_exec_autocmds("User", { pattern = "DoxygenGenerateCompleted" })

      --- update
      local html = doxygen.get_html_name(M.preview_buffer)
      viewer.updatejob.run(opts, html)
    end)
  )
end

function M.stop()
  M.preview_buffer = 0
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
