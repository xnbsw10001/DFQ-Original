--[[
	desc: INPUT, a lib that encapsulate input function.
	author: Musoucrow
	since: 2018-5-22
	alter: 2019-2-10
]]--

local _CONFIG = require("config")

---@class Lib.INPUT
---@field public enum enum @the enum of input's states.
local _INPUT = {
	enum = {pressed = 0, hold = 1, released = 2}
}

---@param map map
---@param key string
---@return bool
function _INPUT.IsPressed(map, key)
	return map[key] == _INPUT.enum.pressed
end

---@param map map
---@param key string
---@return bool
function _INPUT.IsHold(map, key)
	return map[key] == _INPUT.enum.hold
end

---@param map map
---@param key string
---@return bool
function _INPUT.IsReleased(map, key)
	return map[key] == _INPUT.enum.released
end

---@param map map
---@param key string
function _INPUT.OnPressed(map, key)
	map[key] = map[key] and _INPUT.enum.hold or _INPUT.enum.pressed

	return true
end

---@param map map
---@param key string
function _INPUT.OnReleased(map, key)
	if (map[key] and map[key] ~= _INPUT.enum.released) then
		map[key] = _INPUT.enum.released

		return true
	end

	return false
end

---@param map map
function _INPUT.Update(map)
	for k in pairs(map) do
		if (map[k] == _INPUT.enum.pressed) then
			map[k] = _INPUT.enum.hold
		elseif (map[k] == _INPUT.enum.released) then
			map[k] = nil
		end
	end
end

---@param name string
---@param value string
function _INPUT.SetKey(name, value)
	if (_CONFIG.anticode[_CONFIG.code[name]] == name) then
		_CONFIG.anticode[_CONFIG.code[name]] = nil
	end

	_CONFIG.code[name] = value
	_CONFIG.anticode[value] = name
end

return _INPUT