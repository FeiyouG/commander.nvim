---@class CommanderFilter
---@field mode? string
---@field cat? string
local Filter = {}
Filter.__mt = { __index = Filter }

---@return CommanderFilter filter the default empty filter
function Filter:default()
  return setmetatable({
    mode = nil,
    cat = nil,
  }, Filter.__mt)
end

---Parse a filter object
---@param filter CommanderFilter
---@return CommanderFilter?
---@return string? error
function Filter.parse(filter)
  filter = filter or {}

  local default = Filter:default()
  local mergedFilter = vim.tbl_deep_extend("keep", default, filter)
  setmetatable(mergedFilter, Filter.__mt)

  local _, err = pcall(vim.validate, {
    mode = { mergedFilter.mode, "string", true },
    cat = { mergedFilter.cat, "string", true },
  })

  if err then
    return nil, err
  end

  return mergedFilter, nil
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
