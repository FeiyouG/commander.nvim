local M = {}

local utils = require("command_center.utils")

local constants = require("command_center.constants")
local component = constants.component
local max_length = constants.max_length
local add_mode = constants.mode

-- Actual comamnd_center.items are stored here
M.items = {}
M._duplicate_detector = {}


M.add = function(passed_items, mode)

  -- Early return from the function if passed in an empty table
  if not passed_items then return end

  -- Add and register keybindings by defualt
  mode = mode or constants.mode.ADD_AND_REGISTER

  for _, value in ipairs(passed_items) do

    if value.command then
      utils.warn_command_deprecated()
    end

    -- Ignore entries that do not have comands
    if not value.cmd and not value.command then goto continue end

    -- Map command to cmd
    value.cmd = value.cmd or ("<cmd>" .. value.command .. "<CR>")
    value.cmd_str = type(value.cmd) == "function" and constants.lua_func_str or value.cmd

    -- Override mode if specified
    value.mode = value.mode or mode

    -- Making sure description is not nil
    value.replace_desc_with_cmd = value.description or value.cmd_str
    value.description = value.description or ""

    -- Properly format keybindings for further process
    value.keybindings = utils.format_keybindings(value.keybindings)

    -- Get the string representation of the keybindings for display
    value.keybinding_str = utils.get_keybindings_string(value.keybindings)

    -- Ignore duplicate entries
    local key = value.cmd_str .. value.description ..
      value.keybinding_str .. value.mode

    if M._duplicate_detector[key] then goto continue end
    M._duplicate_detector[key] = true

    -- Register the keybindings (only if mode is not ADD_ONLY)
    if value.mode ~= add_mode.ADD_ONLY then
      utils.register_keybindings(value.keybindings, value.cmd)
    end

    -- If REGISTER_ONLY, then we are done!
    if value.mode == add_mode.REGISTER_ONLY then goto continue end

    -- Update maximum command length
    max_length[component.COMMAND_STR] =
      math.max(max_length[component.COMMAND_STR], #value.cmd_str)

    -- Update maximum description length
    max_length[component.DESCRIPTION] =
      math.max(max_length[component.DESCRIPTION], #value.description)

    -- And Update maximum keybinding length
    max_length[component.KEYBINDINGS_STR] =
      math.max(max_length[component.KEYBINDINGS_STR], #value.keybinding_str)

    -- This is used when user wants to replace desc with cmd
    max_length[component.REPLACE_DESC_WITH_CMD] =
      math.max(max_length[component.REPLACE_DESC_WITH_CMD], #value.replace_desc_with_cmd)

    -- Add the entry to M.items
    table.insert(M.items, {
      value.cmd,
      value.description,
      value.keybindings,
      value.cmd_str,
      value.keybinding_str,
      value.replace_desc_with_cmd,
    })

    -- We need signal Telescop to cache again
    M.cached = false

    -- Label for end of an iteration
    ::continue::
  end
end

-- Add some constants to M
-- to ease the customization of command center
M.mode = constants.mode
M.component = {
  COMMAND = constants.component.COMMAND_STR,
  DESCRIPTION = constants.component.DESCRIPTION,
  KEYBINDINGS = constants.component.KEYBINDINGS_STR
}

return M
