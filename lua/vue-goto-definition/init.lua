local config = require("vue-goto-definition.config")

---@class VueGotoDefinition
---@field setup fun(opts: table):nil
---@field goto_definition fun():nil
---@return VueGotoDefinition
local M = {}

function M.setup(opts)
	opts = opts or {}
	config.set_opts(opts)
	M.Log = require("vue-goto-definition.logger").init()
	if opts.lsp.override_definition then
    require("vue-goto-definition.autocmd").override_definition()
	end
end

function M.goto_definition(opts)
 	local goto = require("vue-goto-definition.lsp").get_goto(opts)
	goto()
end

return M
