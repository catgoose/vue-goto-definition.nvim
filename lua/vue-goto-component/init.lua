M = {}

local lsp_definition = vim.lsp.buf.definition

local function init()
	vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
		pattern = { "*.vue" },
		callback = function()
			local on_list = {
				on_list = function(list)
					if list and list.items and list.items[1] then
						local file = string.match(list.items[1].text, "import%('(.-)'%)")
						if file then
							vim.cmd.edit(file)
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
	init()
end

return M
