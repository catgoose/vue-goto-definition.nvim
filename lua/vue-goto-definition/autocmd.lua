local config = require("vue-goto-definition.config")
local lsp = require("vue-goto-definition.lsp")

---@class Autocmd
---@field override_definition fun():nil
---@return Autocmd
local M = {}

function M.override_definition()
	local group = vim.api.nvim_create_augroup("VueGotoDefinition", { clear = true })
	vim.api.nvim_clear_autocmds({ group = group })
	local opts = config.get_opts()
	vim.api.nvim_create_autocmd({ "FileType" }, {
		pattern = opts.filetypes,
		group = group,
		callback = function()
			local goto = lsp.get_goto()
			---@diagnostic disable-next-line: duplicate-set-field
			vim.lsp.buf.definition = goto
		end,
	})
end

return M
