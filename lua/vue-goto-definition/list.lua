local import = require("vue-goto-definition.import")
local locationlist = require("vue-goto-definition.locationlist")

local M = {}

function M.process(list, opts)
	local is_volar = vim.lsp.get_clients({ name = "volar" })[1] ~= nil
	if not list or not list.items or #list.items == 0 or not is_volar then
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
