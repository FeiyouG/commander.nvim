local Component = require("commander.model.Component")
local theme = require("telescope._extensions.commander.theme")

---@class CommanderIntegrationConfig
---@field telescope {enable: boolean, theme: function}
---@field lazy {enable: boolean, set_plugin_name_as_cat: boolean}

---@class CommanderConfig
---@field components string[] the components to be rendered in the propmt; possible values are DESC, KEYS, CMD, and CAT
---@field sort_by string[] the default ordering of commands in the prompt; possible values are DESC, KEYS, CMD, and CAT
---@field separator string the separator between each component in the prompt
---@field auto_replace_desc_with_cmd boolean automatically replace empty desc with cmd
---@field integration CommanderIntegrationConfig?
---@field prompt_title string the title of the prompt
local Config = {}
Config.__mt = { __index = Config }


---Return default configuration
---@return CommanderConfig the default configuration
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
    prompt_title = "Commander",

    integration = {
      telescope = {
        enable = false,
        theme = theme,
      },
      lazy = {
        enable = false,
        set_plugin_name_as_cat = false,
      }
    }

  }, Config.__mt)
end

---Validate passed config
---@param config CommanderConfig
---@return string | nil error
local function validate(config)
  local _, err = pcall(vim.validate, {
    separator = { config.separator, "string", true },
    auto_replace_desc_with_cmd = { config.auto_replace_desc_with_cmd, "boolean", true },
    prompt_title = { config.prompt_title, "string", true },
    ["integration.telescope.enable"] = { config.integration.telescope.enable, "boolean", true },
    ["integration.telescope.theme"] = { config.integration.telescope.theme, "function", true },
    ["integration.lazy.enable"] = { config.integration.lazy.enable, "boolean", true },
    ["integration.lazy.set_plugin_name_as_cat"] = { config.integration.lazy.set_plugin_name_as_cat, "boolean", true },
  })
  if err then return err end

  local function validate_cmps(name, cmps)
    local cmp_keys = {}
    for _, cmp in pairs(Component) do
      cmp_keys[#cmp_keys + 1] = cmp
    end

    for i, cmp in ipairs(cmps) do
      _, err = pcall(vim.validate, {
        [name .. "[" .. i .. "]"] = {
          cmp, function(x) return vim.tbl_contains(cmp_keys, x) end,
          "one of " .. vim.inspect(cmp_keys)
        }
      })
      if err then return err end
    end
  end

  err = validate_cmps("components", config.components)
  if err then return err end

  err = validate_cmps("sorted_by", config.sort_by)
  if err then return err end
end

---Merge config into self if and only if config is valid
---@param config CommanderConfig | nil
---@return string | nil err
function Config:merge(config)
  if config == nil or config == {} then return nil end

  -- Clean up
  if config.components ~= nil then
    local components = {}
    for _, cmp in ipairs(config.components or {}) do
      if Component[cmp] ~= nil then
        components[#components + 1] = Component[cmp]
      end
    end
    config.components = components
  end

  if config.sort_by ~= nil then
    local sort_by = {}
    for _, cmp in ipairs(config.sort_by or {}) do
      if Component[cmp] ~= nil then
        sort_by[#sort_by + 1] = Component[cmp]
      end
    end
    config.sort_by = sort_by
  end

  -- Merge
  local mergedConfig = vim.tbl_deep_extend("force", self, config)
  setmetatable(mergedConfig, Config.__mt)

  -- Validate
  local err = validate(mergedConfig)
  if err then
    vim.notify("Commander.nvim: setup failed; " .. err)
    return
  end

  -- Update self
  for k, v in pairs(mergedConfig) do
    self[k] = v
  end

  for i, cmp in ipairs(self.components) do
    if self.auto_replace_desc_with_cmd and cmp == "DESC" then
      self.components[i] = Component.non_empty_desc
    end
  end
end

return Config
