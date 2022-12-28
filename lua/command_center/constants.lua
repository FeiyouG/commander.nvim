-- Mimic enum in C
local M = {}

M.mode = {
  ADD = 1,
  SET = 2,
  ADD_SET = 3,
}

M.anon_lua_func_name = "<anonymous> lua function"

M.keymap_modes = { "n", "i", "c", "x", "v", "t" }

return M
