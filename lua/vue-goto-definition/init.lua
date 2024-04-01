local config = require("vue-goto-definition.config")
local autocmd = require("vue-goto-definition.autocmd")
local lsp = require("vue-goto-definition.lsp")

---@class VueGotoDefinition
---@field setup fun(opts: table):nil
---@field goto_definition fun():nil
---@return VueGotoDefinition
local M = {}

function M.setup(opts)
	opts = opts or {}
	opts = config.set_opts(opts)
	if opts.lsp.override_definition then
		autocmd.override_definition()
	end
end

function M.goto_definition()
	local goto = lsp.get_goto()
	 goto()
end

return M
