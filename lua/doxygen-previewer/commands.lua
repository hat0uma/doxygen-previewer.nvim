local util = require "doxygen-previewer.util"
local config = require "doxygen-previewer.config"
local viewer = require "doxygen-previewer.viewer"
local doxygen = require "doxygen-previewer.doxygen"
local logger = require("plenary.log").new {
  plugin = "doxygen-previewer",
  level = "info",
  use_console = false,
}

local M = {}

--- update docs
---@param opts? DoxygenPreviewerOptions
function M.update(opts)
  opts = config.get(opts)
  if vim.fn.executable(opts.doxygen) ~= 1 then
    vim.notify(string.format("[doxygen-previewer] %s is not executable", opts.doxygen), vim.log.levels.ERROR)
    return
  end

  doxygen.generate_docs(opts, function(obj)
    if obj.code ~= 0 then
      error(string.format("[doxygen-previewer] doxygen exited with code %d.", obj.code))
      return
    end
    vim.notify "[doxygen-previewer] generate docs completed."
  end)
end

--- generate docs and open viewer
---@param opts? DoxygenPreviewerOptions
function M.open(opts)
  opts = config.get(opts)
  if vim.fn.executable(opts.doxygen) ~= 1 then
    vim.notify(string.format("[doxygen-previewer] %s is not executable", opts.doxygen), vim.log.levels.ERROR)
    return
  end

  -- create temporary dir
  local paths = util.previewer_paths(opts)
  vim.loop.fs_mkdir(paths.temp_root, 493)

  -- copy doxyfile or create default
  if vim.loop.fs_access(opts.project_doxyfile, "R") then
    local success = vim.loop.fs_copyfile(opts.project_doxyfile, paths.temp_doxyfile)
    if not success then
      error "[doxygen-previewer] copy doxyfile failed."
      return
    end
  else
    vim.notify "[doxygen-previewer] Doxyfile does not exist. Generate with default settings."
    doxygen.generate_doxyfile(opts)
  end

  local bufnr = vim.api.nvim_get_current_buf()
  doxygen.modify_doxyfile(
    paths.temp_doxyfile,
    vim.tbl_deep_extend("force", doxygen.default_override_options(opts), opts.override_options(bufnr))
  )

  -- run doxygen
  doxygen.generate_docs(
    opts,
    vim.schedule_wrap(function(obj)
      logger.info(obj.stdout)
      if obj.code ~= 0 then
        error(string.format("[doxygen-previewer] doxygen Exited with code %d.", obj.code))
        return
      end
      vim.notify "[doxygen-previewer] generate docs completed."

      -- show output
      local html = doxygen.get_html_name(bufnr)
      viewer[opts.viewer].open(opts, html)
    end)
  )
end

function M.setup()
  vim.api.nvim_create_user_command("DoxygenOpen", M.open, {})
  vim.api.nvim_create_user_command("DoxygenUpdate", M.update, {})
end

return M
