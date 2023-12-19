-- check for dependencies
local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  error("telescope.nvim is not installed (https://github.com/nvim-telescope/telescope.nvim)")
  return nil
end

local theme = require("telescope._extensions.commander.theme")
local finder = require("telescope._extensions.commander.finder")
local attach_mappings = require("telescope._extensions.commander.attach_mappings")

local pickers = require("telescope.pickers")
local telescope_conf = require("telescope.config").values


---@param opts CommanderShowOpts
local function run(opts)
  -- When commander is reloaded, the reference will change
  -- So M can't be a global variable
  local M = require("commander")
  M.layer:set_filter(opts.filter)
  print(vim.inspect(M.layer.cache_component_width))
  local commands = M.layer:get_commands()
  local config = vim.deepcopy(M.config)

  -- Insert the calculated length constants
  config.max_width = M.layer:get_max_width()
  config.num_items = #commands
  config = theme(config)

  local telescope_obj = pickers.new(config, {
    prompt_title = M.config.prompt_title,
    finder = finder(M, commands),
    sorter = telescope_conf.generic_sorter(config),
    attach_mappings = attach_mappings,
  })

  telescope_obj:find()
end

return telescope.register_extension({
  exports = {
    commander = run,
    filter = function(filter)
      run({ filter = filter })
    end
  },
})
