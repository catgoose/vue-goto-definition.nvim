local M = {}

function M.is_nuxt()
	return vim.fn.glob(".nuxt/") ~= ""
end

function M.is_vue3()
	return vim.fn.filereadable("vite.config.ts") == 1 or vim.fn.filereadable("src/App.vue") == 1
end

function M.vue_lsp_loaded()
	return vim.lsp.get_clients({ name = "volar" })[1] ~= nil
end

return M
