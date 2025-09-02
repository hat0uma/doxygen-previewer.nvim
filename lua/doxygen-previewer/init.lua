local commands = require("doxygen-previewer.commands")
local config = require("doxygen-previewer.config")

---@class DoxygenPreviewer
local M = {}

M.setup = config.setup
M.open = commands.open
M.update = commands.update

return M
