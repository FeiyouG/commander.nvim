-- Mimic enum in C
local constants = {}

constants.component = {
  COMMAND = 1,
  DESCRIPTION = 2,
  KEYBINDINGS = 3,

  -- Private
  COMMAND_STR = 4,
  KEYBINDINGS_STR = 5,
  REPLACE_DESC_WITH_CMD = 6,
}

constants.mode = {
  ADD_ONLY = 1,
  REGISTER_ONLY = 2,
  ADD_AND_REGISTER = 3,
}

-- Default (minimum) length for each argyment type
-- In the order of constants.component + if_replace_desc_with_cmd
constants.max_length = { nil, 8, nil,  8, 8, 8}

constants.lua_func_str = "Lua Function"

return constants
