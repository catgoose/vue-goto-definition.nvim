local config = require("vue-goto-definition.config")
local list = require("vue-goto-definition.list")
local Log = require("vue-goto-definition").Log
local sf = require("vue-goto-definition.utils").string_format

local M = {}

local goto_items = {}

local function clear()
	goto_items = {}
end

local items_callback = function()
	local opts = config.get_opts()
	Log.trace(sf("items._items_callback: called for %s goto_items", #goto_items))
	list.process(goto_items, opts)
	clear()
end

local function process_items()
	if goto_items[1] then
		Log.trace(sf("items._process_items: Processing %s goto_items", #goto_items))
		items_callback()
	end
end

function M.add(items)
	for _, item in ipairs(items) do
		table.insert(goto_items, item)
	end
	Log.trace(sf(
		[[items.add: Adding items to goto_items:

  items: %s,

  goto_items: %s
  ]],
		#items,
		#goto_items
	))
	vim.defer_fn(function()
		process_items()
	end, config.get_opts().debounce)
end

function M.set_callback(func)
	items_callback = func
end

return M
