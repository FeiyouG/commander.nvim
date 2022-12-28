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

    -- Handle keys as if they were typed
    local cmd = selection.value[component.CMD]
    if type(cmd) == "function" then
      cmd()
    else
      cmd = vim.api.nvim_replace_termcodes(cmd, true, false, true)
      vim.api.nvim_feedkeys(cmd, "t", true)
    end
  end)
  return true
end
