local entry_display = require("telescope.pickers.entry_display")
local finders = require("telescope.finders")


local display = function(commander, entry)
  local display = {}
  local component_info = {}

  for _, v in ipairs(commander.config.components) do
    table.insert(display, entry.value[v])
    table.insert(component_info, { width = commander.layer:get_length(v) })
  end

  local displayer = entry_display.create({
    separator = commander.config.separator,
    items = component_info,
  })

  return displayer(display)
end


return function(commander, commands)
  return finders.new_table({
    results = commands,
    entry_maker = function(entry)
      -- Concatenate components specified in `sort_by` for better sorting
      local ordinal = ""
      for _, v in ipairs(commander.config.sort_by) do
        ordinal = ordinal .. entry[v]
      end

      return {
        value = entry,
        display = function(entry) return display(commander, entry) end,
        ordinal = ordinal,
      }
    end,
  })
end
