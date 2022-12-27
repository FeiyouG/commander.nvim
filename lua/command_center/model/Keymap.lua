local constants = require("command_center.constants")

---@class Keymap
---@field modes {[integer]: string}
---@field lhs string
---@field opts {[integer]: string}
local Keymap = {}
Keymap.__mt = { __index = Keymap }

-- ---Create a new Keymap
-- ---@param modes {[integer]: string}
-- ---@param lhs string
-- ---@param rhs string | function
-- ---@param opts {[integer]: string} | nil
-- ---@return Keymap
-- function Keymap:new(modes, lhs, rhs, opts)
--   return setmetatable({
--     modes = modes,
--     lhs = lhs,
--     rhs = rhs,
--     opts = opts,
--   }, Keymap.__mt)
-- end

---Parse an item into Keymap
---@param item table
---@return Keymap | nil
---@return string | nil
function Keymap:parse(item)
  local keymap = setmetatable({}, Keymap.__mt)

  keymap.lhs = item[2]
  keymap.opts = item[3] or {}

  -- Check whether this is a valid command
  local _, err = pcall(vim.validate, {
    ["[2]"] = { keymap.lhs, "string", false },
    ["[3]"] = { keymap.opts, "table", true },
  })

  if err then
    return nil, err
  end

  keymap.modes = {}
  if type(item[1]) == "string" then
    item[1] = { item[1] }
  end

  for i, mode in ipairs(item[1]) do
    ---@diagnostic disable-next-line: redefined-local
    local _, err = pcall(vim.validate, {
      ["[1][" .. i .. "]"] = {
        mode,
        function(m)
          return vim.tbl_contains(constants.keymap_modes, m)
        end,
        "expect one of " .. vim.inspect(constants.keymap_modes) .. ", but got " .. mode,
      },
    })

    if err then
      return nil, err
    end

    table.insert(keymap.modes, mode)
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
