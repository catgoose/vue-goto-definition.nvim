local Log = require("vue-goto-definition").Log
local sf = require("vue-goto-definition.utils").string_format

---@class LocationList
---@field open fun(items: table, opts: table):nil
---@return LocationList
local M = {}

local function dedupe_filenames(items)
	local seen = {}
	local filtered = {}
	for _, item in ipairs(items) do
		if not seen[item.filename] then
			table.insert(filtered, item)
			seen[item.filename] = true
		end
	end
	if #filtered == 0 then
		Log.debug([[locationlist.dedupe_filenames: filtered list is empty: returning original items]])
		return items
	end
	if #filtered ~= #items then
		Log.debug(sf([[locationlist.dedupe_filenames: found %s items after deduping filenames]], #filtered))
	end
	return filtered
end

local function apply_filters(items, opts)
	local filtered = vim.tbl_filter(function(item)
		local is_auto_import = opts.filters.auto_imports and item.filename:match(opts.patterns.auto_imports)
		local is_component = opts.filters.auto_components and item.filename:match(opts.patterns.auto_components)
		local is_same_file = opts.filters.same_file and item.filename == vim.fn.expand("%:p")
		return not is_auto_import and not is_component and not is_same_file
	end, items or {})
	if #filtered == 0 then
		Log.debug([[locationlist.apply_filters: filtered list is empty: returning original items]])
		return items
	end
	if #filtered ~= #items then
		Log.debug(sf([[locationlist.apply_filters: found %s items after applying filters]], #filtered))
	end
	return filtered
end

local function remove_declarations(items, opts)
	local filtered = vim.tbl_filter(function(item)
		local is_declaration = opts.filters.declaration and item.filename:match(opts.patterns.declaration)
		return not is_declaration
	end, items)
	if #filtered == 0 then
		Log.debug([[locationlist.remove_declarations: filtered list is empty: returning original items]])
		return items
	end
	if #filtered ~= #items then
		Log.debug(sf([[locationlist.remove_declarations: found %s items after declaration filter]], #filtered))
	end
	return filtered
end

local function get_filtered_items(items, opts)
	items = dedupe_filenames(items)
	items = apply_filters(items, opts)
	if #items < 2 then
		return items
	end
	items = remove_declarations(items, opts)
	return items
end

function M.open(items, opts)
	Log.debug(sf("locationlist.open: processing %s items", #items))
	local filtered = get_filtered_items(items, opts)
	Log.trace(sf(
		[[locationlist.open: filtered items:

  %s]],
		filtered
	))
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
