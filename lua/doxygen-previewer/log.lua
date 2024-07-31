--- This module is responsible for logging the output of the doxygen command.
--- It provides a buffer to display the log.

local M = {}
M.bufnr = nil

--- Locks the buffer so that it cannot be modified.
local function unlock()
  vim.bo[M.bufnr].modifiable = true
  vim.bo[M.bufnr].readonly = false
end

--- Unlocks the buffer so that it can be modified.
local function lock()
  vim.bo[M.bufnr].modifiable = false
  vim.bo[M.bufnr].readonly = true
end

--- Creates the log buffer.
local function create_buf()
  M.bufnr = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_name(M.bufnr, "DoxygenLog")

  vim.bo[M.bufnr].filetype = "DoxygenLog"
  vim.bo[M.bufnr].buftype = "nofile"
end

--- Appends text to the log buffer.
---@param text string
function M.append(text)
  if M.bufnr == nil or not vim.api.nvim_buf_is_loaded(M.bufnr) then
    create_buf()
  end
  unlock()
  vim.api.nvim_buf_set_lines(M.bufnr, -1, -1, true, vim.split(text, "\n", {}))
  lock()
end

--- Opens the log buffer.
function M.open()
  if M.bufnr == nil or not vim.api.nvim_buf_is_loaded(M.bufnr) then
    create_buf()
    lock()
  end

  vim.cmd.tabnew()
  vim.api.nvim_set_current_buf(M.bufnr)
end

return M
