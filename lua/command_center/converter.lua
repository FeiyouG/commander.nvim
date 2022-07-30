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
        keymap[4] = vim.tbl_extend("force", keymap[4], item[args_to_perserve])
      end

      table.insert(res, keymap)
    end

    ::continue::
  end

  return res
end

local convert_from_helper = function(items)
  -- Early exit from the function if passed in an empty table
  if not items then return {} end

  local res = {}

  for _, item in ipairs(items) do

    --- { mode, lhs, rhs [, opts] }
    if #item < 3 then return end

    item = vim.deepcopy(item)
    local converted_item = {}

    converted_item.cmd = item[3]

    if #item >= 4 then
      converted_item.desc = item[4].desc
    end

    converted_item.keys = { item[1], item[2], item[4] }


    table.insert(res, converted_item)
  end

  return res
end

---Converts a list of commands used by `command_center`
--- ```lua
---{
---  {
---    desc = ... -- will be inserted into opts
---    cmd = ...
---    keys = { mode, lhs [, opts]}
---  }
---}
---```
---to the format used by `nvim_set_keymap`:
---```lua
---{
--- { mode, lhs, rhs [, opts] }
---}
---```
---@param commands table?: the commands to be converted
M.to_nvim_set_keymap = function(commands)
  return convert_to_helper(commands)
end

---Converts a list of commands used by `command_center`
--- ```lua
---{
---  {
---    desc = ...
---    cmd = ...
---    keys = { mode, lhs [, opts]},
---    hydra_head_args = { ... } -- e.g. optional hydra specific opts; e.g { exit = true }
---  }
---}
---```
---to the format used by `hydra.nvim`'s heads:
---```lua
---{
--- { lhs, rhs [, opts] }
---}
---```
---@param commands table?: the commands to be converted
M.to_hydra_heads = function(commands)
  local keybindings = convert_to_helper(commands, "hydra_head_args")

  for _, keybinding in ipairs(keybindings) do
    -- remove mode
    table.remove(keybinding, 1)
  end

  return keybindings
end


---Converts a list of commands used by `nvim_set_keymap`:
---```lua
---{
--- { mode, lhs, rhs [, opts] }
---}
---```
---to the format used by `command_center`:
--- ```lua
---{
---  {
---    desc = ... -- will be inserted into opts
---    cmd = ...
---    keys = { mode, lhs [, opts]}
---  }
---}
---```
---@param commands table?: the commands to be converted
M.from_nvim_set_keymap = function(commands)
  return convert_from_helper(commands)
end


return M
