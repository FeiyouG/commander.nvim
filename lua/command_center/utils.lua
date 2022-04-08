local utils = {}

utils.set_keymap = function (keymaps, command)
  -- If only one keymap is specified
  if (#keymaps >=2 and #keymaps <= 3 and type(keymaps[1]) == "string") then
    vim.api.nvim_set_keymap(keymaps[1], keymaps[2], "<cmd>" .. command .. "<cr>", keymaps[3] or {})
    return;
  end

  -- If multiple keymaps is specified
  for _, value in ipairs(keymaps or {}) do
    vim.api.nvim_set_keymap(value[1], value[2], "<cmd>" .. command .. "<cr>", value[3] or {})
  end
end

return utils
