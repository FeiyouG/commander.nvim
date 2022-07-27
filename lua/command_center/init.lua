local M = {}

local utils = require("command_center.utils")

local constants = require("command_center.constants")
local component = constants.component
local max_length = constants.max_length
local cc_mode = constants.mode

-- Actual comamnd_center.items are stored here
M._items = {}

M.add = function(passed_items, opts)

  -- Early exit from if passed in an empty table
  if not passed_items then return end

  opts = opts or {}

  local mode = opts
  if type(opts) == "table" then
    mode = opts.mode
  end

  for _, item in ipairs(passed_items) do

    -- Deep copy item to avoid modifying the parameter
    item = vim.deepcopy(item)

    -- Validate and configure cmd
    item.cmd = item.cmd or item.command
    if not item.cmd then goto continue end
    item.cmd_str = type(item.cmd) == "function" and constants.lua_func_str or item.cmd

    -- Configure mode and category
    item.mode = item.mode or mode or constants.mode.ADD_AND_REGISTER
    item.category = item.category or opts.category or ""

    -- Configure desc
    item.desc = item.desc or item.description or ""
    item.replaced_desc = item.desc ~= "" and item.desc or item.cmd_str

    -- Configure keys
    item.keys = item.keys or item.keybindings
    item.keys = utils.format_keybindings(item.keys)
    item.keys_str = utils.get_keybindings_string(item.keys)

    -- Check for duplications
    local id = item.cmd_str .. item.desc .. item.keys_str
    if M._items[id] then goto continue end

    -- Register the keybindings (only if mode is not ADD_ONLY)
    if item.mode > cc_mode.ADD_ONLY then
      utils.register_keybindings(item.keys, item.cmd)
    end

    -- If REGISTER_ONLY, then we are done!
    if item.mode == cc_mode.REGISTER_ONLY then goto continue end

    -- Update max length
    max_length[component.CMD_STR] = math.max(max_length[component.CMD_STR], #item.cmd_str)
    max_length[component.DESC] = math.max(max_length[component.DESC], #item.desc)
    max_length[component.KEYS_STR] = math.max(max_length[component.KEYS_STR], #item.keys_str)
    max_length[component.CATEGORY] = math.max(max_length[component.CATEGORY], #item.category)
    max_length[component.REPLACED_DESC] = math.max(max_length[component.REPLACED_DESC], #item.replaced_desc)

    -- Add the entry to M.items
    M._items[id] = {
      item.cmd,
      item.desc,
      item.keys,
      item.category,
      item.cmd_str,
      item.keys_str,
      item.replaced_desc,
    }

    -- Label for end of an iteration
    ::continue::
  end
end

M.remove = function(items)

  -- Early exit if passed in an empty table
  if not items then return end

  for _, item in ipairs(items) do

    --- Deep copy item to avoid modifying the parameter
    item = vim.deepcopy(item)

    -- Validate and configure cmd
    item.cmd = item.cmd or item.command
    if not item.cmd then goto continue end
    item.cmd_str = type(item.cmd) == "function" and constants.lua_func_str or item.cmd

    -- Configure desc
    item.desc = item.desc or item.description or ""

    -- Configure keys
    item.keys = item.keys or item.keybindings
    item.keys = utils.format_keybindings(item.keys)
    item.keys_str = utils.get_keybindings_string(item.keys)

    -- Remove the entry
    local id = item.cmd_str .. item.desc .. item.keys_str
    M._items[id] = nil

    ::continue::
  end
end

-- Add some constants to M
-- to ease the customization of command center
M.mode = constants.mode
M.component = {
  COMMAND = constants.component.CMD_STR,
  DESCRIPTION = constants.component.DESC,
  KEYBINDINGS = constants.component.KEYS_STR,
  CATEGORY = constants.component.CATEGORY,
}

M.converter = require("command_center.converter")

return M
