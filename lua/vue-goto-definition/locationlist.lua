local config = require("vue-goto-definition.config")

local M = {}

local function get_filtered_items(items, patterns)
	local filter = config.get_opts().filter
	local filtered = vim.tbl_filter(function(item)
		local is_auto_import = filter.auto_imports and item.filename:match(patterns.auto_imports)
		local is_component = filter.components and item.filename:match(patterns.components)
		local is_same_file = filter.same_file and item.filename == vim.fn.expand("%:p")
		return not is_auto_import and not is_component and not is_same_file
	end, items or {})
	if #filtered < 2 then
		return filtered
	end
	return vim.tbl_filter(function(item)
		local is_declaration = filter.declaration and item.filename:match(patterns.declaration)
		return not is_declaration
	end, filtered)
end

function M.open(items, patterns)
	local filtered = get_filtered_items(items, patterns)
	if #filtered > 0 then
		if #filtered == 1 then
			vim.cmd.edit(filtered[1].filename)
			vim.api.nvim_win_set_cursor(0, { filtered[1].lnum, items[1].col - 1 })
		else
			vim.fn.setloclist(0, filtered)
			vim.cmd.lopen()
		end
	end
end

return M
