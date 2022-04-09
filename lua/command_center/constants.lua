-- Mimic enum in C
local constants = {}

constants.argument = {
  COMMAND = 1,
  DESCRIPTION = 2,
  KEYMAPS = 3,
}

constants.add_mode = {
  ADD_ONLY = 1,
  REGISTER_ONLY = 2,
  ADD_AND_REGISTER = 3,
}

-- Default (minimum) length for each argyment type
constants.max_length = { 20, 8, 15,}

return constants
