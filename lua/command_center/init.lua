local M = {}

local utils = require("command_center.utils")

M.items = {}

M.add = function(passed_item)
  for _, value in ipairs(passed_item or {}) do
    -- Ignore entries that do not have comand
    if value.command then
      table.insert(M.items, value)

      -- If has keymaps, register it
      if value.keymaps then
        utils.set_keymap(value.keymaps, value.command)
      end
    end
  end
end


return M
