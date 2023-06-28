local util = require "doxygen-previewer.util"

--- @type number|nil
local liveserver_job = nil

--- @class DoxygenViewer
--- @field open fun(opts:DoxygenPreviewerOptions,html_name:string)

--- @type table<string,DoxygenViewer>
local M = {
  ["live-server"] = {
    open = function(opts, html_name)
      local paths = util.previewer_paths(opts)
      if liveserver_job ~= nil then
        print "stop exists viewer job."
        vim.fn.jobstop(liveserver_job)
        liveserver_job = nil
      end
      liveserver_job = vim.fn.jobstart { opts.live_server, paths.temp_htmldir, "--open=" .. html_name }
    end,
  },
}
return M
