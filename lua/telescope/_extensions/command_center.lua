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

local M = require("command_center")
local utils = require("command_center.utils")

local constants = require("command_center.constants")
local argument = constants.argument
local max_length = constants.max_length

-- Initial opts to defualt values
local user_opts = {
  arguments = {
    argument.DESCRIPTION,
    argument.KEYMAPS,
    argument.COMMAND,
  },
  seperator = " ",
}


-- Override default opts by user
local function setup(opts)
  opts = opts or {}
  utils.merge_tables(user_opts, opts)
end

-- Custom theme for command center
function themes.command_center(opts)
  opts = opts or {}

  local theme_opts = {
    theme = "command_center",
    results_title = false,
    sorting_strategy = "ascending",
    layout_strategy = "center",
    layout_config = {
      preview_cutoff = 1, -- Preview should always show (unless previewer = false)
      anchor = "N",
      prompt_position = "top",

      width = function(_, max_columns, _)
        return math.min(max_columns, opts.max_width or 99)
      end,

      height = function(_, _, max_lines)
        return math.min(max_lines, 20)
      end,
    },

    border = true,
    borderchars = {
      prompt = { "─", "│", " ", "│", "╭", "╮", "│", "│" },
      results = { "─", "│", "─", "│", "├", "┤", "╯", "╰" },
    },
  }

  if opts.layout_config and opts.layout_config.prompt_position == "bottom" then
    theme_opts.borderchars = {
      prompt = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      results = { "─", "│", "─", "│", "╭", "╮", "┤", "├" },
    }
  end

  return vim.tbl_deep_extend("force", theme_opts, opts)
end



local function run(opts)
  opts = opts or {}
  utils.merge_tables(opts, user_opts)

  -- Only display what the user specifies
  -- And in the right order
  local make_display = function(entry)
    local to_display = {}
    local items = {}

    for _, v in ipairs(opts.arguments) do
      table.insert(to_display, entry.value[v])
      table.insert(items, { width = max_length[v] } )
    end

    -- Set the columns in telecope
    local displayer = entry_display.create({
      separator = user_opts.seperator,
      items = items,
    })

    return displayer(to_display)
  end


  -- Insert the calculated length constants
  opts.max_width = utils.get_max_width(user_opts.arguments, max_length, user_opts.seperator)
  opts = themes.command_center(opts)

  -- opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Command Center",

    finder = finders.new_table({
      results = M.items,
      entry_maker = function(entry)
        return {
          value = entry,
          display = make_display,
          ordinal = entry[1]
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

  }):find()
end

return telescope.register_extension({
  setup = setup,
  exports = {
    -- Default when to argument is given, i.e. :Telescope command_center
    command_center = run
  },
})

