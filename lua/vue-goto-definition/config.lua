local utils = require("vue-goto-definition.utils")

---@class Config
---@field set_opts fun(opts: table):table
---@field get_opts fun():table
---@field at_least_log_level fun(find_level: string):boolean
---@return Config
local M = {}

local default_log_level = "warn"

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
	lsp = {
		override_definition = true,
	},
	log_level = default_log_level,
	log_levels = { "trace", "debug", "info", "warn", "error", "fatal" },
	debounce = 200,
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
	if not vim.tbl_contains(_opts.log_levels, _opts.log_level) then
		_opts.log_level = default_log_level
	end
	return M.get_opts()
end

function M.get_opts()
	return {
		framework = framework,
		patterns = patterns[framework],
		filters = _opts.filters,
		filetypes = _opts.filetypes,
		lsp = _opts.lsp,
		log_level = _opts.log_level,
		log_levels = _opts.log_levels,
		debounce = _opts.debounce,
	}
end

function M.at_least_log_level(find_level)
	local opts = M.get_opts()
	local log_levels = opts.log_levels
	local cur_i = utils.tbl_get_index(log_levels, opts.log_level)
	local find_i = utils.tbl_get_index(log_levels, find_level)
	return find_i <= cur_i
end

return M
