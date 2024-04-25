local config = require("vue-goto-definition.config")
local sf = require("vue-goto-definition.utils").string_format

---@class VueGotoDefinition
---@field setup fun(opts: table):nil
---@field goto_definition fun():nil
---@return VueGotoDefinition
local M = {}

local function framework_found()
  if not config.get_opts().framework then return end
  return true
end

local function log_no_framework(prefix) M.Log.debug(sf("%s: no framework detected", prefix)) end

function M.setup(opts)
  opts = opts or {}
  opts = config.set_opts(opts)
  M.Log = require("vue-goto-definition.logger").init()
  if not framework_found() then
    log_no_framework("init.setup")
    return
  end
  if opts.lsp.override_definition then
    require("vue-goto-definition.autocmd").override_definition()
  end
end

function M.goto_definition(opts)
  if not framework_found() then
    log_no_framework("init.goto_definition")
    return
  end
  require("vue-goto-definition.lsp").get_goto(opts)()
end

return M
