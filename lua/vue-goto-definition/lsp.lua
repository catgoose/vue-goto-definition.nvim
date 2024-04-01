local list = require("vue-goto-definition.list")
local config = require("vue-goto-definition.config")

---@class Lsp
---@field get_goto fun():function
---@return Lsp
local M = {}

local lsp_definition = vim.lsp.buf.definition

local function get_definition()
	return lsp_definition
end

function M.get_goto()
	local opts = config.get_opts()
	local on_list = {
		on_list = function(_list)
			list.process(_list, opts)
		end,
	}
	local goto = function(_opts)
		_opts = _opts or {}
		_opts = vim.tbl_extend("keep", _opts, on_list)
		local definition = get_definition()
    definition(_opts)
	end
	return goto
end

return M
