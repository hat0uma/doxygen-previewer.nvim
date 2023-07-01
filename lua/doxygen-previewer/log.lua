local M = {}
M.bufnr = nil

local function unlock()
  vim.bo[M.bufnr].modifiable = true
  vim.bo[M.bufnr].readonly = false
end

local function lock()
  vim.bo[M.bufnr].modifiable = false
  vim.bo[M.bufnr].readonly = true
end

local function create_buf()
  M.bufnr = vim.api.nvim_create_buf(false, false)
  vim.api.nvim_buf_set_name(M.bufnr, "DoxygenLog")

  vim.bo[M.bufnr].filetype = "DoxygenLog"
  vim.bo[M.bufnr].buftype = "nofile"
end

--- log
---@param text string
function M.append(text)
  if M.bufnr == nil or not vim.api.nvim_buf_is_loaded(M.bufnr) then
    create_buf()
  end
  unlock()
  vim.api.nvim_buf_set_lines(M.bufnr, -1, -1, true, vim.split(text, "\n", {}))
  lock()
end

function M.open()
  if M.bufnr == nil or not vim.api.nvim_buf_is_loaded(M.bufnr) then
    create_buf()
    lock()
  end

  vim.cmd.tabnew()
  vim.api.nvim_set_current_buf(M.bufnr)
end

return M
