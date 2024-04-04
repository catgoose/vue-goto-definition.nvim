local import = require("vue-goto-definition.import")
local locationlist = require("vue-goto-definition.locationlist")
local Log = require("vue-goto-definition").Log
local sf = require("vue-goto-definition.utils").string_format

---@class List
---@field process fun(list: table, opts: table):nil
---@return List
local M = {}

function M.process(items, opts)
	--  TODO: 2024-03-21 - add opts for hybridMode for vue lsp
	local is_volar = vim.lsp.get_clients({ name = "volar" })[1] ~= nil
	if not is_volar then
		Log.warn("list.process: Volar LSP not found.")
	end
	Log.trace(sf("list.process: Processing list items: %s", #items))
	local path = import.get_path(items, opts)
	if path then
		Log.trace(sf("list.process: Found path: %s", path))
		vim.cmd.edit(path)
	else
		locationlist.open(items, opts)
	end
end

return M
