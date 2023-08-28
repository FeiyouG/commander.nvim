local keymap_modes = { "n", "v", "x", "s", "o", "!", "i", "l", "c", "t", }


---@class CommanderItemKey
---@field [1] string | string[] mode or a list of modes
---@field [2] string lhs of this keymap
---@field [3] table | nil same opts accepted by nvim.keymap.set

---@class CommanderKeymap
---@field modes string[]
---@field lhs string
---@field opts table | nil
local Keymap = {}
Keymap.__mt = { __index = Keymap }

---Parse an item into Keymap object
---@param itemKey CommanderItemKey
---@return CommanderKeymap | nil
---@return string | nil
function Keymap:parse(itemKey)
  itemKey = itemKey or {}
  local keymap = setmetatable({}, Keymap.__mt)

  -- 1, parse item
  keymap.modes = type(itemKey[1]) == "table" and itemKey[1] or { itemKey[1] }
  keymap.lhs = itemKey[2]
  keymap.opts = itemKey[3] or {}

  -- 2, validate lhs and opts
  local _, err = pcall(vim.validate, {
    ["[2]"] = { keymap.lhs, "string", false },
    ["[3]"] = { keymap.opts, "table", true },
  })

  if err then
    return nil, err
  end

  -- 3, validate modes
  local err = "[1]: expected vim-mode(s) (one or a list of "
      .. vim.inspect(keymap_modes)
      .. "), got "
      .. vim.inspect(itemKey[1])
  if not itemKey[1] then
    return nil, err
  end

  for _, mode in ipairs(keymap.modes) do
    if not vim.tbl_contains(keymap_modes, mode) then
      return nil,
          "[1]: expected vim-mode(s) (one or a list of " .. vim.inspect(keymap_modes) .. "), got " .. vim.inspect(
            itemKey[1]
          )
    end
  end

  return keymap, nil
end

--- Set this keymap
---@param rhs string | function the rhs of the keymap to be set
function Keymap:set(rhs)
  vim.keymap.set(self.modes, self.lhs, rhs, self.opts)
end

--- Unset this keymap
function Keymap:unset()
  vim.keymap.del(self.modes, self.lhs, self.opts)
end

---Return the string representation of the lhs of this keymap
---@return string
function Keymap:str()
  local str = ""
  for i, mode in ipairs(self.modes) do
    if i > 1 then
      str = str .. ","
    end

    str = str .. mode
  end

  str = str .. "|"

  str = str .. self.lhs

  return str
end

return Keymap
