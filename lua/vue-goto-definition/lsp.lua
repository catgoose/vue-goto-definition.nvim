local list = require("vue-goto-definition.list")
local config = require("vue-goto-definition.config")
local Log = require("vue-goto-definition").Log
local sf = require("vue-goto-definition.utils").string_format

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
			-- list.process(_list, opts)
      Log.trace(sf("Processing list items: %s", #_list.items))
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
