Config = {}

local _opts = {
	auto_imports = true,
	components = true,
	enabled = function()
		return vim.fn.filereadable("vite.config.ts") == 1
	end,
}

Config.init = function(opts)
	opts = opts or {}
	_opts = vim.tbl_deep_extend("keep", opts, _opts)
	return Config.get_opts()
end

Config.get_opts = function()
	return _opts
end

return Config
