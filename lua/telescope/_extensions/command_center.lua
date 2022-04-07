local has_telescope, telescope = pcall(require, "telescope")

-- Check for dependencies
if not has_telescope then
  error("This plugin requires telescope.nvim (https://github.com/nvim-telescope/telescope.nvim)")
end

local themes = require("telescope.themes")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local entry_display = require("telescope.pickers.entry_display")
local conf = require("telescope.config").values


local items

local function setup(passed_items)
  items = passed_items or {}
end

local function search(opts)
  opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Command Center",
    finder = finders.new_table({
      results = items
    })
  }):find()
end


local function run()
  print("COMMAND CENTER")
  search(themes.get_dropdown())
  -- categories(require("telescope.themes").vscode({}))
end

return telescope.register_extension({
  setup = setup,
  exports = {
    -- Default when to argument is given, i.e. :Telescope command_palette
    command_center = run
  },
})

