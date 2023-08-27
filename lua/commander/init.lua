local Layer = require("commander.model.Layer")
local Config = require("commander.model.Config")
local Component = require("commander.model.Component")

local converter = require("commander.converter")
local constants = require("commander.constants")

local M = {}

M.layer = Layer:new()
M.config = Config:new()

---Setup plugin with customized configurations
---@param config Config
function M.setup(config)
  M.config:merge(config)
  M.layer:setup(config)

  if M.config.integration.lazy.enable then
    local cmds = converter.get_lazy_keys()
    M.layer:insert(cmds)
  end

  if M.config.integration.telescope.enable then
    local telescop_avail, telescope = pcall(require, "telescope")
    if telescop_avail then
      telescope.load_extension("commander")
    else
      vim.notify("Commander.nvim: telscope integration failed; telescope is not installed.")
    end
  end
end

function M.add(items, opts)
  local err = M.layer:add(items, opts)
  if err then
    vim.notify("commander will ignore the following incorrectly fomratted item:\n" .. err, vim.log.levels.WARN)
  end
end

function M.show(opts)
  opts = opts or {}
  M.layer:set_filter(opts.filter)

  if M.config.integration.telescope.integrate then
    vim.cmd("Telescope commander")        -- Use telecope
  else
    M.layer:select(M.config.prompt_title) -- Use vim.ui.select
  end
end

-- MARK: Add some constants to M
-- to ease the customization of command center
M.converter = converter

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
