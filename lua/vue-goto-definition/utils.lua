Utils = {}

function Utils.is_nuxt()
	return vim.fn.glob(".nuxt/") ~= ""
end

function Utils.is_vue3()
	return vim.fn.filereadable("vite.config.ts") == 1
end

function Utils.vue_tsserver_plugin_loaded()
	local found = false
	local clients = vim.lsp.get_clients({ name = "tsserver" })
	if
		clients[1]
		and clients[1].config
		and clients[1].config.init_options
		and clients[1].config.init_options.plugins
	then
		for _, plugin in ipairs(clients[1].config.init_options.plugins) do
			if plugin.name == "@vue/typescript-plugin" then
				found = true
				break
			end
		end
	end
	return found
end

return Utils
