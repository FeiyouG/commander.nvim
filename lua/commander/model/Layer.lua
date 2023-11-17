local Command = require("commander.model.Command")
local Filter = require("commander.model.filter")

---@class Layer
---@field commands {[integer]: CommanderCommand}
---@field private filter CommanderFilter specify which commands are going to be displayed
---@field private sorter {[integer] : Component} | nil  specify by what order the commands are diplayed
---@field private displayer {[integer]: Component} | nil specify which components of a command are displayed
---@field private separator string
---@field private is_cached_valid boolean
---@field private cache_commands {[integer]: CommanderCommand}
---@field private cache_component_length {[Component]: integer}
local Layer = {}
Layer.__mt = { __index = Layer }

---Create a new layer
---@overload fun(): Layer
---@return Layer
function Layer:new()
  return setmetatable({
    commands = {},
    sorter = nil,
    filter = Filter:default(),
    displayer = nil,
    separator = " ",

    is_cached_valid = false,
    cache_commands = {},
    cache_component_length = {},
  }, Layer.__mt)
end

---@param commands CommanderCommand[]
function Layer:insert(commands)
  if not commands or #commands == 0 then return end

  self.is_cache_valid = false
  for _, command in ipairs(commands) do
    table.insert(self.commands, command)
    command:set_keymaps()
  end
end

---Add a list of items to this layer
---@param items? CommanderItem[]
---@param opts? CommanderAddOpts
---@return string | nil error
function Layer:add(items, opts)
  if not items or #items == 0 then
    return nil
  end

  opts = opts or Command:default_add_opts()

  for _, item in ipairs(items) do
    local command, err = Command:parse(item, opts)
    if not command or err then
      return vim.inspect(item) .. "\n -> " .. err
    end
    self.is_cache_valid = false
    table.insert(self.commands, command)
    command:set_keymaps()
  end
end

function Layer:select(prompt_title)
  vim.ui.select(self:get_commands(), {
    prompt = prompt_title,
    format_item = function(command)
      local res = ""
      for _, component in ipairs(self.displayer) do
        local component_str = command[component]
        local num_space = self.cache_component_width[component] - #component_str
        while num_space > 0 do
          component_str = component_str .. " "
          num_space = num_space - 1
        end
        res = res .. component_str
      end
      return res
    end,
  }, function(choice)
    if choice then
      choice:execute()
    end
  end)
end

---Get filtered and sorted commands from this layer
---@return { [integer]: CommanderCommand }
function Layer:get_commands()
  self:validate_cache()
  return self.cache_commands
end

function Layer:get_length(component)
  self:validate_cache()
  return self.cache_component_width[component]
end

function Layer:get_component_length()
  self:validate_cache()
  return self.cache_component_width
end

---Get the max width needed to diplay the commands in this layer
---@return integer
function Layer:get_max_width()
  self:validate_cache()
  local max_length = 0
  for _, length in pairs(self.cache_component_width) do
    max_length = max_length + length + #self.separator
  end
  return max_length
end

---Return the number of commands within the layer (after filter)
---@return integer
function Layer:get_size()
  self:validate_cache()
  return #self.cache_commands
end

---Set all keymaps in this layer
function Layer:set_keymaps()
  for _, command in ipairs(self.commands) do
    command:set_keymaps()
  end
end

---Unset all keymaps in this layer
function Layer:unset_keymaps()
  for _, command in ipairs(self.commands) do
    command:unset_keymaps()
  end
end

---Update filter used by this layer
---@param f table
function Layer:set_filter(f)
  ---@diagnostic disable-next-line: redefined-local
  local filter, err = Filter.parse(f)

  if err then
    vim.notify("commander.nvim invalid filter\n" .. vim.inspect(filter) .. "\n" .. err)
    return
  end

  if self.filter ~= filter then
    self.filter = filter
    self.is_cached_valid = false
  end
end

---Update layer settings with the given config
---@param config CommanderConfig
function Layer:setup(config)
  self:set_sorter(config.sort_by)
  self:set_displayer(config.components)
  self:set_separator(config.separator)
end

---@private
---Update sorter used by this layer
---@param sorter {[integer]: Component} | nil
function Layer:set_sorter(sorter)
  if self.sorter ~= sorter then
    self.sorter = sorter
    self.is_cached_valid = false
  end
end

---@private
---Update displayer used by this layer
---@param displayer {[integer]: Component} | nil
function Layer:set_displayer(displayer)
  if self.displayer ~= displayer then
    self.displayer = displayer
    self.is_cached_valid = false
  end
end

---@private
function Layer:set_separator(separator)
  self.separator = separator
end

---@private
---Re-cache commands iff current cache is not valid
function Layer:validate_cache()
  if self.is_cached_valid then
    return
  end

  self.cache_commands = self.filter:filter(self.commands)

  if self.sorter then
    table.sort(self.cache_commands, function(a, b)
      for _, component in ipairs(self.sorter) do
        if a[component] ~= b[component] then
          return a[component] > b[component]
        end
      end
      return a.non_empty_desc > b.non_empty_desc
    end)
  end

  -- Update width
  self.cache_component_width = {}
  for _, command in ipairs(self.cache_commands) do
    for _, component in pairs(self.displayer) do
      self.cache_component_width[component] = self.cache_component_width[component] or 0
      self.cache_component_width[component] = math.max(self.cache_component_width[component], #command[component])
    end
  end

  self.is_cached_valid = true
end

---Return a clone of this layer
---@return Layer
function Layer:clone()
  return vim.deepcopy(self)
end

return Layer
