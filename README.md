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
    - [`comamnder.add`](#comamnderadd)
    - [`comamnder.mode`](#comamndermode)
  - [Filter](#filter)
  - [`comamnder.remove`](#comamnderremove)
  - [`comamnder.converter`](#comamnderconverter)
- [Related Projects](#related-projects)

<!-- /TOC -->

## Install

This plugin requires [Telescope](https://github.com/nvim-telescope/telescope.nvim).

### vim-plug

```vim
Plug "nvim-telescope/telescope.nvim"
Plug "FeiyouG/comamnder.nvim"
```

### Packer

```lua
use {
  "FeiyouG/comamnder.nvim",
  requires = { "nvim-telescope/telescope.nvim" }
}
```

### Lazy
```lua
return {
  "FeiyouG/comamnder.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" }
}


## Usage

A minimal working example:
```lua
-- Add a new command
require("commander.nvim").add({
  {
    desc = "Open comamnder",
    cmd = "<CMD>Telescope comamnder<CR>",
    keys = {"n", "<Leader>fc", noremap},
  }
})

-- Show commander and select the command
require("commander.nvim").show()
```

#### Configuration

Configuration can be done through
`telescope.setup` function:

```lua
require("commander").setup({
    ...
})

```

The following is the default configuration,
and you only need to pass the settings that you want to change:

```lua
{
  -- Specify what components are shown in telescope prompt;
  -- Order matters, and components may repeat
  components = {
    "DESC",
    "KEYS",
    "CMD",
    "CAT",
  },

  -- Spcify by what components the commands is sorted
  -- Order does not matter
  sort_by = {
    "DESC",
    "KEYS",
    "CMD",
    "CAT",
  },

  -- Change the separator used to separate each component
  separator = " ",

  -- When set to false,
  -- The description compoenent will be empty if it is not specified
  auto_replace_desc_with_cmd = true,

  -- Default title to Telescope prompt
  prompt_title = "Command Center",

  integration = {
    telescope = {
      -- Set to true to use telescope instead of vim.ui.select 
      enable = false,
      -- Can be any builtin or custom telescope theme
      theme = theme, 
    },
    lazy = {
      -- Set to true to automatically add all keymaps set by lazy
      enable = false, 
    }
  }
}
```

#### Example configuration

Below is my personal configuration for `comamnder`.
You can use it as a reference.

```lua
-- Plugin Manager: lazy.nvim
return {
  "FeiyouG/commander.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
  },
  keys = {
    { "<leader>f",  "<CMD>Telescope commander<CR>", mode = "n" },
    { "<leader>fc", "<CMD>Telescope commander<CR>", mode = "n" }
  },
  config = function()
    local commander = require("commander")
    commander.setup({
      components = {
        "DESC",
        "KEYS",
        "CAT",
        "CMD"
      },
      sort_by = {
        "DESC",
        "KEYS",
        "CAT",
        "CMD"
      },
      auto_replace_desc_with_cmd = true,
      separator = " │ ",
      integration = {
        telescope = {
          enable = true,
          theme = require("telescope.themes").commander,
        },
        lazy = {
          enable = true
        }
      }
    })
  end,
}
```

### Add commands

#### `comamnder.add`

The function `comamnder.add(commands, opts)`
does two things:

1. Set the keymaps (if any)
2. Add the commands to `comamnder`

You can find an example below:

```lua
local comamnder = require("comamnder")
local noremap = {noremap = true}
local silent_noremap = {noremap = true, silent = true}

comamnder.add({
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
And calling `:Telescope commander`
will open a prompt like this:

![demo1](https://github.com/gfeiyou/command-center.nvim/blob/assets/demo_add.png)

#### `comamnder.mode`

`comamnder.add()` will add **and** set
the keymaps for you by default.
You can use `comamnder.mode`
to override this behavior.

```lua
mode = {
  ADD = 1,      -- only add the commands to comamnder
  SET = 2,      -- only set the keymaps
  ADD_SET = 3,  -- add the commands and set the keymaps
}
```

An example usage of `comamnder.mode`:

```lua
local comamnder = require("comamnder")

-- Set the keymaps for commands only
-- This allows you to use comamnder just as a convenient
-- and organized way to manage your keymaps
comamnder.add({
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
  mode = comamnder.mode.SET
})


-- Only add the commands to comamnder
-- This is helpful if you already registered the keymap somewhere else
-- and want to avoid set the exact keymap twice
comamnder.add({
  {
    -- If keys are specified,
    -- then they will still show up in comamnder but won't be registered
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
    mode = comamnder.mode.ADD_SET,
  }
}, {
  mode = comamnder.mode.ADD
})

```

Above snippet will only set the keymaps
for _"Find files"_ and _"LSP code actions"_,
but not for others.
The resulted `comamnder` prompt will look like this:

![demo2](https://github.com/gfeiyou/command-center.nvim/blob/assets/demo_mode.png)

### Filter

You can filter the commands upon invoking `:Telescope comamnder`.

Currently, you can filter either by mode or category.
You can find some examples below:

1. Show only commands that has keymaps that work in normal mode

```
:Telescope comamnder mode=n
```

2. Show only commands that in "git" category

```
:Telescope comamnder category=git
```

You can specify the category of a command
as follows:

```lua
comamnder.add({
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
comamnder.add({
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
  mode = comamnder.mode.ADD_ONLY,
  category = "git"
})

```

3. Or both

```
:Telescope comamnder mode=n category=markdown
```

### `comamnder.remove`

```lua
comamnder.remove(commands, opts)
```

You can also remove commands from `comamnder`,
with the following limitations:

1.  You need to pass in commands with the exact same
    `desc`, `cmd`, and `keys`
    in order to remove it from `comamnder`.

Furthermore, you can find an example usage
in the [wiki page](https://github.com/FeiyouG/comamnder.nvim/wiki/Integrations).

### `comamnder.converter`

The functions in `comamnder.converter`
can be used to convert commands
used by comamnder to/from
the conventions used by another plugin/functions.

Current available converters are:

- `comamnder.converter.to_nvim_set_keymap(commands)`
- `comamnder.converter.to_hydra_heads(commands)`

You can find some example usage of converters
in [wiki page](https://github.com/FeiyouG/comamnder.nvim/wiki/Integrations).

## Related Projects

- [which-key](https://github.com/folke/which-key.nvim)
- [hydra](https://github.com/anuvyklack/hydra.nvim)
- [Telescope-command-palette](https://github.com/LinArcX/telescope-command-palette.nvim)
- [legendary.nvim](https://github.com/mrjones2014/legendary.nvim)
