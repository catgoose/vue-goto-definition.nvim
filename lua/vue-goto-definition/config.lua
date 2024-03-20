local utils = require("vue-goto-definition.utils")

local M = {}

local _opts = {
	filter = {
		auto_imports = true,
		auto_components = true,
		same_file = true,
		declaration = true,
	},
	filetypes = { "vue" },
	detection = {
		nuxt = function()
			return utils.is_nuxt()
		end,
		vue3 = function()
			return utils.is_vue3()
		end,
		priority = { "nuxt", "vue3" },
	},
	defer = 100,
}

local framework = _opts.detection.priority[1]

local common = {
	import = [[import%(['|"](.-)['|"]%)]],
	declaration = ".*%.d%.ts$",
}
local patterns = {
	vue3 = {
		auto_imports = ".*/auto%-imports%.d%.ts$",
		components = ".*/components%.d%.ts$",
		import_prefix = "^%./",
	},
	nuxt = {
		auto_imports = ".*/%.nuxt/types/imports%.d%.ts$",
		components = ".*/%.nuxt/components%.d%.ts$",
		import_prefix = "^%.%./",
	},
}
for i, _ in pairs(common) do
	for j, _ in pairs(patterns) do
		patterns[j][i] = common[i]
	end
end

M.set_opts = function(opts)
	opts = opts or {}
	_opts = vim.tbl_deep_extend("keep", opts, _opts)
	_opts.filter = vim.tbl_deep_extend("keep", opts.filter or {}, _opts.filter)
	_opts.detection = vim.tbl_deep_extend("keep", opts.detection or {}, _opts.detection)
	for _, detection in ipairs(_opts.detection.priority) do
		if _opts.detection[detection]() then
			framework = detection
			break
		end
	end
	return M.get_opts()
end

M.get_opts = function()
	return _opts
end

M.get_framework = function()
	return framework
end

M.get_patterns = function()
	return patterns
end

return M
