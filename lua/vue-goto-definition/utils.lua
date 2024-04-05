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

function M.find_index(list, item)
	for index, value in ipairs(list) do
		if value == item then
			return index
		end
	end
	return nil
end

return M
