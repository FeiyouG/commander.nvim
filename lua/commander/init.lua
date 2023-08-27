local Layer = require("commander.model.Layer")
local Config = require("commander.model.Config")

local converter = require("commander.converter")

local M = {}

M.layer = Layer:new()
M.config = Config:new()

---Setup plugin with customized configurations
---@param config CommanderConfig
function M.setup(config)
  M.config:merge(config)
  M.layer:setup(M.config)

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

---@param items CommanderItem[]
---@param opts CommanderAddOpts
function M.add(items, opts)
  local err = M.layer:add(items, opts)
  if err then
    vim.notify("Commander will ignore the following incorrectly fomratted item:\n" .. err, vim.log.levels.WARN)
  end

end

function M.show(opts)
  opts = opts or {}
  M.layer:set_filter(opts.filter)

  if M.config.integration.telescope.enable then
    vim.cmd("Telescope commander")        -- Use telecope
  else
    M.layer:select(M.config.prompt_title) -- Use vim.ui.select
  end
end

return M
