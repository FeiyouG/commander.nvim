local Keymap = require("commander.model.Keymap")
local constants = require("commander.constants")

local anon_lua_func_name = "<anonymous> lua function"

---@class Command
---@field cmd string | function
---@field cmd_str string the string represetnation of the cmd
---@field desc string
---@field non_empty_desc string same as cmd_str if desc is empty; otherwise same as desc
---@field keymaps {[integer]: Keymap}
---@field keymaps_str string the string representation of the keymaps
---@field cat string
---@field mode integer
local Command = {}
Command.__mt = { __index = Command }

-- MARK: Local Helper Functions

-- Best effort to infer function names for actions.which_key
-- Copied from https://github.com/nvim-telescope/telescope.nvim/blob/75a5e5065376d9103fc4bafc3ae6327304cee6e9/lua/telescope/actions/utils.lua#L110
local function get_lua_func_name(func_ref)
  local Path = require("plenary.path")
  local info = debug.getinfo(func_ref)
  local fname
  -- if fn defined in string (ie loadstring) source is string
  -- if fn defined in file, source is file name prefixed with a `@´
  local path = Path:new((info.source:gsub("@", "")))
  if not path:exists() then
    return anon_lua_func_name
  end
  for i, line in ipairs(path:readlines()) do
    if i == info.linedefined then
      fname = line
      break
    end
  end

  -- test if assignment or named function, otherwise anon
  if (fname:match("=") == nil) and (fname:match("function %S+%(") == nil) then
    return anon_lua_func_name
  else
    local patterns = {
      { "function", "" }, -- remove function
      { "local", "" }, -- remove local
      { "[%s=]", "" }, -- remove whitespace and =
      { [=[%[["']]=], "" }, -- remove left-hand bracket of table assignment
      { [=[["']%]]=], "" }, -- remove right-ahnd bracket of table assignment
      { "%((.+)%)", "" }, -- remove function arguments
      { "(.+)%.", "" }, -- remove TABLE. prefix if available
      { "end,$", "" }, -- remove end and comma (in case of an inline function)
      { "cmd()", "" }, -- remove cmd() (for anonymous funciton defined in cmd)
    }
    for _, tbl in ipairs(patterns) do
      fname = (fname:gsub(tbl[1], tbl[2])) -- make sure only string is returned
    end
    -- not sure if this can happen, catch all just in case
    if fname == nil or fname == "" then
      return anon_lua_func_name
    end

    return fname
  end
end

-- MARK: Public methods

---Parse an item into Command
---@param item table | nil
---@param opts table | nil
---@return Command|nil command
---@return string | nil error
function Command:parse(item, opts)
  if not item then
    return
  end

  opts = opts or {}

  local command = setmetatable({}, Command.__mt)

  -- Ensure backword compatibility
  command.cmd = item.cmd or item.command
  command.desc = item.desc or item.description or ""
  command.cat = item.cat or item.category or opts.cat or opts.category or ""
  command.mode = item.mode or opts.mode or constants.mode.ADD_SET

  -- Check whether this is a valid command
  local _, err = pcall(vim.validate, {
    cmd = { command.cmd, { "string", "function" }, false },
    desc = { command.desc, "string", false },
    cat = { command.cat, "string", false },
    mode = {
      command.mode,
      function(m)
        return m >= constants.mode.ADD and m <= constants.mode.ADD_SET
      end,
      "expect one of " .. vim.inspect(constants.mode) .. ", but got " .. command.mode,
    },
  })

  if err then
    return nil, vim.inspect(item) .. err
  end

  command.cmd_str = type(command.cmd) == "function" and get_lua_func_name(item.cmd) or item.cmd
  command.non_empty_desc = command.desc and command.desc or command.cmd_str

  -- Parse keymaps
  command.keymaps = {}
  command.keymaps_str = ""

  ---@diagnostic disable-next-line: redefined-local
  local keymap, err = Keymap:parse(item.keys or item.keybindings or {})
  if not err then
    table.insert(command.keymaps, keymap)
    ---@diagnostic disable-next-line: need-check-nil
    command.keymaps_str = keymap:str()
    return command, nil
  end

  -- Making sure the passed-in keys is a 2D array
  for i, key in ipairs(item.keys or item.keybindings or {}) do
    ---@diagnostic disable-next-line: redefined-local
    local keymap, err = Keymap:parse(key)
    if not keymap or err then
      return nil, vim.inspect(item) .. "\nkeys[" .. i .. "]" .. err
    end

    table.insert(command.keymaps, keymap)

    if i > 1 then
      command.keymaps_str = command.keymaps_str .. " "
    end
    command.keymaps_str = command.keymaps_str .. keymap:str()
  end

  return command, nil
end

---Set all keymaps in this command
function Command:set_keymaps()
  if self.mode == constants.mode.ADD then
    return
  end

  for _, keymap in ipairs(self.keymaps) do
    keymap:set(self.cmd)
  end
end

---Unset all keymaps in this command
function Command:unset_keymaps()
  if self.mode == constants.mode.ADD then
    return
  end

  for _, keymap in ipairs(self.keymaps) do
    keymap:unset()
  end
end

---Execute this command
function Command:execute()
  if type(self.cmd) == "function" then
    self.cmd()
  else
    local cmd = vim.api.nvim_replace_termcodes(self.cmd, true, false, true)
    vim.api.nvim_feedkeys(cmd, "t", true)
  end
end

return Command
