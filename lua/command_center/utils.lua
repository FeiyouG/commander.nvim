local constants = require("command_center.constants")

local M = {}

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
    return constants.anon_lua_func_name
  end
  for i, line in ipairs(path:readlines()) do
    if i == info.linedefined then
      fname = line
      break
    end
  end

  -- test if assignment or named function, otherwise anon
  if (fname:match("=") == nil) and (fname:match("function %S+%(") == nil) then
    return constants.anon_lua_func_name
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
      return constants.anon_lua_func_name
    end

    return fname
  end
end

---Use a pcall to protect a call to vim.validate
---@param tbl table: the parameter specification, same as the arguments to `vim.validate`
---@return boolean is_validate: true if `tbl` is validate
---@return string|nil err: an error message if the `is_validae` if failed; nil otherwise
local function validate(tbl)
  return pcall(vim.validate, tbl)
end

---Check if item is validate to add to command_center
---@param item table: the item to be validated
---@return boolean is_validate: true if `tbl` is validate
---@return string|nil err: an error message if the `is_validae` if failed; nil otherwise
local function validate_item(item)
  return validate({
    cmd = { item.cmd, { "string", "function" }, false },
    desc = { item.desc, "string", true },
    keys = { item.keys, "table", true },
    mode = {
      item.mode,
      function(mode)
        if not mode then
          return true
        end
        for _, mode_num in pairs(constants.mode) do
          if mode_num == mode then
            return true
          end
        end
        return false
      end,
      "comment_center.mode",
    },
    cat = { item.cat, "string", true },

    hydra_head_args = { item.hydra_head_args, "table", true },
  })
end

---Check if key is validate to be set
---@param key table: the item to be validated
---@return boolean is_validate: true if `tbl` is validate
---@return string|nil err: an error message if the `is_validae` if failed; nil otherwise
local function validate_raw_key(key)
  return validate({
    mode = {
      key[1],
      function(mode)
        if not mode then
          return false
        end
        mode = type(mode) == "string" and { mode } or mode

        for _, m in ipairs(mode) do
          if not vim.tbl_contains(constants.keymap_modes, m) then
            return false
          end
        end
        return true
      end,
      "one of " .. vim.inspect(constants.keymap_modes),
    },
    lhs = { key[2], "string", false },
    opts = { key[3], "table", true },
  })
end

-- MARK: Public Functions

---@return boolean: true if tbl is an non-empty list
function M.is_nonempty_list(tbl)
  return tbl and vim.tbl_islist(tbl) and not vim.tbl_isempty(tbl)
end

---@return boolean: true if tbl is an non-empty table
function M.is_nonempty_tbl(tbl)
  return tbl and not vim.tbl_islist(tbl) and not vim.tbl_isempty(tbl)
end

---Properly parse each item:
---1. Convert deprecated fields
---2. Convert keys
---3. Create string represetnation for cmd and keys
---4. Create id for the item
---@param item table: the item to be converted
---@param opts table?: additional options
function M.convert_item(item, opts)
  opts = opts or {}
  item = vim.deepcopy(item)

  item.cmd = item.cmd or item.command
  item.desc = item.desc or item.description or ""
  item.keys = item.keys or item.keybindings or nil
  item.mode = item.mode or opts.mode or constants.mode.ADD_SET
  item.cat = item.cat or item.category or opts.cat or opts.category or ""

  item.command = nil
  item.description = nil
  item.keybindings = nil
  item.category = nil

  local res, err = validate_item(item)
  if not res then
    local message = "Invalid declaration of item; item will be ignored:\n"
        .. (err or "")
        .. "\n"
        .. vim.inspect(item)
    vim.notify(message, vim.log.levels.WARN)
    return nil
  end

  item.keys = M.convert_keys(item.desc, item.cmd, item.keys, opts.keys_opts)
  item.keys_str = M.get_keys_str(item.keys)
  item.cmd_str = type(item.cmd) == "function" and get_lua_func_name(item.cmd) or item.cmd
  item.replaced_desc = item.desc and item.desc or item.cmd_str
  item.id = item.desc .. item.cmd_str .. item.keys_str

  return item
end

---Convert opts (for backward capatibility)
function M.convert_opts(opts)
  opts = opts and vim.deepcopy(opts) or {}
  if type(opts) == "number" then
    opts = { mode = opts }
  elseif type(opts) == "string" then
    opts = { category = opts }
  end
  return opts
end

