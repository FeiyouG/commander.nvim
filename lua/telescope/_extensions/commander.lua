-- Check for dependencies
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

local M = require("commander")

-- Override default opts by user
---@deprecated Use require("commander").setup instead
local function setup(opts)
  M.setup(opts)
end

local function run(filter)
  M.layer:set_filter(filter)
  local commands = M.layer:get_commands()
  local opts = vim.deepcopy(M.config)

  -- Insert the calculated length constants
  opts.max_width = M.layer:get_max_width()
  opts.num_items = #commands
  opts = theme(opts)

  local telescope_obj = pickers.new(opts, {
    prompt_title = M.config.prompt_title,
    finder = finder(commands),
    sorter = telescope_conf.generic_sorter(opts),
    attach_mappings = attach_mappings,
  })

  telescope_obj:find()
end

return telescope.register_extension({
  setup = setup,
  exports = {
    command_center = run,
  },
})
