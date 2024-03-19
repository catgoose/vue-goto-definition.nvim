local config = require("vue-goto-definition.config")

local Import = {}

local function handle_vue3_imports(opts, item, import, patterns)
	if opts.auto_imports and item.filename:match(patterns.auto_imports) then
		if not string.match(import, "%.ts$") then
			return import .. ".ts"
		end
	elseif opts.components and item.filename:match(patterns.components) then
		return import
	end
	return nil
end

local function handle_nuxt_imports(opts, item, import, patterns)
	if opts.components and item.filename:match(patterns.components) then
		return import:gsub(patterns.import_prefix, "")
	end
	return nil
end

local function get_framework_import_func(framework)
	return framework == "vue3" and handle_vue3_imports
		or framework == "nuxt" and handle_nuxt_imports
		or function(...)
			error(string.format("Unknown framework: %s, args: %s", framework, vim.inspect(...)))
		end
end

Import.get_import_path = function(list, patterns, framework)
	local opts = config.get_opts()
	for _, item in ipairs(list.items) do
		local import = string.match(item.text, patterns.import)
		if import and string.match(import, patterns.import_prefix) then
			local import_path = get_framework_import_func(framework)(opts, item, import, patterns)
			if import_path then
				return import_path
			end
		end
	end
	return nil
end

return Import
