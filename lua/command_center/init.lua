local M = {}

local utils = require("command_center.utils")
local constants = require("command_center.constants")
local component = constants.component
local max_len = constants.max_len

local process_commands = function(items, opts, add_callback, register_callback)

  -- Early exit from if passed in an empty list
  if not items and
      not vim.tbl_islist(items) and
      not vim.tbl_isempty(items) then
    return
  end

  -- Configure opts (for backward capatibility)
  opts = opts and vim.deepcopy(opts) or {}
  if type(opts) == "number" then
    opts = { mode = opts }
  elseif type(opts) == "string" then
    opts = { category = opts }
  end

  for _, item in ipairs(items) do

    -- Deep copy item to avoid modifying the parameter
    item = vim.deepcopy(item)

    -- Validate and configure cmd
    item.cmd = item.cmd or item.command
    if not item.cmd then goto continue end
    item.cmd_str = type(item.cmd) == "function" and constants.lua_func_desc or item.cmd

    -- Configure mode and category
    item.mode = item.mode or opts.mode or constants.mode.ADD_AND_REGISTER
    item.category = item.category or opts.category or ""

    -- Configure desc
    item.desc = item.desc or item.description or ""
    item.replaced_desc = item.desc ~= "" and item.desc or item.cmd_str

    -- Configure keys
    item.keys = item.keys or item.keybindings
    item.keys = utils.format_keybindings(item.keys)
    item.keys_str = utils.get_keybindings_string(item.keys)

    -- Check for duplications
    local id = item.desc .. item.cmd_str .. item.keys_str
    if M._items[id] then goto continue end

    -- Register the keybindings (only if mode is not ADD_ONLY)
    if item.mode == constants.mode.ADD_ONLY or item.mode == constants.mode.ADD_AND_REGISTER then
      add_callback(id, item)
    end

    if item.mode == constants.mode.REGISTER_ONLY or item.mode == constants.mode.ADD_AND_REGISTER then
      register_callback(id, item)
    end

    -- Label for end of an iteration
    ::continue::
  end
end

-- Actual comamnd_center.items are stored here
M._items = {}

M.add = function(items, opts)

  local add_callback = function(id, item)
    -- Update max length
    max_len[component.CMD_STR] = math.max(max_len[component.CMD_STR], #item.cmd_str)
    max_len[component.DESC] = math.max(max_len[component.DESC], #item.desc)
    max_len[component.KEYS_STR] = math.max(max_len[component.KEYS_STR], #item.keys_str)
    max_len[component.CATEGORY] = math.max(max_len[component.CATEGORY], #item.category)
    max_len[component.REPLACED_DESC] = math.max(max_len[component.REPLACED_DESC], #item.replaced_desc)

    -- Add the entry to M.items as a list
    M._items[id] = {
      [component.CMD] = item.cmd,
      [component.DESC] = item.desc,
      [component.KEYS] = item.keys,
      [component.CATEGORY] = item.category,
      [component.CMD_STR] = item.cmd_str,
      [component.KEYS_STR] = item.keys_str,
      [component.REPLACED_DESC] = item.replaced_desc,
    }
  end

  local register_callback = function(_, item)
    utils.register_keybindings(item.keys, item.cmd)
  end

  process_commands(items, opts, add_callback, register_callback)

end

M.remove = function(items, opts)

  local add_callback = function(id, _)
    M._items[id] = nil
  end


  local register_callback = function(_, item)
    utils.delete_keybindings(item.keys, item.cmd)
  end

  process_commands(items, opts, add_callback, register_callback)

end

-- MARK: Add some constants to M
-- to ease the customization of command center

M.mode = constants.mode
M.converter = require("command_center.converter")

M.component = {
  -- @deprecated use CMD instead
  COMMAND = constants.component.CMD_STR,

  -- @deprecated use DESC instead
  DESCRIPTION = constants.component.DESC,

  -- @deprecated use KEYS instead
  KEYBINDINGS = constants.component.KEYS_STR,

  CMD = constants.component.CMD_STR,
  DESC = constants.component.DESC,
  KEYS = constants.component.KEYS_STR,
  CATEGORY = constants.component.CATEGORY,
}


return M
