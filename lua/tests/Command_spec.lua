local Command = require("commander.model.Command")
local keymap_modes = { "n", "v", "x", "s", "o", "!", "i", "l", "c", "t", }

describe("Command:parse()", function()
  it("correct simple item", function()
    local item = {
      desc = "test parsing a command",
      cmd = "<CMD>echo hello<CR>",
      keys = { "n", "<leader>a" },
      set = false,
      show = true,
      cat = "test",
    }
    local command, err = Command:parse(item)
    assert.Nil(err)
    assert.equal(command.desc, item.desc)
    assert.equal(command.non_empty_desc, item.desc)
    assert.equal(command.cmd, item.cmd)
    assert.equal(command.cmd_str, item.cmd)
    assert.equal(#command.keymaps, 1)
    assert.equal(command.cat, item.cat)
    assert.equal(command.set, item.set)
    assert.equal(command.show, item.show)
  end)

  it("correct complex item", function()
    local item = {
      cmd = function()
        print("helilo")
      end,
      keys = {
        { "n",     "<leader>a" },
        { "v",     "<leader>b" },
        { { "i" }, "<leader>c" },
      },
      cat = "test",
    }
    local command, err = Command:parse(item)

    assert.Nil(err)
    assert.equal(command.desc, "")
    assert.equal(command.non_empty_desc, "<anonymous> lua function")
    assert.equal(command.cmd, item.cmd)
    assert.equal(command.cmd_str, "<anonymous> lua function")
    assert.equal(#command.keymaps, #item.keys)
    assert.equal(command.set, true)
    assert.equal(command.show, true)
  end)

  it("command without valid cmd", function()
    local item = {
      desc = "test parsing a command",
      keys = { "n", "<leader>a" },
      set = false,
      cat = "test",
    }
    local _, err = Command:parse(item)
    assert.equal("cmd: expected string|function, got nil", err)

    item = {
      desc = "test parsing a command",
      keys = { "n", "<leader>a" },
      set = false,
      cat = "test",
      cmd = 123,
    }
    _, err = Command:parse(item)
    assert.equal("cmd: expected string|function, got number", err)
  end)

  it("command without valid keymap", function()
    local item = {
      keys = {
        { "n",     "<leader>b" },
        { { "a" }, "<leader>a" },
      },
      cmd = "<CMD>echo hello<CR>",
    }
    local _, err = Command:parse(item)
    assert.equal(
      'keys[2][1]: expected vim-mode(s) (one or a list of ' .. vim.inspect(keymap_modes) .. '), got { "a" }',
      err
    )

    item = {
      keys = { nil, "<leader>b" },
      cmd = "<CMD>echo hello<CR>",
    }
    _, err = Command:parse(item)
    assert.equal('keys[1]: expected vim-mode(s) (one or a list of ' .. vim.inspect(keymap_modes) .. '), got nil', err)

  end)
end)

describe("Command:execute()", function()
  -- it("vim command as cmd", function()
  -- end)

  it("lua function as cmd", function()
    local cnt = 0
    local item = {
      desc = "test parsing a command",
      cmd = function()
        cnt = cnt + 1
      end,
      keys = { "n", "<leader>a" },
      set = false,
      cat = "test",
    }
    local command, _ = Command:parse(item)
    command:execute()
    assert.equal(1, cnt)

    command:execute()
    assert.equal(2, cnt)
  end)
end)
