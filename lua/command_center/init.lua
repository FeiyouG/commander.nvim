local M = {}

local utils = require("command_center.utils")
local constants = require("command_center.constants")
local component = constants.component
local max_len = constants.max_len

---Process commands
---@param items table? commands to be processed
---@param opts table? additional options
---@param add_callback function? funciton to be excuted if item's `mode` contains `ADD`
---@param set_callback function? function to be executed if item's `mode` contains `SET`
local function process_commands(items, opts, set_callback, add_callback)

  -- Early exit from items is not an non-empty list
  if not utils.is_nonempty_list(items) then return end
  opts = utils.convert_opts(opts)

  for _, item in ipairs(items) do

    item = utils.convert_item(item, opts)
    if not item then goto continue end


    -- Register/unregister the keybindings
    if item.mode == constants.mode.SET or item.mode == constants.mode.ADD_SET then
      if type(set_callback) == "function" then
        set_callback(item.id, item)
      end
    end

    -- Add/remove the item
    if item.mode == constants.mode.ADD or item.mode == constants.mode.ADD_SET then
      if type(add_callback) == "function" then
        add_callback(item.id, item)
      end
    end

    -- Label for end of an iteration
    ::continue::
  end
end

--Actual comamnd_center.items are stored here
M._items = {}

---Add commands into command_center if `mode` contains `ADD`;
---Set the keybindings in the command if `mode` constains `SET`
---@param items table? the list of commands to be removed; do nothing if nil or empty
---@param opts table? additional options
function M.add(items, opts)

  local set_callback = function(id, item)
    if M._items[id] then return end
    utils.set_converted_keys(item.keys)
  end

  local add_callback = function(id, item)
    if M._items[id] then return end

    -- Update max length
    for _, comp in pairs(constants.component) do
      if type(item[comp]) == "string" then
        max_len[comp] = math.max(max_len[comp], #item[comp])
      end
    end

    -- Add the entry to M.items as a list
    M._items[id] = item
  end

  process_commands(items, opts, set_callback, add_callback)
end

---Does the exact opposite as `command_center.add()`:
---* Remove the commands from `command_center` if `mode` contains `ADD`
---* Delete the keymaps if `mode` contains `SET`
---@param items table the list of commands to be removed; do nothing if nil or empty
---@param opts table? additional options; share the same format as the opts for `add()`
function M.remove(items, opts)

  local set_callback = function(id, item)
    if not M._items[id] then return end
    -- utils.delete_keybindings(item.keys, item.cmd)
    utils.del_converted_keys(item.keys)
  end

  local add_callback = function(id, _)
    if not M._items[id] then return end
    M._items[id] = nil
  end

  process_commands(items, opts, set_callback, add_callback)
end

-- MARK: Add some constants to M
-- to ease the customization of command center

M.converter = require("command_center.converter")

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

  -- @deprecated use `KEYS` instead
  CATEGORY = constants.component.CAT,

  CMD = constants.component.CMD_STR,
  DESC = constants.component.DESC,
  KEYS = constants.component.KEYS_STR,
  CAT = constants.component.CAT,
}


return M
