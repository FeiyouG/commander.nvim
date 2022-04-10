# command-center.nvim

An esay-to-config command palette
for neovim written in lua.

<!-- TOC GFM -->

- [Demo](#demo)
- [Installation](#installation)
  - [vim-plug](#vim-plug)
  - [Packer](#packer)
- [Setup and configuration](#setup-and-configuration)
  - [Setup](#setup)
  - [Add commands](#add-commands)
    - [`command_center.mode`](#command_centermode)
  - [configuration](#configuration)
    - [Example complete configuration](#example-complete-configuration)

<!-- /TOC -->

## Demo

![demo](https://github.com/gfeiyou/command-center.nvim/blob/assets/demo.gif)

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
use { "nvim-telescope/telescope.nvim" }
use { "gfeiyou/command-center.nvim" }
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
in [`command-center` way](#example-complete-configuration).
Keep reading the following sections.


### Add commands

Why write the same thing twice
for two purposes
if you can get them both done
at the same time?

`command-center` lets you register keybindings
and add them into `command-center`
simultaneously.

```lua
local command_center = require("command_center")
local noremap = {noremap = true}
local silent_noremap = {noremap = true, silent = true}

command_center.add({
  {
    description = "Search inside current buffer",
    command = "Telescope current_buffer_fuzzy_find",
    keybindings = { "n", "<leader>fl", noremap },
  },  {
    -- If no descirption is specified, command is used to replace descirption by default
    -- You can change this behavior in settigns
    command = "Telescope find_files",
    keybindings = { "n", "<leader>ff", noremap },
  }, {
    -- If no keybindings specified, no keybindings will be displayed or registered
    description = "Find hidden files",
    command = "Telescope find_files hidden=true",
  }, {
    -- You can specify multiple keybindings for the same command ...
    description = "Show document symbols",
    command = "Telescope lsp_document_symbols",
    keybindings = {
      {"n", "<leader>ss", noremap},
      {"n", "<leader>ssd", noremap},
    },
  }, {
    -- ... and for different modes
    description = "Show function signaure (hover)",
    command = "lua vim.lsp.buf.hover()",
    keybindings = {
      {"n", "K", silent_noremap },
      {"i", "<C-k>", silent_noremap },
    }
  }, {
    -- If no command is specified, then this entry is ignored
    description = "lsp run linter",
    keybindings = "<leader>sf"
  }
})
```
If you have above snippet in your config,
`command-center` will create your specified keybindings automatically.
And calling `:Telescope command_center`
will open a prompt like this.

![demo1](https://github.com/gfeiyou/command-center.nvim/blob/assets/demo_add.png)

#### `command_center.mode`

`command_center.add()` will add and register
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
    description = "Find files",
    command = "telescope find_files",
    keybindings = { "n", "<leader>ff", noremap },
  }, {
    -- If keybindings is not specified, then this enery is ignored
    -- since there is nothing to register
    description = "Search inside current buffer",
    command = "Telescope current_buffer_fuzzy_find",
  }
}, command_center.mode.REGISTER_ONLY)


-- Only add the commands to command-center but not create the keybindings
-- This is helpful if you already registered the keybindings somewhere else
-- and want to avoid set the exact keybindings twice
command_center.add({
  {
    -- If keybindings are specified,
    -- then they will still show up in command-center but won't be registered
    description = "Find hidden files",
    command = "Telescope find_files hidden=true",
    keybindings = { "n", "<leader>f.f", noremap },
  }, {
    description = "Show document symbols",
    command = "Telescope lsp_document_symbols",
  }, {
    -- The mode can be even further overridden within each item
    description = "LSP cdoe actions",
    command = "Telescope lsp_code_actions",
    keybinginds = { "n", "<leader>sa", noremap },
    mode = command_center.mode.ADD_AND_REGISTER
  }
}, command_center.mode.ADD_ONLY)

```

Above snippet will register the keybindings
for *"Find files"* and *"LSP code actions"*,
but not for others.
The resulted `command-center` looks like this:

![demo2](https://github.com/gfeiyou/command-center.nvim/blob/assets/demo_mode.png)

### configuration

You can customize `command-center`:

```lua
local telescope = require("telescope")
local command_center = require("command_center")

telescope.setup {
  extensions = {
    -- Below are default settings that can be overriden ...

    -- Change what to show on telescope prompt and in which order
    -- Currently support the following three components
    -- Components may repeat
    components = {
      command_center.component.DESCRIPTION,
      command_center.component.KEYBINDINGS,
      command_center.component.COMMAND,
    },

    -- Change the seperator used to seperate each component
    seperator = " ",

    -- When set to false,
    -- The description compoenent will be empty if it is not specified
    auto_replace_desc_with_cmd = true,
  }
}

telescope.load_extension("command_center")
```

#### Example complete configuration

Below is my personal configuration for `command_center`.
You can use it as a reference.

```lua
local telescope = require("telescope")
local command_center = require("command_center")
local noremap = { noremap = true }

command_center.add({
  {
    description = "Open command_center",
    command = "Telescope command_center",
    keybindings = {
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
        -- command_center.component.COMMAND,
      },
      auto_replace_desc_with_cmd = false,
    }
  }
}

telescope.load_extension('command_center')
```
