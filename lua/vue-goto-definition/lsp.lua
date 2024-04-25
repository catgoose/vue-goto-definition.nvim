local items = require("vue-goto-definition.items")

---@class DefinitionItem
---@field col number
---@field filename string
---@field lnum number
---@field text string
---@field userdata table

---@alias DefinitionItems DefinitionItem[]

---@class Lsp
---@field get_goto fun():function
---@return Lsp
local M = {}

local lsp_definition = vim.lsp.buf.definition

local function get_definition() return lsp_definition end

function M.get_goto(opts)
  opts = opts or {}
  local on_list = {
    on_list = function(_list)
      if _list and _list.items and #_list.items > 0 then items.add(_list.items) end
    end,
  }
  local goto_fn = function()
    opts = vim.tbl_extend("keep", opts, on_list)
    local definition = get_definition()
    definition(opts)
  end
  return goto_fn
end

return M
