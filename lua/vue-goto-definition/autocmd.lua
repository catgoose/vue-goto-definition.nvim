local config = require("vue-goto-definition.config")

Autocmd = {}

local lsp_definition = vim.lsp.buf.definition
-- set default values to avoid checking for nil everywhere
local framework = config.get_framework() or nil
local patterns = config.get_patterns()[framework] or nil

local function handle_vue3_imports(opts, item, import)
	if opts.auto_imports and item.filename:match(patterns.auto_imports) then
		if not string.match(import, "%.ts$") then
			return import .. ".ts"
		end
	elseif opts.components and item.filename:match(patterns.components) then
		return import
	end
	return nil
end

local function handle_nuxt_imports(opts, item, import)
	if opts.components and item.filename:match(patterns.components) then
		return import:gsub(patterns.import_prefix, "")
	end
	return nil
end

local function handle_imports()
	return framework == "vue3" and handle_vue3_imports
		or framework == "nuxt" and handle_nuxt_imports
		or function(...)
			error(string.format("Unknown framework: %s, args: %s", framework, vim.inspect(...)))
		end
end

local function get_import_path(list)
	local opts = config.get_opts()
	for _, item in ipairs(list.items) do
		local import = string.match(item.text, patterns.import)
		if import and string.match(import, patterns.import_prefix) then
			local import_path = handle_imports()(opts, item, import)
			if import_path then
				return import_path
			end
		end
	end
	return nil
end

local function filter_location_list(list)
	local opts = config.get_opts()
	return vim.tbl_filter(function(item)
		local is_auto_import = opts.auto_imports and item.filename:match(patterns.auto_imports)
		local is_component = opts.components and item.filename:match(patterns.components)
		return not is_auto_import and not is_component
	end, list.items or {})
end

local function open_location_list(list)
	local filtered = filter_location_list(list)
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

Autocmd.setup = function()
	if not framework or not patterns then
		return
	end
	-- setting here again to avoid checking for nil everywhere
	framework = config.get_framework()
	patterns = config.get_patterns()[framework]
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
					local found_import_path = get_import_path(list)
					if found_import_path then
						vim.cmd.edit(found_import_path)
					else
						open_location_list(list)
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
