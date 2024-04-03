---@class Utils
---@field string_format fun(msg: string, ...): string
---@return Utils
local M = {}

function M.string_format(msg, ...)
	local args = { ... }
	for i, v in ipairs(args) do
		if type(v) == "table" then
			args[i] = vim.inspect(v)
		end
	end
	return string.format(msg, unpack(args))
end

return M
