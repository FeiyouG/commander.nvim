local M = {}

local utils = require("command_center.utils")

local constants = require("command_center.constants")
local component = constants.component
local max_length = constants.max_length
local add_mode = constants.add_mode

M.items = {}

M.add = function(passed_items, mode)

  -- Add and register keybindings by defualt
  mode = mode or constants.add_mode.ADD_AND_REGISTER

  -- Default empty array
  passed_items = passed_items or {}

  for _, value in ipairs(passed_items) do

    -- Ignore entries that do not have comands
    if value.command then

      -- Override mode if specified
      mode = value.mode or mode

      -- Replace descirption with command if not exit
      value.description = value.description or value.command

      -- Properly format keybindings for further process
      value.keybindings = utils.format_keybindings(value.keybindings)

      -- Register the keybindings
      -- Only if mode is not ADD_ONLY
      if mode ~= add_mode.ADD_ONLY then
        utils.register_keybindings(value.keybindings, value.command)
      end

      -- Update maximum description length
      -- And insert value to M.items
      -- Only if the command is going to be added to command_center
      if mode ~= add_mode.REGISTER_ONLY then

        max_length[component.COMMAND] =
          math.max(max_length[component.COMMAND], #value.command)

        max_length[component.DESCRIPTION] =
            math.max(max_length[component.DESCRIPTION], #value.description)

        -- Get the string representation of the keybindings for display
        -- And Update maximum keybinding length
        value.keybinding_str = utils.get_keybindings_string(value.keybindings)
        max_length[component.KEYBINDINGS] =
            math.max(max_length[component.KEYBINDINGS], #value.keybinding_str)

        -- Insert the vlaue into M
        -- The same order as it is defined in constans.compnent
        table.insert(M.items, {
          value.command,
          value.description,
          value.keybinding_str or "",
        })
      end

    end

  end

end


return M
