local config = require("vue-goto-definition.config")
local import = require("vue-goto-definition.import")
local utils = require("vue-goto-definition.utils")

Autocmd = {}

local lsp_definition = vim.lsp.buf.definition

local function filter_location_list(list, patterns)
	local opts = config.get_opts()
	return vim.tbl_filter(function(item)
		local is_auto_import = opts.auto_imports and item.filename:match(patterns.auto_imports)
		local is_component = opts.components and item.filename:match(patterns.components)
		local is_same_file = item.filename == vim.fn.expand("%:p")
		return not is_auto_import and not is_component and not is_same_file
	end, list.items or {})
end

local function open_location_list(list, patterns)
	local filtered = filter_location_list(list, patterns)
	if #filtered > 0 then
		if #filtered == 1 then
			vim.cmd.edit(filtered[1].filename)
			vim.api.nvim_win_set_cursor(0, { filtered[1].lnum, filtered[1].col - 1 })
		else
			vim.fn.setloclist(0, filtered)
			vim.cmd.lopen()
		end
	end
end

local _list = { items = {} }

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
					vim.list_extend(_list.items, list.items)
					vim.defer_fn(function()
						if not _list.items or #_list.items == 0 then
							return
						end
						local found_import_path = import.get_import_path(_list, patterns, framework)
						if found_import_path then
							vim.cmd.edit(found_import_path)
						else
							open_location_list(_list, patterns)
						end
					end, 100)
				end,
			}
			---@diagnostic disable-next-line: duplicate-set-field
			vim.lsp.buf.definition = function(opts)
				_list.items = {}
				opts = opts or {}
				opts = vim.tbl_extend("keep", opts, on_list)
				lsp_definition(opts)
			end
		end,
	})
end

return Autocmd
