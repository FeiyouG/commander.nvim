# cammander.nvim

Create and manage keymaps and commands
in a more organized way.

## Demo

![demo](https://github.com/FeiyouG/commander.nvim/blob/assets/demo.png)

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
    - [Lazy](#lazy)
- [Configuration and Usage](#configuration-and-usage)
    - [A minimal working example](#a-minimal-working-example)
    - [Configuration](#configuration)
    - [Example configuration](#example-configuration)
- [API](#api)
        - [`comamnder.add(CommanderItem[], CommanderAddOpts)`](#comamnderaddcommanderitem-commanderaddopts)
            - [Examples](#examples)
    - [`Commander.show(CommanderShowOpts)`](#commandershowcommandershowopts)
- [Integration](#integration)
    - [Lazy.nvim](#lazynvim)
- [Special Thanks](#special-thanks)
- [Related Projects](#related-projects)

<!-- /TOC -->

## Install

This plugin requires [Telescope](https://github.com/nvim-telescope/telescope.nvim).

### vim-plug

```vim
Plug "nvim-telescope/telescope.nvim"
Plug "FeiyouG/commander.nvim"
```

### Packer

```lua
use {
  "FeiyouG/commander.nvim",
  requires = { "nvim-telescope/telescope.nvim" }
}
```

### Lazy
```lua
return {
  "FeiyouG/commander.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" }
}
```


## Configuration and Usage

### A minimal working example
```lua
-- Add a new command
require("commander.nvim").add({
  {
    desc = "Open comamnder",
    cmd = require("commander").show,
    keys = { "n", "<Leader>fc" },
  }
})
-- Show commander and select the command by pressing "<leader>fc"
```

### Configuration

Configuration can be done through
`setup` function:

```lua
require("commander").setup({
    ...
})

```

The following is the default configuration,
and you only need to pass the settings that you want to change:

```lua
{
  -- Specify what components are shown in the prompt;
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

  -- When set to true,
  -- The desc component will be populated with cmd if desc is empty or missing.
  auto_replace_desc_with_cmd = true,

  -- Default title of the prompt
  prompt_title = "Commander",

  integration = {
    telescope = {
      -- Set to true to use telescope instead of vim.ui.select for the UI
      enable = false,
      -- Can be any builtin or custom telescope theme
      theme = theme,
    },
    lazy = {
      -- Set to true to automatically add all keymaps set through lazy.nvim
      enable = false,
    }
  }
}
```

### Example configuration

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
    require("commander").setup({
      components = {
        "DESC",
        "KEYS",
        "CAT",
      },
      sort_by = {
        "DESC",
        "KEYS",
        "CAT",
        "CMD"
      },
      integration = {
        telescope = {
          enable = true,
        },
        lazy = {
          enable = true
        }
      }
    })
  end,
}
```

## API

#### `comamnder.add(CommanderItem[], CommanderAddOpts)`
Add a list of `CommanderItem` to Commander.

**ComamnderItem**

| Property | Type                                        | Default  | Descirption                                |
|----------|---------------------------------------------|----------|--------------------------------------------|
| `cmd`    | `string` or `function`                      | Required | The command to be executed                 |
| `desc`   | `string?`                                   | `""`     | A nice description of the command          |
| `keys`   | `CommanderItemKey[]?` or `CommanderItemKey` | `{}`     | The keymap(s) associated with this command |
| `cat`    | `string?                                    | `""`     | The category of this command               |
| `set`    | `boolean?`                                  | `true`   | Whether to set the keymaps in `keys`       |
| `show`   | `boolean?`                                  | `true`   | Wether to show this command in the prompt  |

**CommanderAddOpts**
| Property | Type       | Default | Description                                             |
|----------|------------|---------|---------------------------------------------------------|
| `cat`    | `string?`  | `""`    | The category of all the `CommanderItem[]` to be added   |
| `set`    | `boolean?` | `true`  | Whether to set the keymaps in all the `CommanderItem[]` |
| `show`   | `boolean?` | `true`  | Wether to show all the `CommanderItem[]` in the prompt  |

**CommanderItemKey**
| Property | Type                   | Default  | Description                               |
|----------|------------------------|----------|-------------------------------------------|
| `[1]`    | `string` or `string[]` | Required | Mode, or a list of modes, for this keymap |
| `[2]`    | `string`               | Required | The lhs of this keymap                    |
| `[3]`    | `string` or `string[]` | `{}`     | Same opts accepted by nvim.keymap.set     |

##### Examples

```lua
local comamnder = require("comamnder")

comamnder.add({
  {
    desc = "Search inside current buffer",
    cmd = "<CMD>Telescope current_buffer_fuzzy_find<CR>",
    keys = { "n", "<leader>fl" },
  },  {
    -- If desc is not provided, cmd is used to replace descirption by default
    -- You can change this behavior in setup()
    cmd = "<CMD>Telescope find_files<CR>",
    keys = { "n", "<leader>ff" },
  }, {
    -- If keys are not provided, no keymaps will be displayed nor set
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
      {{"n", "x"}, "K", silent_noremap },
      {"i", "<C-k>", silent_noremap },
    }
  }, {
    -- You can pass in a key sequences as if you would type them in nvim
    desc = "My favorite key sequence",
    cmd = "A  -- Add a comment at the end of a line",
    keys = {"n", "<leader>Ac", noremap}
  }, {
    -- You can also pass in a lua functions as cmd
    -- NOTE: binding lua funciton to a keymap requires nvim >= 0.7
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
commander will create your specified keybindings automatically.
And calling `:Telescope commander`
will open a prompt like this:

![demo1](https://github.com/FeiyouG/commander.nvim/blob/assets/demo_add.png)


```lua
local comamnder = require("comamnder")

-- The keymaps of the following commands will be key (if any)
-- But the commands won't be shown when you call `require("commander").show()`
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
  show = false
})

-- The following commands will be shown in the prompt,
-- But the keymaps will not be registered;
-- This is helpful if you already registered the keymap somewhere else
-- and want to avoid set the exact keymap twice
comamnder.add({
  {
    -- If keys are specified,
    -- then they will still show up in comamnder but won't be set
    desc = "Find hidden files",
    cmd = "<CMD>Telescope find_files hidden=true<CR>",
    keys = { "n", "<leader>f.f", noremap },
  }, {
    desc = "Show document symbols",
    cmd = "<CMD>Telescope lsp_document_symbols<CR>",
  }, {
    -- Since `show` is set to `true` in this command,
    -- It overwrites the opts and this keymap will still be set
    desc = "LSP cdoe actions",
    cmd = "<CMD>Telescope lsp_code_actions<CR>",
    keybinginds = { "n", "<leader>sa", noremap },
    set = true
  }
}, {
    set = false
})

```

Above snippet will only set the keymaps
for _"Find files"_ and _"LSP code actions"_,
but not for others.
The resulted `comamnder` prompt will look like this:

![demo2](https://github.com/FeiyouG/commander.nvim/blob/assets/demo_mode.png)

### `Commander.show(CommanderShowOpts)`

Open Commander's sprompt.

**CommanderFilter**
| Property | Type               | Default | Description           |
|----------|--------------------|---------|-----------------------|
| `filter` | `CommanderFilter?` | `nil`   | The filter to be used |

**CommanderFilter**
| Property | Type      | Default | Description                                       |
|----------|-----------|---------|---------------------------------------------------|
| `cat`    | `string?` | `nil`   | Filter by the category of the comamnds            |
| `mode`   | `string?` | `nil`   | Filter by the mode of the keymaps of the commands |

If you enabled the integration with telescope,
then the following comamnds are also equivalent:
```lua
-- The same as require("commander").show()
Telescope commander

-- The same as require("commander").show({ filter = { mode = "i" } })
Telescope commander filter mode=i

-- The same as require("commander").show({ filter = { mode = "i", cat = "git" } })
Telescope commander filter mode=i cat=git
```

## Integration

### [Lazy.nvim](https://github.com/folke/lazy.nvim)

Enable integration in the config:
```lua
require("commander").setup({
  ...
  integration = {
    ...
    lazy = {
        enable = true
    }
  }
})
```

Now, commander.nvim does two things:

1. Commander will find and add all the `keys`
    that you registered through `lazy.nvim`.
2. Command will look for a new field called `commander`
    in `LazyPlugin`.
    The value of the field is expected to be `CommanderItemp[]`,
    and commander can automatically add those comamnds too.

    For example:
    ```lua
    {
      "mzlogin/vim-markdown-toc",

      ft = { "markdown" },

      cmd = { "GenTocGFM" },

      -- This command will be added to commander automatically
      commander = {
        {
          cmd = "<CMD>GenTocGFM<CR>",
          desc = "Generate table of contents (GFM)",
        }
      },

      config = function() ... end,
    }
    ```


## Special Thanks
- [technicalpickle](https://github.com/technicalpickles)
    for the suggestion of integrating commander.nvim with lazy.nvim

## Related Projects

- [which-key](https://github.com/folke/which-key.nvim)
- [hydra](https://github.com/anuvyklack/hydra.nvim)
- [Telescope-command-palette](https://github.com/LinArcX/telescope-command-palette.nvim)
- [legendary.nvim](https://github.com/mrjones2014/legendary.nvim)
