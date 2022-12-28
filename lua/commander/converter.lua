local M = {}
local utils = require("commander.utils")

local function convert_to_helper(items, opts, args_to_perserve, callback)

  if not utils.is_nonempty_list(items) then return end
  opts = utils.convert_opts(opts)


  for _, item in ipairs(items) do

    if args_to_perserve then
      local perserved = item[args_to_perserve] or opts[args_to_perserve]
      if perserved then
        opts.keys_opts = vim.tbl_extend("force", opts.keys_opts or {}, perserved)
      end
    end

    item = utils.convert_item(item, opts)
    if not item then goto continue end

    for _, key in ipairs(item.keys) do
      callback(key, item)
    end

    ::continue::
  end

end

---Converts a list of commands used by `command_center`
---@param commands table?: the commands to be converted
function M.to_nvim_set_keymap(commands, opts)
  local keys = {}

  convert_to_helper(commands, opts, nil, function(key)
    vim.list_extend(keys, { { key.mode, key.lhs, key.rhs, key.opts } })
  end)

  return keys

end

---Converts a list of commands used by `command_center`
---@param commands table?: the commands to be converted
function M.to_hydra_heads(commands, opts)
  local keys = {}

  convert_to_helper(commands, opts, "hydra_head_args", function(key)

    local cmd = key.rhs

    if key.opts and key.opts.callback then
      cmd = key.opts.callback
      key.opts.callback = nil
    end

    vim.list_extend(keys, { { key.lhs, cmd, key.opts } })
  end)

  return keys
end


return M
