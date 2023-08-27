---@class Filter
---@field mode string | nil
---@field cat string | nil
local Filter = {}
Filter.__mt = { __index = Filter }

---Return an empty filter object
function Filter:new()
  return setmetatable({}, nil)
end

---Parse a filter object
---@param filter table | nil
---@return Filter | nil
---@return string | nil error
function Filter:parse(filter)
  filter = filter or {}

  local _, err = pcall(vim.validate, {
    mode = { filter.mode, "string", true },
    cat = { filter.cat, "string", true },
    category = { filter.category, "string", true },
  })

  if err then
    return nil, err
  end

  return setmetatable({
    mode = filter.mode,
    cat = filter.cat or filter.category,
  }, Filter.__mt), nil
end

---Filter commands
---@param commands Command[]
---@return Command[]
function Filter:filter(commands)
  if not commands or #commands == 0 then
    return {}
  end

  return vim.tbl_filter(function(command)
    if not command.show then
      return false
    end

    if self.mode then
      local mode_match = false
      for _, keys in ipairs(command.keymaps) do
        mode_match = mode_match or vim.tbl_contains(keys.modes, self.mode)
      end
      if not mode_match then return false end
    end

    if self.cat then
      if command.cat ~= self.cat then
        return false
      end
    end

    return true
  end, commands)
end

return Filter
