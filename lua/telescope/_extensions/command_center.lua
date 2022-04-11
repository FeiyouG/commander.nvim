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
local component = constants.component
local private_component = constants.private_component
local max_length = constants.max_length

-- Initial opts to defualt values
local user_opts = {
  components = {
    component.DESCRIPTION,
    component.KEYBINDINGS,
    component.COMMAND,
  },
  seperator = " ",
  auto_replace_desc_with_cmd = true,
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
      preview_cutoff = 0,
      anchor = "N",
      prompt_position = "top",

      width = function(_, max_columns, _)
        return math.min(max_columns, opts.max_width)
      end,

      height = function(_, _, max_lines)
        -- Max 20 lines, smaller if have less than 20 entries in total
        return math.min(max_lines, opts.num_items + 4, 20)
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
    local display = {}
    local component_info = {}

    for _, v in ipairs(opts.components) do

      -- When user chooses to replace desc with cmd ...
      if opts.auto_replace_desc_with_cmd and v == component.DESCRIPTION then

        if not entry.value[v] == "" then
          -- ... and desc is empty, replace desc with cmd
          table.insert(display, entry.value[component.COMMAND])
        else
          -- .. and desc is not empty, use desc
          table.insert(display, entry.value[v])
        end

        -- Update the legnth of desc componenet
        table.insert(component_info, { width = max_length[private_component.REPLACE_DESC_WITH_CMD] })
      else
        table.insert(display, entry.value[v])
        table.insert(component_info, { width = max_length[v] } )
      end
    end

    -- Set the columns in telecope
    local displayer = entry_display.create({
      separator = user_opts.seperator,
      items = component_info,
    })

    return displayer(display)
  end

  -- Insert the calculated length constants
  opts.max_width = utils.get_max_width(user_opts, max_length)
  opts.num_items = #M.items
  opts = themes.command_center(opts)

  -- opts = opts or {}
  pickers.new(opts, {
    prompt_title = "Command Center",

    finder = finders.new_table({
      results = M.items,
      entry_maker = function(entry)

        -- Concatenate components for ordinal
        -- For better sorting
        local ordinal = ""
        for _, v in ipairs(opts.components) do
          ordinal = ordinal .. entry[v]
        end

        return {
          value = entry,
          display = make_display,
          ordinal = ordinal
        }
      end,
    }),

    sorter = conf.generic_sorter(opts),

    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        vim.api.nvim_exec(selection.value[component.COMMAND], true)
      end)
      return true
    end,

  }):find()
end

return telescope.register_extension({
  setup = setup,
  exports = {
    command_center = run
  },
})