function M.convert_keys(desc, cmd, keys, opts)
  if not M.is_nonempty_list(keys) then
    return {}
  end
  opts = opts and vim.deepcopy(opts) or {}

  -- Check whether cmd is a string or a lua callback
  if type(cmd) == "function" then
    opts = vim.tbl_extend("force", opts, { callback = cmd })
    cmd = ""
  end

  if desc then
    opts.desc = desc
  end

  -- Convert keys to a 2D list if it is a 1D list
  local is_valid, _ = validate_raw_key(keys)
  if is_valid then
    keys = { keys }
  end

  local converted_key = {}
  for _, key in ipairs(keys) do
    local res, err = validate_raw_key(key)
    if not res then
      local message = "Invalid declaration of keys:\n" .. err .. "\n" .. vim.inspect(key)
      vim.notify(message, vim.log.levels.WARN)
      goto continue
    end

    local new_key = {
      mode = key[1],
      lhs = key[2],
      rhs = cmd,
      opts = vim.tbl_extend("keep", key[4] or {}, opts),
    }

    table.insert(converted_key, new_key)

    ::continue::
  end

  return converted_key
end

function M.set_converted_keys(keys)
  for _, key in ipairs(keys) do
    vim.keymap.set(key.mode, key.lhs, key.rhs, key.opts)
  end
end

function M.del_converted_keys(keys)
  for _, key in ipairs(keys) do
    vim.keymap.del(key.mode, key.lhs, key.opts)
  end
end

---Convert keys to a 2D list if it is a 1D list;
---then, append opts to all opts within each key;
---finally sort the keys based on mode
---@return table: a formatted keys in a 2D array
function M.format_keys(keys, opts)
  if not keys or vim.tbl_isempty(keys) then
    return {}
  end
  opts = opts or {}

  -- Convert keys to a 2D list if it is 1D list
  local is_key, _ = validate_raw_key(keys)
  if is_key then
    keys = { keys }
  end

  local formatted_keys = {}
  for _, key in ipairs(keys) do
    local res, err = validate_raw_key(key)
    if not res then
      local message = "Invalid declaration of keys:\n" .. err .. "in\n" .. vim.inspect(key)
      vim.notify(message, vim.log.levels.WARN)
      goto continue
    end

    key[3] = key[3] or {}
    vim.list_extend(key[3], opts)
    table.insert(formatted_keys, key)

    ::continue::
  end

  table.sort(formatted_keys, function(lhs, rhs)
    return lhs[1] < rhs[2]
  end)
  return formatted_keys
end

---Generate the string representation of keybindings
---@param keybindings table: properly formatted keybindings (by called format_keybindings)
function M.get_keys_str(keybindings)
  local res = ""

  for i, keymap_mode in ipairs(constants.keymap_modes) do
    local filter_keys_by_mode = function(key)
      return key.mode == keymap_mode
    end

    local keys_under_mode = vim.tbl_filter(filter_keys_by_mode, keybindings)

    for j, key in ipairs(keys_under_mode) do
      res = res .. (j == 1 and (" " .. keymap_mode .. "|") or ",") .. key.lhs
    end
  end

  return res:gsub("^%s+", "")
end

---Get the max width of the result display
---takes into consideration of the length of each component
---and what component to display
---@param user_opts table: user settings, must contains component and seperator
---@param length table:  a table contains the max length for each component
function M.get_max_width(user_opts, length)
  local max_width = 0
  for i, component in ipairs(user_opts.components) do
    if component == constants.component.DESC and user_opts.auto_replace_desc_with_cmd then
      max_width = max_width + length[constants.component.REPLACED_DESC]
    else
      max_width = max_width + length[component]
    end

    -- Add "seperator" to avoid breaking existing configurations
    if i > 0 then
      max_width = max_width + #user_opts.separator
    end
  end

  return max_width + 6 -- Leave some margin at the end
end

-- Filter items based on filter
---@return table: filtered item as a list
---@return integer: number of items returned
function M.filter_items(items, filter)
  local filter_func = {
    mode = function(item, mode)
      for _, key in ipairs(item.keys or {}) do
        if key.mode == mode then
          return true
        end
      end
      return false
    end,

    cat = function(item, cat)
      return item.cat == cat
    end,

    -- @deprecated
    category = function(item, cat)
      return item.cat == cat
    end,
  }

  local count = 0
  local filtered_item = vim.tbl_filter(function(item)
    for k, v in pairs(filter) do
      if not filter_func[k](item, v) then
        return false
      end
    end

    count = count + 1
    return true
  end, items)

  return filtered_item, count
end

function M.sort_items(items, sort_by)
  table.sort(items, function(a, b)
    for _, k in ipairs(sort_by) do
      if a[k] and b[k] then
        return a[k] < b[k]
      end
    end
    return a.id < b.id
  end)

  -- sort is in place, but we return items so it is consistent with filter_items function
  return items
end

return M
