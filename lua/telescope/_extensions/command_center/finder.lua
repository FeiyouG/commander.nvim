local entry_display = require("telescope.pickers.entry_display")
local finders = require("telescope.finders")

local M = require("command_center")

local display = function(entry)
  local display = {}
  local component_info = {}

  for _, v in ipairs(M.config.components) do
    table.insert(display, entry.value[v])
    table.insert(component_info, { width = M.layer:get_length(v) })
  end

  local displayer = entry_display.create({
    separator = M.config.separator,
    items = component_info,
  })

  return displayer(display)
end


return function(commands)
  return finders.new_table({
    results = commands,
    entry_maker = function(entry)
      -- Concatenate components specified in `sort_by` for better sorting
      local ordinal = ""
      for _, v in ipairs(M.config.sort_by) do
        ordinal = ordinal .. entry[v]
      end

      return {
        value = entry,
        display = display,
        ordinal = ordinal,
      }
    end,
  })
end
