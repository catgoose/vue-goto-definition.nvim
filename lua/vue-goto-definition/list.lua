local import = require("vue-goto-definition.import")
local locationlist = require("vue-goto-definition.locationlist")
local utils = require("vue-goto-definition.utils")

local M = {}

function M.process(list, opts)
	if not list or not list.items or #list.items == 0 or not utils.vue_lsp_loaded() then
		return
	end
	local items = list.items
	local path = import.get_path(items, opts)
	if path then
		vim.cmd.edit(path)
	else
		locationlist.open(items, opts)
	end
end

return M
