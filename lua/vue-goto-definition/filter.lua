local Log = require("vue-goto-definition").Log
local sf = require("vue-goto-definition.utils").string_format

---@class Filter
---@field items fun(items: DefinitionItems, opts: table):table
---@return Filter
local M = {}

local function log_status(method_name, items)
  local prefix = "filter._" .. method_name
  if #items == 0 then
    Log.debug(sf([[%s: filtered list is empty: returning original items]], prefix))
  else
    Log.debug(sf(
      [[%s: found %s items: 

%s
]],
      prefix,
      #items,
      items
    ))
  end
end

local function dedupe_filenames(items)
  local seen = {}
  local filtered = {}
  for _, item in ipairs(items) do
    if not seen[item.filename] then
      table.insert(filtered, item)
      seen[item.filename] = true
    end
  end
  log_status("dedupe_filenames", items)
  return #filtered == 0 and items or filtered
end

local function same_filename_lnum(items)
  local lnum = vim.api.nvim_win_get_cursor(0)[1]
  local filtered = vim.tbl_filter(
    function(item) return item.filename ~= vim.fn.expand("%:p") or item.lnum ~= lnum end,
    items
  )
  log_status("same_filename_lnum", items)
  return #filtered == 0 and items or filtered
end

local function dedupe_filename_lnum(items)
  local seen = {}
  local filtered = {}
  for _, item in ipairs(items) do
    local key = item.filename .. ":" .. item.lnum
    if not seen[key] then
      table.insert(filtered, item)
      seen[key] = true
    end
  end
  log_status("dedupe_filename_lnum", items)
  return #filtered == 0 and items or filtered
end

local function import_filters(items, opts)
  local filtered = vim.tbl_filter(function(item)
    local is_auto_import = opts.filters.auto_imports
      and item.filename:match(opts.patterns.auto_imports)
    local is_component = opts.filters.auto_components
      and item.filename:match(opts.patterns.auto_components)
    local is_same_file = opts.filters.import_same_file and item.filename == vim.fn.expand("%:p")
    return not is_auto_import and not is_component and not is_same_file
  end, items or {})
  log_status("import_filters", items)
  return #filtered == 0 and items or filtered
end

local function remove_declarations(items, opts)
  local filtered = vim.tbl_filter(
    function(item) return not item.filename:match(opts.patterns.declaration) end,
    items
  )
  log_status("remove_declarations", items)
  return #filtered == 0 and items or filtered
end

function M.items(items, opts)
  Log.debug(sf(
    [[filter.items: filtering %s items:

  %s
  ]],
    #items,
    items
  ))
  items = same_filename_lnum(items)
  items = dedupe_filename_lnum(items)
  if opts.filters.duplicate_filename then items = dedupe_filenames(items) end
  items = import_filters(items, opts)
  if #items < 2 then return items end
  if opts.filters.declaration then items = remove_declarations(items, opts) end
  Log.debug(sf(
    [[filter.items: returning %s filtered items:

  %s
  ]],
    #items,
    items
  ))
  return items
end

return M
