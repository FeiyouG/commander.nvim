local constants = require("command_center.constants")

local utils = {}

utils._notified = {}
local has_notify, notify = pcall(require, "notify")

utils.command_drepcated_notified = false

utils.warn_once = function(message)
  if (utils._notified[message]) then return end
  utils.warn(message)
  utils._notified[message] = true
end

utils.warn = function(message)
  vim.schedule(function()
    if has_notify then
      notify(message, vim.log.levels.WARN, { title = "command_center.nvim" })
    else
      vim.notify("[command_center.nvim] " .. message, vim.log.levels.WARN)
    end
  end)
end


-- Convert keybings to a 2D array
-- if it is passed in as an array of single keiybindings
-- then sort the array based on mode
utils.format_keybindings = function(keybindings)
  keybindings = keybindings or {}

  if #keybindings >= 2 and #keybindings <= 3 and type(keybindings[1]) == "string" then
    keybindings = { keybindings }
  end

  local res = {}
  for _, value in ipairs(keybindings or {}) do
    if #value >= 2 and type(value[1]) == "string" and type(value[2]) == "string" then
      table.insert(res, value)
    end
  end

  table.sort(res, function(lhs, rhs) return lhs[1] < rhs[2] end)
  return res
end

-- Register the keybindings if they are valid
-- @param keybindings   properly formatted keybindings (by called format_keybindings)
-- @param command       the command the the keybindings map to
utils.register_keybindings = function(keybindings, command)
  for _, value in ipairs(keybindings or {}) do
    if type(command) == "function" then
      if vim.fn.has("nvim-0.7") then
        vim.api.nvim_set_keymap(value[1], value[2], '', {callback = command})
      else
        utils.warn_once("Binding lua function to key is only support in NeoVim 0.7+.")
      end
    else
      vim.api.nvim_set_keymap(value[1], value[2], command, value[3] or {})
    end
  end
end

-- Generate the string representation of keybindings
-- @param keybindings   properly formatted keybindings (by called format_keybindings)
utils.get_keybindings_string = function(keybindings)
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

-- Get the max width of the result display
-- takes into consideration of the length of each component
-- and what component to display
-- @param user_opts   user settings, must contains the following entries:
--                    component:  an array specifying what component to display and in what order
--                    separator: the separator used, default to " "
-- @param length      a table contains the max length for each component
utils.get_max_width = function(user_opts, length)
  user_opts.components = user_opts.components or {
    constants.component.DESCRIPTION,
    constants.component.KEYBINDINGS,
    constants.component.COMMAND,
  }
  length = length or constants.max_length
  -- Read "seperator" too to avoid breaking existing configurations
  user_opts.separator = (user_opts.seperator or user_opts.separator) or " "

  local max_width = 0
  for i, component in ipairs(user_opts.components) do

    if user_opts.auto_replace_desc_with_cmd and component == constants.component.DESCRIPTION then
      max_width = max_width + length[constants.component.REPLACE_DESC_WITH_CMD]
    else
      max_width = max_width + length[component]
    end

    if i > 0 then
      max_width = max_width + #user_opts.separator
    end

  end

  return max_width + 6 -- Leave some margin at the end
end

-- Merge the key value pairs of table1 into table2
utils.merge_tables = function(t1, t2)
  for k, v in pairs(t2) do t1[k] = v end
end

return utils
