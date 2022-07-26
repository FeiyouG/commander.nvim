local M = {}

local utils = require("command_center.utils")

local constants = require("command_center.constants")
local component = constants.component
local max_length = constants.max_length
local cc_mode = constants.mode

-- Actual comamnd_center.items are stored here
M.items = {}
M._duplicate_detector = {}


M.add = function(passed_items, mode)

  -- Early exit from the function if passed in an empty table
  if not passed_items then return end

  -- Add and register keybindings by defualt
  mode = mode or constants.mode.ADD_AND_REGISTER

  for _, item in ipairs(passed_items) do

    -- Deep copy item to avoid modifying the parameter
    item = vim.deepcopy(item)

    if item.command then
      utils.warn_once("`command` is deprecated in favor of `cmd`. See README.md for detail.")
    end

    -- Ignore entries that do not have comands
    if not item.cmd and not item.command then goto continue end

    -- Map command to cmd
    item.cmd = item.cmd or ("<cmd>" .. item.command .. "<CR>")
    item.cmd_str = type(item.cmd) == "function" and constants.lua_func_str or item.cmd

    -- Override mode if specified
    item.mode = item.mode or mode

    -- Emtpry category by defult
    item.category = item.category or ""


    -- Making sure description is not nil
    item.replace_desc_with_cmd = item.description or item.cmd_str
    item.description = item.description or ""

    -- Properly format keybindings for further process
    item.keybindings = utils.format_keybindings(item.keybindings)

    -- Get the string representation of the keybindings for display
    item.keybinding_str = utils.get_keybindings_string(item.keybindings)

    -- Ignore duplicate entries
    local key = item.cmd_str .. item.description .. item.keybinding_str

    if M._duplicate_detector[key] then goto continue end
    M._duplicate_detector[key] = true

    -- Register the keybindings (only if mode is not ADD_ONLY)
    if item.mode ~= cc_mode.ADD_ONLY then
      utils.register_keybindings(item.keybindings, item.cmd)
    end

    -- If REGISTER_ONLY, then we are done!
    if item.mode == cc_mode.REGISTER_ONLY then goto continue end

    -- Update maximum command length
    max_length[component.COMMAND_STR] = math.max(max_length[component.COMMAND_STR], #item.cmd_str)

    -- Update maximum description length
    max_length[component.DESCRIPTION] = math.max(max_length[component.DESCRIPTION], #item.description)

    -- And Update maximum keybinding length
    max_length[component.KEYBINDINGS_STR] = math.max(max_length[component.KEYBINDINGS_STR], #item.keybinding_str)

    max_length[component.CATEGORY] = math.max(max_length[component.CATEGORY], #item.category)

    -- This is used when user wants to replace desc with cmd
    max_length[component.REPLACE_DESC_WITH_CMD] = math.max(max_length[component.REPLACE_DESC_WITH_CMD], #item.replace_desc_with_cmd)

    -- Add the entry to M.items
    table.insert(M.items, {
      item.cmd,
      item.description,
      item.keybindings,
      item.category,
      item.cmd_str,
      item.keybinding_str,
      item.replace_desc_with_cmd,
      key
    })

    -- We need signal Telescop to cache again
    M.cached = false

    -- Label for end of an iteration
    ::continue::
  end
end

M.remove = function(items)
  -- Early exit from the function if passed in an empty table
  if not items then return end

  for _, item in ipairs(items) do

    -- Deep copy item to avoid modifying the parameter
    item = vim.deepcopy(item)

    -- Ignore entries that do not have comands
    if not item.cmd and not item.command then goto continue end

    -- Map command to cmd
    item.cmd = item.cmd or ("<cmd>" .. item.command .. "<CR>")
    item.cmd_str = type(item.cmd) == "function" and constants.lua_func_str or item.cmd

    -- Properly format keybindings for further process
    item.keybindings = utils.format_keybindings(item.keybindings)

    -- Get the string representation of the keybindings for display
    item.keybinding_str = utils.get_keybindings_string(item.keybindings)

    -- Check if item presents
    local key = item.cmd_str .. item.description .. item.keybinding_str

    -- If not present, ignore this item
    if not M._duplicate_detector[key] then goto continue end
    M._duplicate_detector[key] = nil

    -- Find the item from back to front to avoid dealing with
    -- shifted index when removing element
    for i = #M.items, 1, -1 do
      if (M.items[i][component.ID] == key) then
        table.remove(M.items, i)
      end
    end

    ::continue::
  end
end

-- Add some constants to M
-- to ease the customization of command center
M.mode = constants.mode
M.component = {
  COMMAND = constants.component.COMMAND_STR,
  DESCRIPTION = constants.component.DESCRIPTION,
  KEYBINDINGS = constants.component.KEYBINDINGS_STR,
  CATEGORY = constants.component.CATEGORY,
}

M.converter = require("command_center.converter")

return M
