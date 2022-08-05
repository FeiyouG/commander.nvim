-- Mimic enum in C
local M = {}

M.component = {
  -- public
  CMD = "cmd",
  DESC = "desc",
  KEYS = "keys",
  CAT = "cat",

  -- Private
  CMD_STR = "cmd_str",
  KEYS_STR = "keys_str",
  REPLACED_DESC = "replaced_desc",
  ID = "id",
}

M.mode = {
  ADD = 1,
  SET = 2,
  -- ADD_AND_REGISTER = 3,
}

-- Set the minimal length for each component to 8
local MINI_LEN = 8
M.max_len = {}
for _, component in pairs(M.component) do
  M.max_len[component] = MINI_LEN
end

M.anon_lua_func_name = "<anonymous> lua function"

M.keymap_modes = { "n", "i", "c", "x", "v" }

return M
