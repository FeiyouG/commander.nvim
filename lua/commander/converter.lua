local M = {}
local Command = require("commander.model.Command")

-- Caching the result of parsing lazy's plugin_config
local lazy_commands = nil

---@param set_plugin_name_as_cat boolean
---@return CommanderCommand[]
function M.get_lazy_keys(set_plugin_name_as_cat)
  local lazy_avail, lazy = pcall(require, "lazy")
  if not lazy_avail then return {} end

  if lazy_commands then return lazy_commands end
  lazy_commands = lazy_commands or {}

  for _, plugin_config in ipairs(lazy.plugins()) do
    local keys = require("lazy.core.plugin").values(plugin_config, "keys")
    local main = require("lazy.core.loader").get_main(plugin_config)
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
          cat = set_plugin_name_as_cat and main or "",
          set = false,
          show = true,
        })

        if not err then
          lazy_commands[#lazy_commands + 1] = command
        end
      end
    end

    local items = plugin_config.commander
    if items then
      for _, item in ipairs(items) do
        local command, err = Command:parse(item, {
          cat = set_plugin_name_as_cat and main or "",
          set = true,
          show = true,
        })

        if err then
          err = vim.inspect(item) .. "\n -> " .. err
          vim.notify("Commander will ignore the following incorrectly formatted item:\n" .. err, vim.log.levels.WARN)
        else
          lazy_commands[#lazy_commands + 1] = command
        end
      end
    end
  end

  return lazy_commands
end

return M
