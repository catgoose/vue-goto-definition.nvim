local config = require("vue-goto-definition.config")
local autocmd = require("vue-goto-definition.autocmd")

local GotoDefinition = {}

function GotoDefinition.setup(opts)
	opts = opts or {}
	config.set_opts(opts)
	local framework = config.get_framework()
	local patterns = config.get_patterns()[framework]
	if not framework or not patterns then
		return
	end
	autocmd.setup(framework, patterns)
end

return GotoDefinition
