local Component = require("commander.model.Component")
local theme = require("telescope._extensions.commander.theme")


---@class IntegrationConfig
---@field telescope {enable: boolean, theme: function}
---@field lazy {enable: boolean}

---@class Config
---@field components {[integer]: string} the components to be rendered in the propmt; possible values are DESC, KEYS, CMD, and CAT
---@field sort_by {[integer] : string } the default ordering of commands in the prompt; possible values are DESC, KEYS, CMD, and CAT
---@field separator string the separator between each component in the prompt
---@field auto_replace_desc_with_cmd boolean automatically replace empty desc with cmd
---@field integration IntegrationConfig | nil
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
---@return Config the default configuration
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
    prompt_title = "Command Center",

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
---@param config Config
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

---Merge config into self iff config is valid
---@param config Config | nil
---@return string | nil err_msg
function Config:merge(config)
  if config == nil or config == {} then return nil end

  local mergedConfig = vim.tbl_deep_extend("force", self, config)

  local err = validate(mergedConfig)
  if err then
    vim.notify("Commander.nvim: setup failed; " .. err)
  else
    -- Update self
    for k, v in pairs(mergedConfig) do
      self[k] = mergedConfig[k]
    end
  end
end

-- ---@param intConfigDefault IntegrationConfig
-- ---@param intConfigNew IntegrationConfig
-- local function merger_integration(intConfigDefault, intConfigNew)
--   if intConfigNew == nil then return intConfigDefault, nil end
--
--   local mergedConfig = vim.tbl_deep_extend("keep", intConfigDefault, intConfigNew)
--
--   local err
--
--   _, err = pcall(vim.validate, {
--     ["integration.enable"] = { mergedConfig.telescope.enable, "boolean", true },
--     ["integration.theme"] = { mergedConfig.telescope.theme, "boolean", true },
--   })
--   if err then return intConfigDefault, err end
--
--   _, err = pcall(vim.validate, {
--     ["lazy.enable"] = { mergedConfig.lazy.enable, "boolean", true },
--   })
--   if err then return intConfigDefault, err end
--
--   return mergedConfig
-- end
--
-- ---Validate the passed config
-- ---@param config Config
-- ---@return boolean isValid
-- ---@return string error
-- local function validate(config)
--   local _, err = pcall(vim.validate, {
--     separator = { config.separator, "string", true },
--     auto_replace_desc_with_cmd = { config.auto_replace_desc_with_cmd, "boolean", true },
--     prompt_title = { config.prompt_title, "string", true },
--   })
--
--   if err then
--     return false, err
--   end
--
--   local function keys(tbl)
--     local keys = {}
--     for k, v in pairs(tbl) do
--       keys[#keys + 1] = k
--     end
--     return keys
--   end
--
--   local function validate_cmps(name, cmps)
--     for i, cmp in ipairs(cmps) do
--       _, err = pcall(vim.validate, {
--         [name .. "[" .. i .. "]"] = {
--           cmp, function(cmp) return Component[cmp] ~= nil end,
--           "one of " .. vim.inspect(keys(Component))
--         }
--       })
--     end
--     if err then return err end
--   end
--
--   err = validate_cmps("components", config.components)
--   if err then return false, err end
--
--   err = validate_cmps("sorted_by", config.sort_by)
--   if err then return false, err end
-- end
--
-- ---Validate and parse the given config
-- ---@param config Config
-- ---@return Config config
-- function Config:update(config)
--   local _, err = pcall(vim.validate, {
--     separator = { config.separator, "string", true },
--     auto_replace_desc_with_cmd = { config.auto_replace_desc_with_cmd, "boolean", true },
--     prompt_title = { config.prompt_title, "string", true },
--   })
--
--   if err then
--     vim.notify(err)
--     return self
--   end
--
--   local function validate_cmp(cmp)
--     return Component[cmp] ~= nil
--   end
--
--   for i, cmp in ipairs(config.components) do
--     _, err = pcall(vim.validate, {
--       ["components[" .. i .. "]"] = {
--         config.components[i], validate_cmp,
--         "Unexpected value " .. config.components[i]
--       }
--     })
--   end
--
--
--
--
--
--   local function validate_cmps(cmps)
--     if cmps == nil then return true end
--     for _, cmp in ipairs(cmps) do
--       if not Component[cmp] then return false end
--     end
--   end
--
--   local _, err = pcall(vim.validate, {
--     components = {
--       config.components, validate_cmps,
--       "Unexpected value in list " .. vim.inspect(config.components)
--     }
--   })
--   if err then
--     vim.notify(err)
--   elseif config.components then
--     self.components = {}
--     for i, cmp in ipairs(config.components) do
--       self.components[i] = Component[cmp]
--     end
--   end
--
--   _, err = pcall(vim.validate, {
--     sort_by = {
--       config.sort_by, validate_cmps,
--       "Unexpected value in list " .. vim.inspect(config.components)
--     }
--   })
--   if err then
--     vim.notify(err)
--   elseif config.sort_by then
--     self.sort_by = {}
--     for i, cmp in ipairs(config.sort_by) do
--       self.sort_by[i] = Component[cmp]
--     end
--   end
--
--   _, err = pcall(vim.validate, {
--     separator = { config.separator, "string", true },
--   })
--   if not err then
--     self.separator = config.separator or self.separator
--   else
--     vim.notify(err)
--   end
--
--   _, err = pcall(vim.validate, {
--     auto_replace_desc_with_cmd = { config.auto_replace_desc_with_cmd, "boolean", true },
--   })
--   if not err then
--     self.auto_replace_desc_with_cmd = config.auto_replace_desc_with_cmd or self.auto_replace_desc_with_cmd
--   else
--     vim.notify(err)
--   end
--
--   _, err = pcall(vim.validate, {
--     prompt_title = { config.prompt_title, "string", true },
--   })
--   if not err then
--     self.prompt_title = config.prompt_title or self.prompt_title
--   else
--     vim.notify(err)
--   end
--
--   _, err = pcall(vim.validate, {
--     integration = { config.integration, "table", true }
--   })
--
--   if not err and config.integration then
--     _, err = pcall(vim.validate, {
--       ["integration.telescope"] = { config.integration.telescope, "table", true },
--       ["integration.telescope.enable"] = { config.integration.telescope.enable, "boolean", true }
--     })
--
--     if err then
--       vim.notify(err)
--     elseif config.integration.telescope and config.integration.telescope.enable then
--       local telescope_avail, telescope = pcall(require, "telescope")
--       if telescope_avail then
--         telescope.load_extension("commander")
--         self.integration.telescope = config.integration.telescope
--       else
--         vim.notify("Commander.nvim: can't integrate with telescope; telescope is not installed")
--       end
--     end
--
--     _, err = pcall(vim.validate, {
--       ["integration.lazy"] = { config.integration.lazy, "table", true },
--       ["integration.lazy.enable"] = { config.integration.lazy.enable, "boolean", true }
--     })
--     if err then
--       print(err)
--       vim.notify(err)
--     elseif config.integration.lazy and config.integration.lazy.enable then
--       local lazy_avail, _ = pcall(require, "lazy")
--       if lazy_avail then
--         self.integration.lazy = config.integration.lazy
--       else
--         vim.notify("Commander.nvim: can't integrate with lazy; lazy is not installed")
--       end
--     end
--   end
--
--   return self
-- end

return Config
