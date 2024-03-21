local M = {}

local _opts = {
	filters = {
		auto_imports = true,
		auto_components = true,
		same_file = true,
		declaration = true,
	},
	filetypes = { "vue", "typescript" },
	detection = {
		nuxt = function()
			return vim.fn.glob(".nuxt/") ~= ""
		end,
		vue3 = function()
			return vim.fn.filereadable("vite.config.ts") == 1 or vim.fn.filereadable("src/App.vue") == 1
		end,
		priority = { "nuxt", "vue3" },
	},
}

local framework = _opts.detection.priority[1]

local common = {
	import = [[import%(['|"](.-)['|"]%)]],
	declaration = ".*%.d%.ts$",
}
local patterns = {
	vue3 = {
		auto_imports = ".*/auto%-imports%.d%.ts$",
		auto_components = ".*/components%.d%.ts$",
		import_prefix = "^%./",
	},
	nuxt = {
		auto_imports = ".*/%.nuxt/types/imports%.d%.ts$",
		auto_components = ".*/%.nuxt/components%.d%.ts$",
		import_prefix = "^%.%./",
	},
}
for i, _ in pairs(common) do
	for j, _ in pairs(patterns) do
		patterns[j][i] = common[i]
	end
end

function M.set_opts(opts)
	opts = opts or {}
	_opts = vim.tbl_deep_extend("keep", opts, _opts)
	for _, detection in ipairs(_opts.detection.priority) do
		if _opts.detection[detection]() then
			framework = detection
			break
		end
	end
	return M.get_opts()
end

function M.get_opts()
	return {
		framework = framework,
		patterns = patterns[framework],
		filters = _opts.filters,
		filetypes = _opts.filetypes,
	}
end

return M
