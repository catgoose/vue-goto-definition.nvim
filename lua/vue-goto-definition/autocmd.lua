local config = require("vue-goto-definition.config")

Autocmd = {}

local lsp_definition = vim.lsp.buf.definition

local patterns = {
	auto_imports = ".*/auto%-imports%.d%.ts$",
	components = ".*/components%.d%.ts$",
	import = "import%('(.-)'%)",
}

local function get_import_path(list)
	local opts = config.get_opts()
	for _, item in ipairs(list.items) do
		local import = string.match(item.text, patterns.import)
		if import and string.match(import, "^%./") then
			if opts.auto_imports and item.filename:match(patterns.auto_imports) then
				if not string.match(import, "%.ts$") then
					return import .. ".ts"
				end
			elseif opts.components and item.filename:match(patterns.components) then
				return import
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
		else
			vim.fn.setloclist(0, filtered)
			vim.cmd.lopen()
		end
	end
end

Autocmd.setup = function()
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
