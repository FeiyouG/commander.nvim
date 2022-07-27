local M = {}

local utils = require("command_center.utils")

local convert_to_helper = function(items, args_to_perserve)
  -- Early exit from the function if passed in an empty table
  if not items then return {} end

  local res = {}

  for _, item in ipairs(items) do

    -- Make a deepcopy to avoid modifying parameters
    item = vim.deepcopy(item)

    -- Valid and configure cmd
    item.cmd = item.cmd or item.command
    if not item.cmd then goto continue end

    -- Configure desc
    item.desc = item.desc or item.description or ""

    -- Configure keys
    item.keys = item.keys or item.keybindings
    item.keys = utils.format_keybindings(item.keys)

    -- Convert keybindings
    for _, keymap in ipairs(item.keys) do
      -- nvim_set_keymap({mode}, {lhs}, {rhs}, {*opts})

      -- insert cmd as rhs
      table.insert(keymap, 3, item.cmd)

      -- Insert desc into opts
      keymap[4]["desc"] = item.description

      -- Insert additional args to opts
      if args_to_perserve and item[args_to_perserve] then
        utils.merge_tables(keymap[4], item[args_to_perserve])
      end

      table.insert(res, keymap)
    end

    ::continue::
  end

  return res
end

M.to_nvim_set_keymap = function(commands)
  return convert_to_helper(commands)
end

M.to_hydra_heads = function(commands)
  local keybindings = convert_to_helper(commands, "hydra_head_args")

  for _, keybinding in ipairs(keybindings) do
    -- remove mode
    table.remove(keybinding, 1)
  end

  return keybindings
end


return M
