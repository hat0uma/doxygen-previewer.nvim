local config = require "doxygen-previewer.config"
local commands = require "doxygen-previewer.commands"
local M = {}

--- setup
---@param opts? DoxygenPreviewerOptions
function M.setup(opts)
  config.setup(opts)
  commands.setup()
end

M.open = commands.open
M.update = commands.update

return M
