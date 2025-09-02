--- This module is responsible for logging the output of the doxygen command.
---@class DoxygenPreviewerLogMod: prelive.log.Logger
local M = {}
M.LOGFILE_PATH = vim.fn.stdpath("log") .. "/doxygen-previewer.log"

---@type prelive.log.Logger | nil
local logger

--- setup logger
---@return prelive.log.Logger
function M.setup()
  logger = require("prelive.core.log").new_logger()
  logger.add_notify_handler(vim.log.levels.INFO, { title = "doxygen-previewer" })
  logger.add_file_handler(vim.log.levels.DEBUG, {
    file_path = M.LOGFILE_PATH,
    max_backups = 0,
    max_file_size = 1024 * 1024,
  })
  return logger
end

return setmetatable(M, {
  __index = function(_, key)
    if not logger then
      return M.setup()[key]
    else
      return logger[key]
    end
  end,
})
