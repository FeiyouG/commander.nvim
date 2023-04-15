local keymap_modes = { "n", "i", "c", "x", "v", "t" }

---@class Keymap
---@field modes {[integer]: string}
---@field lhs string
---@field opts {[integer]: string}
local Keymap = {}
Keymap.__mt = { __index = Keymap }

---Parse an item into Keymap object
---@param item table
---@return Keymap | nil
---@return string | nil
function Keymap:parse(item)
	local keymap = setmetatable({}, Keymap.__mt)

	-- 1, parse item
	keymap.modes = type(item[1]) == "table" and item[1] or { item[1] }
	keymap.lhs = item[2]
	keymap.opts = item[3] or {}

	-- 2, validate lhs and opts
	local _, err = pcall(vim.validate, {
		["[2]"] = { keymap.lhs, "string", false },
		["[3]"] = { keymap.opts, "table", true },
	})

	if err then
		return nil, err
	end

	-- 3, validate modes
	local err = "[1]: expected vim-mode(s) (one or a list of "
		.. vim.inspect(keymap_modes)
		.. "), got "
		.. vim.inspect(item[1])
	if not item[1] then
		return nil, err
	end
	for i, mode in ipairs(keymap.modes) do
		if not vim.tbl_contains(keymap_modes, mode) then
			return nil,
				"[1]: expected vim-mode(s) (one or a list of " .. vim.inspect(keymap_modes) .. "), got " .. vim.inspect(
					item[1]
				)
		end
	end

	return keymap, nil
end

--- Set this keymap
---@param rhs string | function the rhs of the keymap to be set
function Keymap:set(rhs)
	vim.keymap.set(self.modes, self.lhs, rhs, self.opts)
end

--- Unset this keymap
function Keymap:unset()
	vim.keymap.del(self.modes, self.lhs, self.opts)
end

---Return the string representation of the lhs of this keymap
---@return string
function Keymap:str()
	local str = ""
	for i, mode in ipairs(self.modes) do
		if i > 1 then
			str = str .. ","
		end

		str = str .. mode
	end

	str = str .. "|"

	str = str .. self.lhs

	return str
end

return Keymap
