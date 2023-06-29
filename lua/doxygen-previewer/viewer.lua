local util = require "doxygen-previewer.util"

--- @class DoxygenViewer
--- @field open fun(opts:DoxygenPreviewerOptions,html_name:string)

--- @type DoxygenViewer
local live_server = {}
live_server._job = nil
live_server.open = function(opts, html_name)
  local paths = util.previewer_paths(opts)
  if live_server._job ~= nil then
    vim.fn.jobstop(live_server._job)
    live_server._job = nil
  end
  live_server._job = vim.fn.jobstart { opts.live_server, paths.temp_htmldir, "--open=" .. html_name }
end

return {
  ["live-server"] = live_server,
}
