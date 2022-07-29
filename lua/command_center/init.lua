local M = {}

local utils = require("command_center.utils")
local constants = require("command_center.constants")
local component = constants.component
local max_len = constants.max_len

---Process commands
---@param items table? commands to be processed
---@param opts table? additional options
---@param add_callback function? funciton to be excuted if item's `mode` contains `ADD`
---@param register_callback function? function to be executed if item's `mode` contains `SET`
local process_commands = function(items, opts, register_callback, add_callback)

  -- Early exit from if passed in an empty list
  if not items and
      not vim.tbl_islist(items) and
      not vim.tbl_isempty(items) then
    return
  end

  -- Configure opts (for backward capatibility)
  opts = opts and vim.deepcopy(opts) or {}
  if type(opts) == "number" then
    opts = { mode = opts }
  elseif type(opts) == "string" then
    opts = { category = opts }
  end

  for _, item in ipairs(items) do

    -- Deep copy item to avoid modifying the parameter
    item = vim.deepcopy(item)

    -- Validate and configure cmd
    item.cmd = item.cmd or item.command
    if not item.cmd then goto continue end
    item.cmd_str = type(item.cmd) == "function" and constants.lua_func_desc or item.cmd

    -- Configure mode and category
    item.mode = item.mode or opts.mode or constants.mode.ADD_SET
    item.category = item.category or opts.category or ""

    -- Configure desc
    item.desc = item.desc or item.description or ""
    item.replaced_desc = item.desc ~= "" and item.desc or item.cmd_str

    -- Configure keys
    item.keys = item.keys or item.keybindings
    item.keys = utils.format_keybindings(item.keys)
    item.keys_str = utils.get_keybindings_string(item.keys)

    -- Get the id for this item
    local id = item.desc .. item.cmd_str .. item.keys_str

    -- Register/unregister the keybindings
    if item.mode == constants.mode.SET or item.mode == constants.mode.ADD_SET then
      if type(register_callback) == "function" then
        register_callback(id, item)
      end
    end

    -- Add/remove the item
    if item.mode == constants.mode.ADD or item.mode == constants.mode.ADD_SET then
      if type(add_callback) == "function" then
        add_callback(id, item)
      end
    end


    -- Label for end of an iteration
    ::continue::
  end
end

--Actual comamnd_center.items are stored here
M._items = {}

---* Add commands into command_center if `mode` contains `ADD`;
---* Set the keybindings in the command if `mode` constains `SET`
---@param items table? the list of commands to be removed; do nothing if nil or empty
---@param opts table? additional options
M.add = function(items, opts)

  local register_callback = function(_, item)
    if M._items[id] then return end
    utils.register_keybindings(item.keys, item.cmd)
  end

  local add_callback = function(id, item)
    if M._items[id] then return end

    -- Update max length
    max_len[component.CMD_STR] = math.max(max_len[component.CMD_STR], #item.cmd_str)
    max_len[component.DESC] = math.max(max_len[component.DESC], #item.desc)
    max_len[component.KEYS_STR] = math.max(max_len[component.KEYS_STR], #item.keys_str)
    max_len[component.CATEGORY] = math.max(max_len[component.CATEGORY], #item.category)
    max_len[component.REPLACED_DESC] = math.max(max_len[component.REPLACED_DESC], #item.replaced_desc)

    -- Add the entry to M.items as a list
    M._items[id] = {
      [component.CMD] = item.cmd,
      [component.DESC] = item.desc,
      [component.KEYS] = item.keys,
      [component.CATEGORY] = item.category,
      [component.CMD_STR] = item.cmd_str,
      [component.KEYS_STR] = item.keys_str,
      [component.REPLACED_DESC] = item.replaced_desc,
    }
  end


  process_commands(items, opts, register_callback, add_callback)

end

---Does the exact opposite as `command_center.add()`:
---* Remove the commands from `command_center` if `mode` contains `ADD`
---* Delete the keymaps if `mode` contains `SET`
---@param items table the list of commands to be removed; do nothing if nil or empty
---@param opts table? additional options; share the same format as the opts for `add()`
M.remove = function(items, opts)

  local register_callback = function(id, item)
    if not M._items[id] then return end
    utils.delete_keybindings(item.keys, item.cmd)
  end

  local add_callback = function(id, _)
    if not M._items[id] then return end
    M._items[id] = nil
  end

  process_commands(items, opts, register_callback, add_callback)

end

-- MARK: Add some constants to M
-- to ease the customization of command center

M.converter = require("command_center.converter")
M.mode = constants.mode
M.mode = {

  -- @deprecated use `ADD` instead
  ADD_ONLY = constants.mode.ADD,

  -- @deprecated use `SET` instead
  REGISTER_ONLY = constants.mode.SET,

  -- @deprecated use bitwise operator `ADD | SET` instead
  ADD_AND_REGISTER = constants.mode.ADD_SET,

  ADD = constants.mode.ADD,
  SET = constants.mode.SET,
  ADD_SET = constants.mode.ADD_SET
}

M.component = {
  -- @deprecated use `CMD` instead
  COMMAND = constants.component.CMD_STR,

  -- @deprecated use `DESC` instead
  DESCRIPTION = constants.component.DESC,

  -- @deprecated use `KEYS` instead
  KEYBINDINGS = constants.component.KEYS_STR,

  CMD = constants.component.CMD_STR,
  DESC = constants.component.DESC,
  KEYS = constants.component.KEYS_STR,
  CATEGORY = constants.component.CATEGORY,
}


return M
