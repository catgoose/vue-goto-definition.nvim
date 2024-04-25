local config = require("vue-goto-definition.config")
local import = require("vue-goto-definition.import")
local locationlist = require("vue-goto-definition.locationlist")
local Log = require("vue-goto-definition").Log
local sf = require("vue-goto-definition.utils").string_format

---@class List
---@field process fun(items: DefinitionItems, opts: table):nil
---@return List
local M = {}

local function log_process(items)
  if #items > 0 then
    Log.debug(sf(
      [[list.process: Processing %s list items:

    %s
    ]],
      #items,
      items
    ))
    if config.at_least_log_level("debug") then
      local filenames = {}
      for _, item in ipairs(items) do
        if item.filename then table.insert(filenames, item.filename) end
      end
      if #filenames > 0 then
        Log.debug(sf("list.process: Found %s files to process", #filenames))
        for _, filename in ipairs(filenames) do
          Log.debug(sf("list.process: %s", filename))
        end
      end
    end
  end
end

function M.process(items, opts)
  log_process(items)
  local path = import.get_path(items, opts)
  if path then
    Log.trace(sf("list.process: Found path: %s", path))
    vim.cmd.edit(path)
  else
    locationlist.open(items, opts)
  end
end

return M
