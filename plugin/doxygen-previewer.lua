vim.api.nvim_create_user_command("DoxygenOpen", require("doxygen-previewer.commands").open, {})
vim.api.nvim_create_user_command("DoxygenUpdate", require("doxygen-previewer.commands").update, {})
vim.api.nvim_create_user_command("DoxygenStop", require("doxygen-previewer.commands").stop, {})
vim.api.nvim_create_user_command("DoxygenLog", require("doxygen-previewer.commands").log, {})
