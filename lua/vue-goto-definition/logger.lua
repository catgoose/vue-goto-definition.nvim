local config = require("vue-goto-definition.config")
local sf = require("vue-goto-definition.utils").string_format
local utils = require("vue-goto-definition.utils")

---@class Logger
---@field log table
---@field init fun()
---@return Logger
local M = {}

M.log = nil

function M.init()
	M.log = require("plenary.log").new({
		plugin = "vue-goto-definition",
		level = config.get_opts().log_level,
		fmt_msg = function(_, mode_name, src_path, src_line, msg)
			local nameupper = mode_name:upper()
			local lineinfo = vim.fn.fnamemodify(src_path, ":t") .. ":" .. src_line
			local log_message = sf("[%s %s] %s: %s", nameupper, os.date("%H:%M:%S"), lineinfo, msg)
			return log_message
		end,
	})
	return M.log
end

function M.at_least_level(find_level)
	local opts = config.get_opts()
	local log_levels = opts.log_levels
	local cur_i = utils.find_index(log_levels, opts.log_level)
	local find_i = utils.find_index(log_levels, find_level)
	return find_i <= cur_i
end

return M
