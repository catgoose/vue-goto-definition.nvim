local config = require("vue-goto-definition.config")
local autocmd = require("vue-goto-definition.autocmd")

GotoDefinition = {}

function GotoDefinition.setup(opts)
	opts = opts or {}
	local _opts = config.init(opts)
	if type(_opts.enabled) == "function" and _opts.enabled() or type(_opts.enabled) == "boolean" and _opts.enabled then
		autocmd.setup()
	end
end

return GotoDefinition
