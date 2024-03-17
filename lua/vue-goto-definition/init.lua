M = {}

local lsp_definition = vim.lsp.buf.definition

local patterns = {
	auto_imports = ".*/auto%-imports%.d%.ts$",
	components = ".*/components%.d%.ts$",
}

local function get_import(list)
	for _, item in ipairs(list.items) do
		local import = string.match(item.text, "import%('(.-)'%)")
		if import and string.match(import, "^%./") then
			if item.filename:match(patterns.auto_imports) then
				if not string.match(import, "%.ts$") then
					return import .. ".ts"
				end
			elseif item.filename:match(patterns.components) then
				return import
			end
		end
	end
	return nil
end

local function filter_location_list(list)
	local new_list = vim.tbl_filter(function(item)
		return not item.filename:match(patterns.auto_imports) or item.filename:match(patterns.components)
	end, list.items)
	return new_list
end

local function open_location_list(list)
	local new_list = filter_location_list(list)
	if #new_list > 0 then
		if #new_list == 1 then
			vim.cmd.edit(new_list[1].filename)
		else
			vim.fn.setloclist(0, new_list)
			vim.cmd.lopen()
		end
	end
end

local function autocmd()
	local group = vim.api.nvim_create_augroup("VueGotoDefinition", { clear = true })
	vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
		pattern = { "*.vue" },
		group = group,
		callback = function()
			local on_list = {
				on_list = function(list)
					if not list or not list.items or #list.items == 0 then
						return
					end
					local found_import = get_import(list)
					if found_import then
						vim.cmd.edit(found_import)
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

---@diagnostic disable-next-line: duplicate-set-field
function M.setup(config)
	config = config or {}
	autocmd()
end

return M
