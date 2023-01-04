local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local component = require("commander.model.Component")

return function(prompt_bufnr, map)
  actions.select_default:replace(function()
    actions.close(prompt_bufnr)
    local selection = action_state.get_selected_entry()

    if not selection then
      return false
    end

    local command = selection.value
    command:execute()
  end)
  return true
end
