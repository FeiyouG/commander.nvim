local M = {}

local utils = require("command_center.utils")
local constants = require("command_center.constants")

local convert_to_helper = function(items, args_to_perserve)
  -- Early exit from the function if passed in an empty table
  if not items then return {} end

  local keybindings = {}

  for _, item in ipairs(items) do

    -- Make a deepcopy to avoid modifying parameters
    item = vim.deepcopy(item)

    -- Ignore entries that do not have comands
    if not item.cmd and not item.command then goto continue end

    -- Ignore if this is a ADD_ONLY keybindings
    if item.mode and item.mode == constants.mode.ADD_ONLY then goto continue end

    -- Map command to cmd
    item.cmd = item.cmd or ("<cmd>" .. item.command .. "<CR>")

    -- Making sure description is not nil
    item.replace_desc_with_cmd = item.description or item.cmd_str
    item.description = item.description or ""

    -- Properly format keybindings for further process
    item.keybindings = utils.format_keybindings(item.keybindings)

    for _, keybinding in ipairs(item.keybindings) do

      table.insert(keybinding, 3, item.cmd)
      keybinding[4]["desc"] = item.description

      if args_to_perserve and item[args_to_perserve] then
        utils.merge_tables(keybinding[4], item[args_to_perserve])
      end

      table.insert(keybindings, keybinding)
    end

    -- Label for end of an iteration
    ::continue::
  end

  return keybindings
end

M.to_nvim_set_keymap = function(commands)
  return convert_to_helper(commands)
end

M.to_hydra_heads = function(commands)
  local keybindings = convert_to_helper(commands, "hydra_head_args")

  for _, keybinding in ipairs(keybindings) do
    table.remove(keybinding, 1)
  end

  return keybindings
end


return M
