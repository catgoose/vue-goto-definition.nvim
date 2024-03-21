local config = require("vue-goto-definition.config")
local autocmd = require("vue-goto-definition.autocmd")

local M = {}

function M.setup(opts)
	opts = opts or {}
	config.set_opts(opts)
	autocmd.setup()
end

return M
