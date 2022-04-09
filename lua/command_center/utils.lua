local constants = require("command_center.constants")

local utils = {}

-- Convert keymaps to a 2D array if it is passed in as an array of single keymap
-- then sort the array based on mode
utils.format_keymap = function(keymaps)
  if #keymaps >=2 and #keymaps <= 3 and type(keymaps[1]) == "string" then
    keymaps = { keymaps }
  end

  local res = {}
  for _, value in ipairs(keymaps or {}) do
    if #value < 2 or type(value[1]) ~= "string" or type(value[2]) ~= "string" then
      print("Bad Keymaps")
    else
      table.insert(res, value)
    end
  end

  table.sort(res, function(lhs, rhs) return lhs[1] < rhs[2] end)
  return res
end

-- Set the keymaps if they are valid
-- Assumes:
---- keymaps are properly formatte (by calling format_keymap)
utils.set_keymap = function(keymaps, command)
  for _, value in ipairs(keymaps or {}) do
    vim.api.nvim_set_keymap(value[1], value[2], "<cmd>" .. command .. "<cr>", value[3] or {})
  end
end

-- Generate the string representation of keymaps
-- Assumes:
---- keymaps are properly formatte (by calling format_keymap)
utils.get_keymaps_string = function(keymaps)
  local res = ""
  local mode
  for i, value in ipairs(keymaps or {}) do
    if i == 1 then
      mode = value[1]
      res = mode .. "|" .. value[2]
    else
      if value[1] == mode then
        res = res .. "," .. value[2]
      else
        mode = value[1]
        res = res .. "; " .. mode .. "|" .. value[2]
      end
    end
  end
  return res
end

-- Get the max width of the result display
-- takes into consideration of the length of each arguments
-- and what arguments to display
-- @param arguments   An array specifying what arugmetns to display and in what order
-- @param length      a table contains the max length for each argument types
-- @param seperator   the seperator used, default to " "
utils.get_max_width = function(arguments, length, seperator)
  arguments = arguments or {
    constants.argument.DESCRIPTION,
    constants.argument.KEYMAPS,
    constants.argument.COMMAND,
  }
  length = length or constants.max_length
  seperator = seperator or " "

  local max_width = 0
  for i, argument in ipairs(arguments) do
    max_width = max_width + length[argument]

    if i > 0 then
      max_width = max_width + #seperator
    end

  end

  return max_width + 6 -- Leave some margin at the end
end

-- Merge the key value pairs of table1 into table2
utils.merge_tables = function(table1, table2)
  for k,v in pairs(table2) do table1[k] = v end
end

return utils
