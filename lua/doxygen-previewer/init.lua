local commands = require("doxygen-previewer.commands")
local config = require("doxygen-previewer.config")
local M = {}

--- setup
---@param opts? DoxygenPreviewerOptions
function M.setup(opts)
  config.setup(opts)
end

M.open = commands.open
M.update = commands.update

return M
