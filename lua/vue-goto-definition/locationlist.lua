local config = require("vue-goto-definition.config")

local M = {}

function M.get_filtered_items(list, patterns)
	local filter = config.get_opts().filter
	return vim.tbl_filter(function(item)
		local is_auto_import = filter.auto_imports and item.filename:match(patterns.auto_imports)
		local is_component = filter.components and item.filename:match(patterns.components)
		local is_same_file = filter.same_file and item.filename == vim.fn.expand("%:p")
		return not is_auto_import and not is_component and not is_same_file
	end, list.items or {})
end

function M.open(items)
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

return M
