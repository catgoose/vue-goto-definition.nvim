local utils = require("vue-goto-definition.utils")

local Config = {}

local _opts = {
	filter = {
		auto_imports = true,
		auto_components = true,
		same_file = true,
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

local import = [[import%(['|"](.-)['|"]%)]]
local patterns = {
	vue3 = {
		auto_imports = ".*/auto%-imports%.d%.ts$",
		components = ".*/components%.d%.ts$",
		import = import,
		import_prefix = "^%./",
	},
	nuxt = {
		auto_imports = ".*/%.nuxt/types/imports%.d%.ts$",
		components = ".*/%.nuxt/components%.d%.ts$",
		import = import,
		import_prefix = "^%.%./",
	},
}

Config.set_opts = function(opts)
	opts = opts or {}
	_opts = vim.tbl_deep_extend("keep", opts, _opts)
	for _, detection in ipairs(_opts.detection.priority) do
		if _opts.detection[detection]() then
			framework = detection
			break
		end
	end
	return Config.get_opts()
end

Config.get_opts = function()
	return _opts
end

Config.get_framework = function()
	return framework
end

Config.get_patterns = function()
	return patterns
end

return Config
