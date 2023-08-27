local M = {}
local Command = require("commander.model.Command")

---@return CommanderCommand[]
function M.get_lazy_keys()
  local lazy_avail, lazy = pcall(require, "lazy")
  if not lazy_avail then return {} end

  if lazy_commands then return lazy_commands end

  for _, plugin_config in ipairs(lazy.plugins()) do
    local keys = plugin_config.keys
    if keys then
      for _, key in ipairs(keys) do
        local command, err = Command:parse({
          cmd = key[2],
          desc = key.desc,
          keys = {
            key.mode or "n", key[1],
            {
              noremap = key.noremap,
              remap = key.remap,
              expr = key.expr
            }
          }
        }, {
          cat = "",
          set = false,
          show = true,
        })


        if not err then
          if not lazy_commands then lazy_commands = {} end
          lazy_commands[#lazy_commands + 1] = command
        end
      end
    end

    local items = plugin_config.commander
    if items then
      for _, item in ipairs(items) do
        local command, err = Command:parse(item, {
          cat = "",
          set = false,
          show = true,
        })

        if not err then
          if not lazy_commands then lazy_commands = {} end
          lazy_commands[#lazy_commands + 1] = command
        end
      end
    end
  end

  return lazy_commands
end

return M
