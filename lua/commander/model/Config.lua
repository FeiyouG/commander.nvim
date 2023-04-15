local Component = require("commander.model.Component")
local theme = require("telescope._extensions.commander.theme")

---@class Config
---@field components {[integer]: Component} the components to be rendered in the propmt
---@field sort_by {[integer] : Component } the default ordering of commands in the prompt
---@field separator string the separator between each component in the prompt
---@field auto_replace_desc_with_cmd boolean automatically replace empty desc with cmd
---@field telescope {[string]: any} | nil
---@field prompt_title string the title of the prompt
local Config = {}
Config.__mt = { __index = Config }

---Return default configuration
---@return Config the default configuration
function Config:new()
  return setmetatable({
    components = {
      Component.DESC,
      Component.KEYS,
      Component.CMD,
      Component.CAT,
    },

    sort_by = {
      Component.DESC,
      Component.KEYS,
      Component.CMD,
      Component.CAT,
    },

    separator = " ",
    auto_replace_desc_with_cmd = true,
    prompt_title = "Command Center",

    telescope = {
      integrate = false,
      theme = theme,
    },
  }, Config.__mt)
end

-- MARK: Public methods

---Update config
---@param config Config
---@return Config updated config
function Config:update(config)
  self.components = config.components or self.components
  self.sort_by = config.sort_by or self.sort_by
  self.separator = config.separator or self.separator
  self.auto_replace_desc_with_cmd = config.auto_replace_desc_with_cmd or self.auto_replace_desc_with_cmd
  self.prompt_title = config.prompt_title or self.prompt_title

  -- Replace desc with cmd if desc is empty
  if self.auto_replace_desc_with_cmd then
    for i, component in ipairs(self.components) do
      if component == Component.DESC then
        self.components[i] = Component.NON_EMPTY_DESC
      end
    end
  end

  if config.telescope and config.telescope.integrate then
    self.telescope.integrate = true
    self.theme = config.theme or self.theme

    if self.telescope.integrate == true then
      local has_telescope, telescope = pcall(require, "telescope")
      if has_telescope then
        ---@deprecated
        telescope.load_extension("command_center")
        telescope.load_extension("commander")
      end
    end
  end

  return self
end

return Config
