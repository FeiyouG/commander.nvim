local M = {}

---Select amd execute a command
---@param commands {[integer]: Command} the commands to be selected
---@param prompt_title string the title of the prompt
---@param displayer {[integer]: Component}
---@param componet_width {[Component]: integer}
function M.select(commands, prompt_title, displayer, componet_width)
  vim.ui.select(commands, {
    promp = prompt_title,
    format_item = function(command)
      local res = ""
      for _, component in ipairs(displayer) do
        local component_str = command[component]
        local num_space = componet_width[component] - #component_str
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

return M
