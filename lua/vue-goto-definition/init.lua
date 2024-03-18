local config = require("vue-goto-definition.config")
local autocmd = require("vue-goto-definition.autocmd")

GotoDefinition = {}

function GotoDefinition.setup(opts)
	opts = opts or {}
	config.set_opts(opts)
	local framework = config.get_framework()
	if framework then
		autocmd.setup(framework)
	end
end

return GotoDefinition
