# command_center.nvim

Create and manage keybindings and commands
in a more organized manner,
and search them quickly through Telescope.

## Demo

![demo](https://github.com/gfeiyou/command-center.nvim/blob/assets/demo.gif)

## Change log

- Here is a GitHub issue documents
  [breaking changes](https://github.com/FeiyouG/command_center.nvim/issues/4)
  for `command_center.nvim`.


## Table of Contents

<!-- TOC GFM -->

- [Installation](#installation)
  - [vim-plug](#vim-plug)
  - [Packer](#packer)
- [Setup and configuration](#setup-and-configuration)
  - [Setup](#setup)
  - [Add commands](#add-commands)
    - [`command_center.add`](#command_centeradd)
    - [`command_center.mode`](#command_centermode)
  - [Remove commands](#remove-commands)
  - [Filter](#filter)
  - [Converter](#converter)
  - [configuration](#configuration)
    - [Example configuration](#example-configuration)
- [Related Projects](#related-projects)

<!-- /TOC -->

## Installation

This plugin requires [Telescope](https://github.com/nvim-telescope/telescope.nvim)
to be installed.

### vim-plug

```vim
Plug "nvim-telescope/telescope.nvim"
Plug "gfeiyou/command-center.nvim"
```

### Packer

```lua
use {
  "gfeiyou/command-center.nvim",
  requires = { "nvim-telescope/telescope.nvim" }
}
```

## Setup and configuration

### Setup

First,
you will need to load this plugin
as a [Telescope extension](https://github.com/nvim-telescope/telescope.nvim#extensions).
Put this somewhere in your config:

```lua
require("telescope").load_extension('command_center')
```

Then,
you can open `command-center`
by calling `:Telescope command_center`.
I also use the following keybinding:

```lua
vim.cmd "nnoremap <leader>fc <cmd>Telescope command_center<cr>"
```

And, of course,
the above keybindings can also be created
in [`command-center` way](#example-configuration).
Keep reading the following sections.


### Add commands

#### `command_center.add`

The function `command_center.add(commands, opts)`
does two things:
1. Register the keybindings (if any)
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
    -- If no descirption is specified, command is used to replace descirption by default
    -- You can change this behavior in setup()
    cmd = "<CMD>Telescope find_files<CR>",
    keys = { "n", "<leader>ff", noremap },
  }, {
    -- If no keys are specified, no keybindings will be displayed nor registered
    desc = "Find hidden files",
    cmd = "<CMD>Telescope find_files hidden=true<CR>",
  }, {
    -- You can specify multiple keys for the same command ...
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
    -- You can pass in a key sequence as if they were typed in neovim
    desc = "My favorite key sequence",
    cmd = "A  -- Add a comment at the end of a line",
    keys = {"n", "<leader>Ac", noremap}
  }, {
    -- You can also pass in a lua functions as cmd
    -- NOTE: binding lua funciton with key requires at least nvim 0.7
    desc = "Run lua function",
    cmd = function() print("ANONYMOUS LUA FUNCTION") end,
    keys = {"n", "<leader>alf", noremap},
  }, {
    -- If no command is specified, then this entry will be ignored
    desc = "lsp run linter",
    keys = {"n", "<leader>sf", noremap},
  }
})
```

**NOTE**:
- If you are on neovim 0.6,
  then you can add a Lua function
  as a `cmd` and execute it inside `command_center`.
  However, you are not able to register it with a keybinding.

- If you are on neovim 0.7,
  then you can both register the Lua function
  with a keybinding
  and execute it in `command_center`.

If you have above snippet in your config,
`command-center` will create your specified keybindings automatically.
And calling `:Telescope command_center`
will open a prompt like this.

![demo1](https://github.com/gfeiyou/command-center.nvim/blob/assets/demo_add.png)

#### `command_center.mode`

`command_center.add()` will add **and** register
the keybindings for you by default.
You can use `command_center.mode`
to override this behavior.

```lua
mode = {
  ADD_ONLY = 1,
  REGISTER_ONLY = 2,
  ADD_AND_REGISTER = 3,
}
```

An example usage of `command_center.mode`:

```lua
local command_center = require("command_center")
local noremap = {noremap = true}
local silent_noremap = {noremap = true, silent = true}

-- Set the keybindings for the comand while ignoring them in command-center
-- This allows you to use command-center just as a convenient
-- and organized way to manage your keybinginds
command_center.add({
  {
    desc = "Find files",
    cmd = "<CMR>telescope find_files<CR>",
    keys = { "n", "<leader>ff", noremap },
  }, {
    -- If keys is not specified, then this enery is ignored
    -- since there is nothing to register
    desc = "Search inside current buffer",
    cmd = "<CMD>Telescope current_buffer_fuzzy_find<CR>",
  }
}, {
  mode = command_center.mode.REGISTER_ONLY
})


-- Only add the commands to command-center but not create the keybindings.
-- This is helpful if you already registered the keys somewhere else
-- and want to avoid set the exact keybindings twice
command_center.add({
  {
    -- If keys are specified,
    -- then they will still show up in command-center but won't be registered
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
    mode = command_center.mode.ADD_AND_REGISTER,
  }
}, {
  mode = command_center.mode.ADD_ONLY
})

```

Above snippet will only register the keybindings
for *"Find files"* and *"LSP code actions"*,
but not for others.
The resulted `command-center` looks like this:

![demo2](https://github.com/gfeiyou/command-center.nvim/blob/assets/demo_mode.png)

### Remove commands

```lua
command_center.remove()
```

You can also remove commands from `command_center`,
with the following limitations:

1.  You need to pass in a command with the exact same
    description, command, and keys
    in order to remove it from `command_centier`.


You can find an example usage
in the [wiki page](https://github.com/FeiyouG/command_center.nvim/wiki/Integrations).

### Filter

You can filter the commands upon invoking `:Telescope command_center`.

Currently, you can filter either by mode or category.
You can find some examples below:

- Show only commands that has keybindings that work in normal mode
```
:Telescope command_center mode=n
```

- Show only commands that are filtered by category
  ```
  :Telescope command_center category=git
  ```
  To make this work,
  you have to first set the category
  when you add a command.
  For example:

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

- Or both
```
:Telescope command_center mode=v category=markdown
```

### Converter

The functions in `command_center.converter`
can be used to convert commands
used by command_center to/from
the conventions used by another plugin.

Current available converters are:
- `command_center.converter.to_nvim_set_keymap(commands)`
- `command_center.converter.to_hydra_heads(commands)`

You can find some example usage of converters
in [wiki page](https://github.com/FeiyouG/command_center.nvim/wiki/Integrations).

### configuration

The following is the default configuration
for `command_center`:

```lua
local telescope = require("telescope")
local command_center = require("command_center")

telescope.setup {
  extensions = {
    command_center = {
      -- Below are default settings that can be overriden ...

      -- Specify what components are shown in telescope prompt;
      -- Order matters, and components may repeat
      components = {
        command_center.component.DESCRIPTION,
        command_center.component.KEYBINDINGS,
        command_center.component.COMMAND,
        command_center.component.CATEGORY,
      },

      -- Spcify by what components that search results are ordered;
      -- Order does not matter
      sort_by = {
        command_center.component.DESCRIPTION,
        command_center.component.KEYBINDINGS,
        command_center.component.COMMAND,
        command_center.component.CATEGORY,
      },

      -- Change the separator used to separate each component
      separator = " ",

      -- When set to false,
      -- The description compoenent will be empty if it is not specified
      auto_replace_desc_with_cmd = true,

      -- Default title to Telescope prompt
      prompt_title = "Command Center",
    }
  }
}

telescope.load_extension("command_center")
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
        command_center.component.DESCRIPTION,
        command_center.component.KEYBINDINGS,
      },
      sort_by = {
        command_center.component.DESCRIPTION,
        command_center.component.KEYBINDINGS,
      },
      auto_replace_desc_with_cmd = false,
    }
  }
}

telescope.load_extension('command_center')
```
## Related Projects

- [legendary.nvim](https://github.com/mrjones2014/legendary.nvim)
- [Telescope-command-palette](https://github.com/LinArcX/telescope-command-palette.nvim)
- [which-key](https://github.com/folke/which-key.nvim)
