local util = require "doxygen-previewer.util"
local config = require "doxygen-previewer.config"
local doxygen = require "doxygen-previewer.doxygen"
local log = require "doxygen-previewer.log"
local prelive = require "prelive"

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
    log.error("%s is not executable", opts.doxygen.cmd)
    return
  end

  -- get preview buffer
  local preview_bufnr = vim.api.nvim_get_current_buf()
  local preview_file = vim.api.nvim_buf_get_name(preview_bufnr)

  -- find user doxyfile
  local user_doxyfile = doxygen.find_doxyfile(opts.doxygen.doxyfile_patterns, preview_file)
  local user_doxyfile_path = user_doxyfile and vim.fs.joinpath(user_doxyfile.dir, user_doxyfile.match) or nil
  local preview_cwd = user_doxyfile and user_doxyfile.dir or opts.doxygen.fallback_cwd()

  -- get doxygen options
  local paths = util.previewer_paths(opts)
  local doxygen_opts = doxygen.default_override_options(opts, paths)
  doxygen_opts = vim.tbl_deep_extend("force", doxygen_opts, opts.doxygen.override_options())

  util.start_coroutine(function() ---@async
    -- prepare doxyfile for preview
    doxygen.prepare_doxyfile_for_preview(opts, paths, doxygen_opts, user_doxyfile_path)

    M.preview_bufnr = preview_bufnr
    M.preview_cwd = preview_cwd

    -- generate docs
    log.debug "Generating documentation..."
    local obj = doxygen.generate_docs_async(opts, paths, M.preview_cwd)
    log.debug "Documentation generated."

    -- on generate completed
    vim.schedule(function()
      log.debug(obj.stdout)
      if obj.code ~= 0 then
        log.error("doxygen exited with code %d.", obj.code)
        return
      end

      -- open preview
      local html = vim.fs.joinpath(paths.temp_htmldir, doxygen.get_html_name(preview_bufnr))
      prelive.go(paths.temp_htmldir, html, { watch = false })

      -- update on save
      if opts.update_on_save then
        start_update(opts, preview_bufnr)
      end
    end)
  end)
end

--- update docs
---@param opts? DoxygenPreviewerOptions
function M.update(opts)
  opts = config.get(opts)
  if vim.fn.executable(opts.doxygen.cmd) ~= 1 then
    log.error("%s is not executable", opts.doxygen.cmd)
    return
  end

  if M.preview_bufnr == nil then
    log.info "Buffer in preview does not exist."
    return
  end

  local paths = util.previewer_paths(opts)
  util.start_coroutine(function() ---@async
    --- run doxygen
    log.debug "Generating documentation..."
    local obj = doxygen.generate_docs_async(opts, paths, M.preview_cwd)
    log.debug "Documentation generated."

    -- on generate completed
    vim.schedule(function()
      log.debug(obj.stdout)
      if obj.code ~= 0 then
        log.error("doxygen exited with code %d.", obj.code)
        return
      end

      vim.api.nvim_exec_autocmds("User", { pattern = "DoxygenGenerateCompleted" })
      prelive.reload(paths.temp_htmldir)
    end)
  end)
end

function M.stop()
  M.preview_bufnr = nil
  M.preview_cwd = nil
end

function M.log()
  vim.cmd("tabedit " .. log.LOGFILE_PATH)
end

return M
