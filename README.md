# command-center.nvim

An esay-to-config command palette
for neovim written in lua.

## Demo


<!-- TOC GFM -->

- [Installation](#installation)
  - [vim-plug](#vim-plug)
  - [Packer](#packer)
- [Features](#features)
- [Setup and configuration](#setup-and-configuration)
  - [Setup](#setup)
  - [Add commands](#add-commands)
    - [`command_center.mode`](#command_centermode)
  - [configuration](#configuration)

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
Use { "gfeiyou/command-center.nvim", require = { "nvim-telescope/telescope.nvim" } }
```

## Features


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

I created the following keybindings for `command-center`:
```lua
-- Use <leader>fc to open command center
vim.cmd "nnoremap <leader>fc <cmd>Telescope command_center<cr>"
vim.cmd "vnoremap <leader>fc <cmd>Telescope command_center<cr>"
-- If ever hesitate when using telescope
-- (most of my Telescope commands start with <leader>f)
-- also open command center
vim.cmd "nnoremap <leader>f <cmd>Telescope command_center<cr>"
vim.cmd "vnoremap <leader>f <cmd>Telescope command_center<cr>"
```

And, of course,
the above keybindings can also be created
in `command-center` way.
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
    -- If no keybindings specified, no keybindings will be created
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
    -- ... and for different mode
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
And your `command-center` will like this:

![demo1](https://github.com/gfeiyou/command-center.nvim/blob/assets/demo_add.png)

#### `command_center.mode`

`command_center.add()` will add and register
the keybindings for you by default.
You can use `command_center.mode`
to override this behavior.

```lua
mode = {
  COMMAND = 1,
  DESCRIPTION = 2,
  KEYBINDINGS = 3,
}
```

An example usage of `command_center.mode`:

```lua
local command_center = require("command_center")
local noremap = {noremap = true}
local silent_noremap = {noremap = true, silent = true}

-- Set the keybindings for the comand while ignoring them in command-center
-- This allows you to use command-center just as a convenient
-- and organized way to create keybinginds
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
command_center.add({
  {
    -- If keybindings are specified
    -- then they will still show up in command-center but are not registered
    description = "Find hidden files",
    command = "Telescope find_files hidden=true",
    keybindings = { "n", "<leader>f.f", noremap },
  }, {
    description = "Show document symbols",
    command = "Telescope lsp_document_symbols",
  }, {
    -- The mode can be even further override within each item
    description = "LSP cdoe actions",
    command = "Telescope lsp_code_actions",
    keybinginds = { "n", "<leader>sa", noremap },
    mode = command_center.mode.ADD_AND_REGISTER
  }
}, command_center.mode.ADD_ONLY)

```

Above snippet will register the keybindings
for *"Find files"* and *"LSP cdoe actions"*,
but not for others.
result in `command-center` look like this:

![demo2](https://github.com/gfeiyou/command-center.nvim/blob/assets/demo_mode.png)


### configuration

You can customize `command-center`:

```lua
local telescope = require("telescope")
local command_center = require("command_center")

telescope.setup {
  extensions = {
    -- Override default settings go here ...

    -- Change what to show on telescope prompt and in which order
    -- Currently supporting the following three component
    -- Components may repeat
    components = {
      command_center.component.DESCRIPTION,
      command_center.component.KEYBINDINGS,
      command_center.component.COMMAND,
    },

    -- Change the seperator used to seperate each component
    seperator = " ",

    -- When set to false, description compoenent wil be empty
    -- if it is not set
    auto_replace_desc_with_cmd = true,
  }
}

telescope.load_extension("command_center")
```

