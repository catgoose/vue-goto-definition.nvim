M = {}

local lsp_definition = vim.lsp.buf.definition

local function component_init()
	vim.api.nvim_create_augroup("VueGotoDefinition", { clear = true })
	vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
		pattern = { "*.vue" },
		callback = function()
			local on_list = {
				on_list = function(list)
					if list and list.items then
						for _, item in ipairs(list.items) do
							if string.match(item.filename, ".*/components.d.ts$") then
								local file = string.match(item.text, "import%('(.-)'%)")
								if file then
									vim.cmd.edit(file)
								end
								break
							end
						end
					end
				end,
			}
			---@diagnostic disable-next-line: duplicate-set-field
			vim.lsp.buf.definition = function(opts)
				opts = opts or {}
				opts = vim.tbl_extend("force", opts, on_list)
				lsp_definition(opts)
			end
		end,
	})
end

---@diagnostic disable-next-line: duplicate-set-field
function M.setup(config)
	config = config or {}
	component_init()
end

return M
