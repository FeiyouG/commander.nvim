local M = {}

local utils = require("command_center.utils")

local constants = require("command_center.constants")
local argument = constants.argument
local max_length = constants.max_length

M.items = {}

M.add = function(passed_items, mode)

  -- Add and register keymaps by defualt
  mode = mode or constants.add_mode.ADD_AND_REGISTER

  -- Default empty array
  passed_items = passed_items or {}

  for _, value in ipairs(passed_items) do

    -- Ignore entries that do not have comands
    if value.command then


      -- Update maximum description length
      max_length[argument.COMMAND] =
        math.max(max_length[argument.COMMAND], #value.command)

      -- If has keymaps specified
      if value.keymaps then
        value.keymaps = utils.format_keymap(value.keymaps)

        -- Set the keymap if requested by the user
        if (mode == constants.add_mode.REGISTER_ONLY or mode == constants.add_mode.ADD_AND_REGISTER) then
          utils.set_keymap(value.keymaps, value.command)
        end

        -- Get the string representation of the keymaps for display
        -- And Update maximum keymaps length
        value.keymaps_string = utils.get_keymaps_string(value.keymaps)
        max_length[argument.KEYMAPS] =
            math.max(max_length[argument.KEYMAPS], #value.keymaps_string)
      end

      -- Replace descirption with command if not exit
      -- And update maximum description length
      value.description = value.description or value.command
      max_length[argument.DESCRIPTION] =
          math.max(max_length[argument.DESCRIPTION], #value.description)


      -- Reformat value
      local formatted_value = {
        argument = {
          value.command,
          value.keymaps,
          value.description
        },
        cached = {
          keymaps_str = value.keymaps_string or ""
        }
      }

      -- P(formatted_value)
      -- Insert the vlaue into M
      table.insert(M.items, value)
    end

  end
end


return M
