local constants = require("command_center.constants")

local M = {}

M._notified = {}
local has_notify, notify = pcall(require, "notify")

M.command_drepcated_notified = false

M.warn_once = function(message)
  if (M._notified[message]) then return end
  M.warn(message)
  M._notified[message] = true
end

M.warn = function(message)
  vim.schedule(function()
    if has_notify then
      notify(message, vim.log.levels.WARN, { title = "command_center.nvim" })
    else
      vim.notify("[command_center.nvim] " .. message, vim.log.levels.WARN)
    end
  end)
end


---Convert keybings to a 2D array
---if it is passed in as an array of single keiybindings
---then sort the array based on mode
M.format_keybindings = function(keybindings)
  keybindings = keybindings or {}

  if #keybindings >= 2 and #keybindings <= 3 and type(keybindings[1]) == "string" then
    keybindings = { keybindings }
  end

  local res = {}
  for _, value in ipairs(keybindings) do
    if #value >= 2 and type(value[1]) == "string" and type(value[2]) == "string" then
      value[3] = value[3] or {}
      table.insert(res, value)
    end
  end

  table.sort(res, function(lhs, rhs) return lhs[1] < rhs[2] end)
  return res
end

---Register the keybindings if they are valid
---@param keybindings table:  properly formatted keybindings (by called format_keybindings)
---@param command function|string: the command the the keybindings map to
M.register_keybindings = function(keybindings, command)
  for _, value in ipairs(keybindings or {}) do
    if type(command) == "function" then
      vim.api.nvim_set_keymap(value[1], value[2], '', { callback = command })
    else
      vim.api.nvim_set_keymap(value[1], value[2], command, value[3] or {})
    end
  end
end

M.delete_keybindings = function(keybindings, command)
  for _, value in ipairs(keybindings or {}) do
    -- local keymaps = vim.tbl_filter(function(keymap)
    --   return keymap.rhs and keymap.rhs == command
    -- end,
    --   vim.api.nvim_get_keymap(value[1]))
    --
    -- if vim.tbl_isempty(keymaps) then return end

    vim.api.nvim_del_keymap(value[1], value[2])
    -- if type(command) == "function" then
    --   vim.api.nvim_del_keymap(value[1], value[2])
    -- else
    --   local keymaps = vim.tbl_filter(function(keymap)
    --     return keymap.rhs and keymap.rhs == command
    --   end,
    --     vim.api.nvim_get_keymap(value[1]))
    --   if vim.tbl_isempty(keymaps) then return end
    --   vim.api.nvim_del_keymap(value[1], value[2])
    -- end
  end
end

---Generate the string representation of keybindings
---@param keybindings table: properly formatted keybindings (by called format_keybindings)
M.get_keybindings_string = function(keybindings)
  local res = ""
  local mode
  for i, value in ipairs(keybindings or {}) do
    if i == 1 then
      mode = value[1]
      res = mode .. "|" .. value[2]
    else
      if value[1] == mode then
        res = res .. "," .. value[2]
      else
        mode = value[1]
        res = res .. " " .. mode .. "|" .. value[2]
      end
    end
  end
  return res
end

---Get the max width of the result display
---takes into consideration of the length of each component
---and what component to display
---@param user_opts table: user settings, must contains component and seperator
---@param length number:  a table contains the max length for each component
M.get_max_width = function(user_opts, length)
  user_opts.components = user_opts.components or {
    constants.component.DESC,
    constants.component.KEYS_STR,
    constants.component.CMD_STR,
  }
  length = length or constants.max_len
  -- Read "seperator" too to avoid breaking existing configurations
  user_opts.separator = (user_opts.seperator or user_opts.separator) or " "

  local max_width = 0
  for i, component in ipairs(user_opts.components) do

    if user_opts.auto_replace_desc_with_cmd and component == constants.component.DESC then
      max_width = max_width + length[constants.component.REPLACED_DESC]
    else
      max_width = max_width + length[component]
    end

    if i > 0 then
      max_width = max_width + #user_opts.separator
    end

  end

  return max_width + 6 -- Leave some margin at the end
end

-- Merge the key value pairs of table2 into table1
-- M.merge_tables = function(t1, t2)
--   for k, v in pairs(t2) do t1[k] = v end
-- end

local filter_item_by_mode = function(item, mode)
  if not mode or not item then return true end

  for _, keybinding in ipairs(item[constants.component.KEYS]) do
    if (keybinding[1] == mode) then
      return true
    end
  end
  return false
end

local filter_item_by_category = function(item, category)
  if not category or not item then return true end
  return item[constants.component.CATEGORY] == category
end

-- Filter items based on filter
-- return filtered items
M.filter_items = function(items, filter)
  -- Early exit if filter or items are empty
  if not items then return items end
  if not filter then return items end

  local filtered_items = {}

  for _, item in pairs(items) do
    if filter_item_by_mode(item, filter.mode)
        and filter_item_by_category(item, filter.category) then
      table.insert(filtered_items, item)
    end
  end

  return filtered_items
end

return M
