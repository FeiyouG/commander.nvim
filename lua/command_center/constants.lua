-- Mimic enum in C
local M = {}

M.component = {
  -- public
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

M.mode = {
  ADD_ONLY = 1,
  REGISTER_ONLY = 2,
  ADD_AND_REGISTER = 3,
}

-- Set the minimal length for each component to 8
local MINI_LEN = 8
M.max_len = {}
for _, component in pairs(M.component) do
  M.max_len[component] = MINI_LEN
end

M.lua_func_desc = "Lua Function"

return M
