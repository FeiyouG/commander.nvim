local M = {}

local utils = require("command_center.utils")

local constants = require("command_center.constants")
local component = constants.component
local private_component = constants.private_component
local max_length = constants.max_length
local add_mode = constants.mode

-- Actual comamnd_center.items are stored here
M.items = {}

M.add = function(passed_items, mode)

  -- Early return from the function if passed in an empty table
  if not passed_items then return end

  -- Add and register keybindings by defualt
  mode = mode or constants.mode.ADD_AND_REGISTER

  for _, value in ipairs(passed_items) do

    -- Ignore entries that do not have comands
    if not value.command then goto continue end

    -- Override mode if specified
    value.mode = value.mode or mode

    -- Making sure description is not nil
    value.description = value.description or ""

    -- Properly format keybindings for further process
    value.keybindings = utils.format_keybindings(value.keybindings)

    -- Get the string representation of the keybindings for display
    value.keybinding_str = utils.get_keybindings_string(value.keybindings)

    -- Ignore duplicate entries
    local key = value.command .. value.description ..
                  value.keybinding_str .. value.mode
    if M.items[key] then goto continue end

    -- Register the keybindings (only if mode is not ADD_ONLY)
    if value.mode ~= add_mode.ADD_ONLY then
      utils.register_keybindings(value.keybindings, value.command)
    end

    -- If REGISTER_ONLY, then we are done!
    if value.mode == add_mode.REGISTER_ONLY then goto continue end


    -- And insert value to M.items
    -- Only if the command is going to be added to command_center

    -- Update maximum command length
    max_length[component.COMMAND] =
      math.max(max_length[component.COMMAND], #value.command)

    -- Update maximum description length
    max_length[component.DESCRIPTION] =
      math.max(max_length[component.DESCRIPTION], #value.description)

    -- And Update maximum keybinding length
    max_length[component.KEYBINDINGS] =
      math.max(max_length[component.KEYBINDINGS], #value.keybinding_str)

    -- This is used when user wants to replace desc with cmd
    if (value.description == "") then
      max_length[private_component.REPLACE_DESC_WITH_CMD] =
      math.max(max_length[private_component.REPLACE_DESC_WITH_CMD], #value.command)
    else
      max_length[private_component.REPLACE_DESC_WITH_CMD] =
      math.max(max_length[private_component.REPLACE_DESC_WITH_CMD], #value.description)

    end

    -- Add the entry to M.items
    M.items[key] = {
      value.command,
      value.description,
      value.keybinding_str
    }

    -- We need signal Telescop to cache again
    M.cached = false

    -- Label for end of an iteration
    ::continue::
  end
end

-- Add some constants to M
-- to ease the customization of command center
M.mode = constants.mode
M.component = constants.component

return M
