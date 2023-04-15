# cammander.nvim

Create and manage keymaps and commands
in a more organized manner,
and search them quickly through Telescope.

## Demo

![demo](https://github.com/gfeiyou/command-center.nvim/blob/assets/commander_demo.png)

## Change log

- **`command_center.nvim` is renamed to `commander.nvim`.**
- Here is a GitHub issue documents
  [breaking changes](https://github.com/FeiyouG/cammander.nvim/issues/4)
  for `commander.nvim`.

## Table of Contents

<!-- TOC GFM -->

- [Install](#install)
  - [vim-plug](#vim-plug)
  - [Packer](#packer)
- [Usage](#usage)
  - [Configuration](#configuration)
    - [Configuration](#configuration-1)
    - [Example configuration](#example-configuration)
  - [Add commands](#add-commands)
    - [`command_center.add`](#command_centeradd)
    - [`command_center.mode`](#command_centermode)
  - [Filter](#filter)
  - [`command_center.remove`](#command_centerremove)
  - [`command_center.converter`](#command_centerconverter)
- [Related Projects](#related-projects)

<!-- /TOC -->

## Install

This plugin requires [Telescope](https://github.com/nvim-telescope/telescope.nvim).

### vim-plug

```vim
Plug "nvim-telescope/telescope.nvim"
Plug "FeiyouG/command_center.nvim"
```

### Packer

```lua
use {
  "FeiyouG/command_center.nvim",
  requires = { "nvim-telescope/telescope.nvim" }
}
```

## Usage

A minimal working example:
```lua
-- Add a new command
require("commander.nvim").add({
  {
    desc = "Open command_center",
    cmd = "<CMD>Telescope command_center<CR>",
    keys = {"n", "<Leader>fc", noremap},
  }
})

-- Show commander and select the command
require("commander.nvim").show()
```

### Configuration

Then,
you can open `command-center`
by calling `:Telescope command_center`.
I also use the following keybinding:

```lua
vim.cmd "nnoremap <leader>fc <CMD>Telescope command_center<CR>"
```

And, of course,
the above keybindings can also be created
in [`command-center`-way](#example-configuration).
Keep reading the following sections.

#### Configuration

Configuration can be done through
`telescope.setup` function:

```lua
require("telescope").setup {
  extensions = {
    command_center = {
      -- Your configurations go here
    }
  }
}

```

The following is the default configuration
for `command_center`,
and you only need to pass the settings that you want to change
to `require("telescope").setup`:

```lua
{
  -- Specify what components are shown in telescope prompt;
  -- Order matters, and components may repeat
  components = {
    command_center.component.DESC,
    command_center.component.KEYS,
    command_center.component.CMD,
    command_center.component.CATEGORY,
  },

  -- Spcify by what components the commands is sorted
  -- Order does not matter
  sort_by = {
    command_center.component.DESC,
    command_center.component.KEYS,
    command_center.component.CMD,
    command_center.component.CATEGORY,
  },

  -- Change the separator used to separate each component
  separator = " ",

  -- When set to false,
  -- The description compoenent will be empty if it is not specified
  auto_replace_desc_with_cmd = true,

  -- Default title to Telescope prompt
  prompt_title = "Command Center",

  -- can be any builtin or custom telescope theme
  theme = require("telescope.themes").command_center,
}
```

#### Example configuration

Below is my personal configuration for `command_center`.
You can use it as a reference.

```lua
local telescope = require("telescope")
local command_center = require("command_center")
local noremap = { noremap = true }

command_center.add({
  {
    desc = "Open command_center",
    cmd = "<CMD>Telescope command_center<CR>",
    keys = {
      {"n", "<Leader>fc", noremap},
      {"v", "<Leader>fc", noremap},

      -- If ever hesitate when using telescope start with <leader>f,
      -- also open command center
      {"n", "<Leader>f", noremap},
      {"v", "<Leader>f", noremap},
    },
  }
}, command_center.mode.REGISTER_ONLY)

telescope.setup {
  extensions = {
    command_center = {
      components = {
        command_center.component.DESC,
        command_center.component.KEYS,
      },
      sort_by = {
        command_center.component.DESC,
        command_center.component.KEYS,
      },
      auto_replace_desc_with_cmd = false,
    }
  }
}

telescope.load_extension('command_center')
```

### Add commands

#### `command_center.add`

The function `command_center.add(commands, opts)`
does two things:

1. Set the keymaps (if any)
2. Add the commands to `command_center`

You can find an example below:

```lua
local command_center = require("command_center")
local noremap = {noremap = true}
local silent_noremap = {noremap = true, silent = true}

command_center.add({
  {
    desc = "Search inside current buffer",
    cmd = "<CMD>Telescope current_buffer_fuzzy_find<CR>",
    keys = { "n", "<leader>fl", noremap },
  },  {
    -- If no descirption is specified, cmd is used to replace descirption by default
    -- You can change this behavior in setup()
    cmd = "<CMD>Telescope find_files<CR>",
    keys = { "n", "<leader>ff", noremap },
  }, {
    -- If no keys are specified, no keymaps will be displayed nor set
    desc = "Find hidden files",
    cmd = "<CMD>Telescope find_files hidden=true<CR>",
  }, {
    -- You can specify multiple keys for the same cmd ...
    desc = "Show document symbols",
    cmd = "<CMD>Telescope lsp_document_symbols<CR>",
    keys = {
      {"n", "<leader>ss", noremap},
      {"n", "<leader>ssd", noremap},
    },
  }, {
    -- ... and for different modes
    desc = "Show function signaure (hover)",
    cmd = "<CMD>lua vim.lsp.buf.hover()<CR>",
    keys = {
      {"n", "K", silent_noremap },
      {"i", "<C-k>", silent_noremap },
    }
  }, {
    -- You can pass in a key sequences as if you would type them in nvim
    desc = "My favorite key sequence",
    cmd = "A  -- Add a comment at the end of a line",
    keys = {"n", "<leader>Ac", noremap}
  }, {
    -- You can also pass in a lua functions as cmd
    -- NOTE: binding lua funciton to a keymap requires nvim 0.7 and above
    desc = "Run lua function",
    cmd = function() print("ANONYMOUS LUA FUNCTION") end,
    keys = {"n", "<leader>alf", noremap},
  }, {
    -- If no cmd is specified, then this entry will be ignored
    desc = "lsp run linter",
    keys = {"n", "<leader>sf", noremap},
  }
})
```

If you have above snippet in your config,
`command-center` will create your specified keybindings automatically.
And calling `:Telescope command_center`
will open a prompt like this:

![demo1](https://github.com/gfeiyou/command-center.nvim/blob/assets/demo_add.png)

#### `command_center.mode`

`command_center.add()` will add **and** set
the keymaps for you by default.
You can use `command_center.mode`
to override this behavior.

```lua
mode = {
  ADD = 1,      -- only add the commands to command_center
  SET = 2,      -- only set the keymaps
  ADD_SET = 3,  -- add the commands and set the keymaps
}
```

An example usage of `command_center.mode`:

```lua
local command_center = require("command_center")

-- Set the keymaps for commands only
-- This allows you to use command_center just as a convenient
-- and organized way to manage your keymaps
command_center.add({
  {
    desc = "Find files",
    cmd = "<CMR>telescope find_files<CR>",
    keys = { "n", "<leader>ff", { noremap = true } },
  }, {
    -- If keys is not specified, then this enery is ignored
    -- since there is no keymaps to set
    desc = "Search inside current buffer",
    cmd = "<CMD>Telescope current_buffer_fuzzy_find<CR>",
  }
}, {
  mode = command_center.mode.SET
})


-- Only add the commands to command_center
-- This is helpful if you already registered the keymap somewhere else
-- and want to avoid set the exact keymap twice
command_center.add({
  {
    -- If keys are specified,
    -- then they will still show up in command_center but won't be registered
    desc = "Find hidden files",
    cmd = "<CMD>Telescope find_files hidden=true<CR>",
    keys = { "n", "<leader>f.f", noremap },
  }, {
    desc = "Show document symbols",
    cmd = "<CMD>Telescope lsp_document_symbols<CR>",
  }, {
    -- The mode can be even further overridden within each item
    desc = "LSP cdoe actions",
    cmd = "<CMD>Telescope lsp_code_actions<CR>",
    keybinginds = { "n", "<leader>sa", noremap },
    mode = command_center.mode.ADD_SET,
  }
}, {
  mode = command_center.mode.ADD
})

```

Above snippet will only set the keymaps
for _"Find files"_ and _"LSP code actions"_,
but not for others.
The resulted `command_center` prompt will look like this:

![demo2](https://github.com/gfeiyou/command-center.nvim/blob/assets/demo_mode.png)

### Filter

You can filter the commands upon invoking `:Telescope command_center`.

Currently, you can filter either by mode or category.
You can find some examples below:

1. Show only commands that has keymaps that work in normal mode

```
:Telescope command_center mode=n
```

2. Show only commands that in "git" category

```
:Telescope command_center category=git
```

You can specify the category of a command
as follows:

```lua
command_center.add({
  {
    description = "Open git diffview",
    cmd = "<CMD>DiffviewOpen<CR>",
    keybindings = { "n", "<leader>gd", noremap },
    category = "git",
  }, {
    description = "Close current git diffview",
    cmd = "<CMD>DiffviewClose<CR>",
    keybindings = { "n", "<leader>gc", noremap },
    category = "git",
  }, {
    description = "Toggle markdown preview",
    cmd = "<CMD>MarkdownPreviewToggle<CR>",
    keybindings = { "n", "<leader>mp", noremap },
    category = "markdown",
  }
})

-- Or you can set up the category for multiple commands at once
command_center.add({
  {
    description = "Open git diffview",
    cmd = "<CMD>DiffviewOpen<CR>",
    keybindings = { "n", "<leader>gd", noremap },
  }, {
    description = "Close current git diffview",
    cmd = "<CMD>DiffviewClose<CR>",
    keybindings = { "n", "<leader>gc", noremap },
  }, {
    -- category set in a smaller scope takes precedence
    description = "Toggle markdown preview",
    cmd = "<CMD>MarkdownPreviewToggle<CR>",
    keybindings = { "n", "<leader>mp", noremap },
    category = "markdown",
  }
}, {
  mode = command_center.mode.ADD_ONLY,
  category = "git"
})

```

3. Or both

```
:Telescope command_center mode=n category=markdown
```

### `command_center.remove`

```lua
command_center.remove(commands, opts)
```

You can also remove commands from `command_center`,
with the following limitations:

1.  You need to pass in commands with the exact same
    `desc`, `cmd`, and `keys`
    in order to remove it from `command_center`.

Furthermore, you can find an example usage
in the [wiki page](https://github.com/FeiyouG/command_center.nvim/wiki/Integrations).

### `command_center.converter`

The functions in `command_center.converter`
can be used to convert commands
used by command_center to/from
the conventions used by another plugin/functions.

Current available converters are:

- `command_center.converter.to_nvim_set_keymap(commands)`
- `command_center.converter.to_hydra_heads(commands)`

You can find some example usage of converters
in [wiki page](https://github.com/FeiyouG/command_center.nvim/wiki/Integrations).

## Related Projects

- [which-key](https://github.com/folke/which-key.nvim)
- [hydra](https://github.com/anuvyklack/hydra.nvim)
- [Telescope-command-palette](https://github.com/LinArcX/telescope-command-palette.nvim)
- [legendary.nvim](https://github.com/mrjones2014/legendary.nvim)
