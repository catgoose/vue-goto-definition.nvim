local Log = require("vue-goto-definition").Log
local sf = require("vue-goto-definition.utils").string_format

---@class Import
---@field get_path fun(items: table, opts: table):string|nil
---@return Import
local M = {}

local function handle_vue3_imports(item, import, opts)
	if opts.filters.auto_imports and item.filename:match(opts.patterns.auto_imports) then
		if not string.match(import, "%.ts$") then
			return import .. ".ts"
		end
	elseif opts.filters.auto_components and item.filename:match(opts.patterns.auto_components) then
		return import
	end
	return nil
end

local function handle_nuxt_imports(item, import, opts)
	return opts.filters.auto_components
			and item.filename:match(opts.filters.auto_components)
			and import:gsub(opts.import_prefix, "")
		or nil
end

local function get_framework_import_func(framework)
	return framework == "vue3" and handle_vue3_imports
		or framework == "nuxt" and handle_nuxt_imports
		or function(...)
			error(string.format("Unknown framework: %s, args: %s", framework, vim.inspect(...)))
		end
end

function M.get_path(items, opts)
	for _, item in ipairs(items) do
		Log.trace(sf(
			[[import.get_path:

    import path: %s
    pattern: %s
    ]],
			item.text,
			opts.patterns.import
		))
		local import = string.match(item.text, opts.patterns.import)
		Log.trace(sf("import.get_path: import: %s", import or "none found"))
		local prefix = import and string.match(import, opts.patterns.import_prefix)
		if import and prefix then
			local import_path = get_framework_import_func(opts.framework)(item, import, opts)
			if import_path then
				return import_path
			end
		end
	end
	return nil
end

return M
