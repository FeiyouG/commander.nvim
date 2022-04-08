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
-- local defaulter = require('telescope.utils').make_default_callable

local command_center = require("command_center")
local opts

local function setup(passed_opts)
  opts = passed_opts or {}
end


local function run(opts)
  opts = themes.get_dropdown(opts)
  -- opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Command Center",

    finder = finders.new_table({
      results = command_center.items,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry.description,
          ordinal = entry.description
        }
      end,
    }),

    sorter = conf.generic_sorter(opts),

    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        -- print(vim.inspect(selection))
        vim.api.nvim_exec(selection.value.command, true)
      end)
      return true
    end,

    -- previewer = defaulter(function(opts)
    --   get_command = function(entry)
    --     return {"echo", "Hello World"}
    --   end
    -- end)
  }):find()
end

return telescope.register_extension({
  setup = setup,
  exports = {
    -- Default when to argument is given, i.e. :Telescope command_center
    command_center = run
  },
})

