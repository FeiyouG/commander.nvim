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

local component = require("command_center.model.Component")
local M = require("command_center")

-- Custom theme for command center
-- themes.command_center = require("telescope._extensions.command_center.theme")
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
        return math.min(max_columns, M.layer:get_max_width())
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

-- Override default opts by user
local function setup(opts)
  M.setup(opts)
end

local function run(filter)
  M.layer:set_filter(filter)
  local commands = M.layer:get_commands()
  local opts = vim.deepcopy(M.config)

  -- Only display what the user specifies
  -- And in the right order
  local make_display = function(entry)
    local display = {}
    local component_info = {}

    for _, v in ipairs(opts.components) do
      table.insert(display, entry.value[v])
      table.insert(component_info, { width = M.layer:get_length(v) })
    end

    local displayer = entry_display.create({
      separator = opts.separator,
      items = component_info,
    })

    return displayer(display)
  end

  -- Insert the calculated length constants
  opts.max_width = M.layer:get_max_width()
  opts.num_items = #commands
  -- opts = themes.command_center(opts)
  opts = opts.telescope.theme(opts)

  -- opts = opts or {}
  local telescope_obj = pickers.new(opts, {
    prompt_title = opts.prompt_title,

    finder = finders.new_table({
      results = commands,
      entry_maker = function(entry)
        -- Concatenate components specified in `sort_by` for better sorting
        local ordinal = ""
        for _, v in ipairs(opts.sort_by) do
          ordinal = ordinal .. entry[v]
        end

        return {
          value = entry,
          display = make_display,
          ordinal = ordinal,
        }
      end,
    }),

    sorter = conf.generic_sorter(opts),

    attach_mappings = function(prompt_bufnr, map)
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
    end,
  })

  -- MARK: Save all current settings
  -- vim.deepcopy() can't copy getfenv(),
  -- Use force extend instead, as inpsired by hydra.nvim
  local env = vim.tbl_deep_extend("force", getfenv(), {
    vim = { o = {}, go = {}, bo = {}, wo = {} },
  }) --[[@as table]]
  local o = env.vim.o
  local go = env.vim.go
  local bo = env.vim.bo
  local wo = env.vim.wo

  -- MARK: Start telescope
  vim.schedule(function()
    vim.bo.modifiable = true
    vim.cmd("startinsert")
  end)

  telescope_obj:find()

  -- MAKR: Restore all settings
  env.vim.o = o
  env.vim.go = go
  env.vim.bo = bo
  env.vim.wo = wo
end

return telescope.register_extension({
  setup = setup,
  exports = {
    command_center = run,
  },
})
