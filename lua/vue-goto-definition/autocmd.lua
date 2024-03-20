local config = require("vue-goto-definition.config")
local import = require("vue-goto-definition.import")
local utils = require("vue-goto-definition.utils")

local Autocmd = {}

local lsp_definition = vim.lsp.buf.definition

local function filter_location_list(list, patterns)
	local filter = config.get_opts().filter
	return vim.tbl_filter(function(item)
		local is_auto_import = filter.auto_imports and item.filename:match(patterns.auto_imports)
		local is_component = filter.components and item.filename:match(patterns.components)
		local is_same_file = filter.same_file and item.filename == vim.fn.expand("%:p")
		return not is_auto_import and not is_component and not is_same_file
	end, list.items or {})
end

local function open_location_list(items)
	if #items > 0 then
		if #items == 1 then
			vim.cmd.edit(items[1].filename)
			vim.api.nvim_win_set_cursor(0, { items[1].lnum, items[1].col - 1 })
		else
			vim.fn.setloclist(0, items)
			vim.cmd.lopen()
		end
	end
end

local _items = {}

Autocmd.setup = function(framework, patterns)
	local group = vim.api.nvim_create_augroup("VueGotoDefinition", { clear = true })
	vim.api.nvim_create_autocmd({ "FileType" }, {
		pattern = config.get_opts().filetypes,
		group = group,
		callback = function()
			local on_list = {
				on_list = function(list)
					if not list or not list.items or #list.items == 0 or not utils.vue_tsserver_plugin_loaded() then
						return
					end
					local items = filter_location_list(list, patterns)
					vim.list_extend(_items, items)
					vim.defer_fn(function()
						if #_items == 0 then
							return
						end
						local found_import_path = import.get_import_path(_items, patterns, framework)
						if found_import_path then
							vim.cmd.edit(found_import_path)
						else
							open_location_list(_items)
						end
					end, config.get_opts().defer)
				end,
			}
			---@diagnostic disable-next-line: duplicate-set-field
			vim.lsp.buf.definition = function(opts)
				_items = {}
				opts = opts or {}
				opts = vim.tbl_extend("keep", opts, on_list)
				lsp_definition(opts)
			end
		end,
	})
end

return Autocmd
