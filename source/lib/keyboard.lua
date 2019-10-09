--[[
	desc: KEYBOARD, a lib that encapsulate keyboard function.
	author: Musoucrow
	since: 2018-5-27
	alter: 2019-3-15
]]--

local _INPUT = require("lib.input")

local _Caller = require("core.caller")

local _map = {}
local _pressKey
local _releasedKey

---@type table<string, Core.Caller>
local _callerMap = {
	onPressed = _Caller.New(),
	onReleased = _Caller.New()
}

---@class Lib.KEYBOARD
local _KEYBOARD = {}

---@param type string
---@param obj table
---@param Func func
function _KEYBOARD.AddListener(type, obj, Func)
	_callerMap[type]:AddListener(obj, Func)
end

---@param type string
---@param obj table
---@param Func func
function _KEYBOARD.DelListener(type, obj, Func)
	_callerMap[type]:DelListener(obj, Func)
end

---@param key string
---@return bool
function _KEYBOARD.IsPressed(key)
	return _INPUT.IsPressed(_map, key)
end

---@param key string
---@return bool
function _KEYBOARD.IsHold(key)
	return _INPUT.IsHold(_map, key)
end

---@param key string
---@return bool
function _KEYBOARD.IsReleased(key)
	return _INPUT.IsReleased(_map, key)
end

---@param key string
function _KEYBOARD.Pressed(key)
	if (_INPUT.OnPressed(_map, key)) then
		_pressKey = key
		_callerMap.onPressed:Call(key)
	end
end

---@param key string
function _KEYBOARD.Released(key)
	if (_INPUT.OnReleased(_map, key)) then
		_releasedKey = key
		_callerMap.onReleased:Call(key)
	end
end

function _KEYBOARD.LateUpdate()
	_pressKey = nil
	_releasedKey = nil
	_INPUT.Update(_map)
end

function _KEYBOARD.GetPressedKey()
	return _pressKey
end

function _KEYBOARD.GetReleasedKey()
	return _releasedKey
end

return _KEYBOARD