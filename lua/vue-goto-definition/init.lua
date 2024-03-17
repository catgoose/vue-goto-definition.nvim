M = {}

local lsp_definition = vim.lsp.buf.definition

local ai_regx = ".*/auto%-imports%.d%.ts$"
local cmp_regx = ".*/components%.d%.ts$"

local function autocmd()
	local group = vim.api.nvim_create_augroup("VueGotoDefinition", { clear = true })
	vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
		pattern = { "*.vue" },
		group = group,
		callback = function()
			local on_list = {
				on_list = function(list)
					local found = false
					if list and list.items then
						for _, item in ipairs(list.items) do
							local import = string.match(item.text, "import%('(.-)'%)")
							if import and string.match(import, "^%./") then
								if item.filename:match(ai_regx) then
									if not string.match(import, "%.ts$") then
										import = import .. ".ts"
									end
									found = true
								elseif item.filename:match(cmp_regx) then
									found = true
								end
								if found then
									vim.cmd.edit(import)
									break
								end
							end
						end
					end
					if not found then
						local new_list = {}
						for _, item in ipairs(list.items) do
							if not item.filename:match(ai_regx) or item.filename:match(cmp_regx) then
								table.insert(new_list, item)
							end
						end
						if #new_list > 0 then
							if #new_list == 1 then
								vim.cmd.edit(new_list[1].filename)
							else
								vim.fn.setloclist(0, new_list)
								vim.cmd.lopen()
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
	autocmd()
end

return M
