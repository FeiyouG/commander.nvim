local Layer = require("command_center.model.Layer")
local Config = require("command_center.model.Config")

local Component = require("command_center.model.Component")

local M = {}

M.layer = Layer:new()
M.config = Config:new()

---Setup plugin with customized configurations
---@param config Config
function M.setup(config)
  M.config:update(config)

  -- Replace desc with cmd if desc is empty
  if M.config.auto_replace_desc_with_cmd then
    for i, component in ipairs(M.config.components) do
      if component == Component.DESC then
        M.config.components[i] = Component.NON_EMPTY_DESC
      end
    end
  end

  M.layer:set_sorter(M.config.sort_by)
  M.layer:set_separator(M.config.separator)
  M.layer:set_displayer(M.config.components)
end

function M.add(items, opts)
  local err = M.layer:add(items, opts)
  if err then
    vim.notify("command_center ignores incorrectly fomratted item:\n" .. err, vim.log.levels.WARN)
  end
end

local constants = require("command_center.constants")

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
  ADD_SET = constants.mode.ADD_SET,
}

M.component = {
  -- @deprecated use `CMD` instead
  COMMAND = Component.CMD,

  -- @deprecated use `DESC` instead
  DESCRIPTION = Component.DESC,

  -- @deprecated use `KEYS` instead
  KEYBINDINGS = Component.KEYS,

  -- @deprecated use `KEYS` instead
  CATEGORY = Component.CAT,

  CMD = Component.CMD,
  DESC = Component.DESC,
  KEYS = Component.KEYS,
  CAT = Component.CAT,
}

return M
