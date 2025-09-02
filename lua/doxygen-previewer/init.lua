local commands = require("doxygen-previewer.commands")
local config = require("doxygen-previewer.config")

---@class DoxygenPreviewer
local M = {}

M.setup = config.setup
M.open = commands.open
M.update = commands.update

return M

-- vim:ts=2:sts=2:sw=2:et:
