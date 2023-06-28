local config = require "doxygen-previewer.config"
local commands = require "doxygen-previewer.commands"
local M = {}

--- setup
---@param opts? DoxygenPreviewerOptions
function M.setup(opts)
  config.setup(opts)
  if vim.fn.executable(config.options.doxygen) ~= 1 then
    error(string.format("[doxygen-previewer] %s is not executable", config.options.doxygen))
    return
  end

  commands.setup()
end

M.open = commands.open
M.update = commands.update

return M
