local Log = require("vue-goto-definition").Log
local sf = require("vue-goto-definition.utils").string_format
local filter = require("vue-goto-definition.filter")

---@class LocationList
---@field open fun(items: DefinitionItems, opts: table):nil
---@return LocationList
local M = {}

function M.open(items, opts)
  Log.debug(sf("locationlist.open: processing %s items", #items))
  local filtered = filter.items(items, opts)
  Log.trace(sf(
    [[locationlist.open: filtered items:

  %s]],
    filtered
  ))
  if #filtered > 0 then
    if #filtered == 1 then
      vim.cmd.edit(filtered[1].filename)
      vim.api.nvim_win_set_cursor(0, { filtered[1].lnum, items[1].col - 1 })
    else
      vim.fn.setloclist(0, filtered)
      vim.cmd.lopen()
    end
  end
end

return M
