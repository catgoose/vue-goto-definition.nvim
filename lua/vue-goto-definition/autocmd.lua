local config = require("vue-goto-definition.config")
local import = require("vue-goto-definition.import")

Autocmd = {}

local lsp_definition = vim.lsp.buf.definition

local function filter_location_list(list, patterns)
	local opts = config.get_opts()
	return vim.tbl_filter(function(item)
		local is_auto_import = opts.auto_imports and item.filename:match(patterns.auto_imports)
		local is_component = opts.components and item.filename:match(patterns.components)
		return not is_auto_import and not is_component
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

--  BUG: 2024-03-17 - goto definition for vue framework in a .vue file on an
--  imported file like a pinia store does not work
Autocmd.setup = function(framework, patterns)
	local group = vim.api.nvim_create_augroup("VueGotoDefinition", { clear = true })
	vim.api.nvim_create_autocmd({ "FileType" }, {
		pattern = config.get_opts().filetypes,
		group = group,
		callback = function()
			local on_list = {
				on_list = function(list)
					if not list or not list.items or #list.items == 0 then
						return
					end
					local found_import_path = import.get_import_path(list, patterns, framework)
					if found_import_path then
						vim.cmd.edit(found_import_path)
					else
						open_location_list(list, patterns)
					end
				end,
			}
			---@diagnostic disable-next-line: duplicate-set-field
			vim.lsp.buf.definition = function(opts)
				opts = opts or {}
				opts = vim.tbl_extend("keep", opts, on_list)
				lsp_definition(opts)
			end
		end,
	})
end

return Autocmd
