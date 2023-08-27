local Component = require("commander.model.Component")
local theme = require("telescope._extensions.commander.theme")

---@class CommanderIntegrationConfig
---@field telescope {enable: boolean, theme: function}
---@field lazy {enable: boolean}

---@class CommanderConfig
---@field components string[] the components to be rendered in the propmt; possible values are DESC, KEYS, CMD, and CAT
---@field sort_by string[] the default ordering of commands in the prompt; possible values are DESC, KEYS, CMD, and CAT
---@field separator string the separator between each component in the prompt
---@field auto_replace_desc_with_cmd boolean automatically replace empty desc with cmd
---@field integration CommanderIntegrationConfig | nil
---@field prompt_title string the title of the prompt
local Config = {}
Config.__mt = { __index = Config }

local cmp_keys = {
  "DESC",
  "KEYS",
  "CMD",
  "CAT",
}

---Return default configuration
---@return CommanderConfig the default configuration
function Config:new()
  return setmetatable({
    components = {
      "DESC",
      "KEYS",
      "CMD",
      "CAT",
    },

    sort_by = {
      "DESC",
      "KEYS",
      "CMD",
      "CAT",
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
    ["integration.enable"] = { config.integration.telescope.enable, "boolean", true },
    ["integration.theme"] = { config.integration.telescope.theme, "function", true },
    ["lazy.enable"] = { config.integration.lazy.enable, "boolean", true },
  })
  if err then return err end

  local function validate_cmps(name, cmps)
    for i, cmp in ipairs(cmps) do
      _, err = pcall(vim.validate, {
        [name .. "[" .. i .. "]"] = {
          cmp, function(x) return vim.tbl_contains(cmp_keys, x) end,
          "one of " .. vim.inspect(cmp_keys)
        }
      })
    end
    if err then return err end
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

  local mergedConfig = vim.tbl_deep_extend("force", self, config)
  setmetatable(mergedConfig, Config.__mt)

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
    self.components[i] = Component[cmp]
    if self.auto_replace_desc_with_cmd and cmp == "DESC" then
      self.components[i] = Component.NON_EMPTY_DESC
    end
  end

  for i, cmp in ipairs(self.sort_by) do
    self.sort_by[i] = Component[cmp]
  end
end

return Config
