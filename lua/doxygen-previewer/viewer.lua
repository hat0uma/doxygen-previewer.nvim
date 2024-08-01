local util = require "doxygen-previewer.util"
local M = {}

--- @class DoxygenViewer
--- @field open { cmd:string,args:string[] }?
--- @field update { cmd:string,args:string[] }?
--- @field env table<string,string>?
--- @field cwd (fun():string)?

--- format cmd
---@param opts DoxygenPreviewerOptions
---@param html_name string
---@param cmd string[]
---@return string[]
local function format_cmd(opts, html_name, cmd)
  local paths = util.previewer_paths(opts)
  return vim.tbl_map(function(c)
    c = string.gsub(c, "{html_name}", html_name)
    c = string.gsub(c, "{html_dir}", paths.temp_htmldir)
    return c
  end, cmd)
end

--- update viewer
---@param kind "open"|"update"
---@return DoxygenViewerJob
local function viewer_job(kind)
  --- @type integer?
  local job = nil

  --- run job
  ---@param opts DoxygenPreviewerOptions
  ---@param html_name string
  local function run(opts, html_name)
    local viewer = opts.viewers[opts.viewer]
    if viewer[kind] == nil then
      return
    end

    -- stop exists job
    if job ~= nil then
      vim.fn.jobstop(job)
      job = nil
    end

    -- start new job
    local cmd = vim.list_extend({ viewer[kind].cmd }, format_cmd(opts, html_name, viewer[kind].args))
    job = vim.fn.jobstart(cmd, {
      cwd = viewer.cwd and viewer.cwd() or vim.uv.cwd(),
      env = viewer.env,
    })
    if job <= 0 then
      error(string.format("Failed to start viewer %s", job))
      return
    end
  end

  --- stop job
  local function stop()
    if job ~= nil then
      vim.fn.jobstop(job)
      job = nil
    end
  end

  --- @class DoxygenViewerJob
  return {
    run = run,
    stop = stop,
  }
end

M.openjob = viewer_job "open"
M.updatejob = viewer_job "update"

return M
