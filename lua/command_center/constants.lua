-- Mimic enum in C
local constants = {}

constants.component = {
  CMD = 1,
  DESC = 2,
  KEYS = 3,
  CATEGORY = 4,

  -- Private
  CMD_STR = 5,
  KEYS_STR = 6,
  REPLACED_DESC = 7,
  ID = 8
}

constants.mode = {
  ADD_ONLY = 1,
  REGISTER_ONLY = 2,
  ADD_AND_REGISTER = 3,
}

-- Default (minimum) length for each argyment type
-- In the order of constants.component + if_replace_desc_with_cmd
constants.max_length = { nil, 8, nil, 8, 8, 8, 8, nil}

constants.lua_func_str = "Lua Function"

return constants
