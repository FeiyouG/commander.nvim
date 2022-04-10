-- Mimic enum in C
local constants = {}

constants.component = {
  COMMAND = 1,
  DESCRIPTION = 2,
  KEYBINDINGS = 3,
}

constants.private_component = {
  REPLACE_DESC_WITH_CMD = 4
}

constants.mode = {
  ADD_ONLY = 1,
  REGISTER_ONLY = 2,
  ADD_AND_REGISTER = 3,
}

-- Default (minimum) length for each argyment type
-- In the order of constants.component + if_replace_desc_with_cmd
constants.max_length = { 8, 8, 8, 8}

return constants
