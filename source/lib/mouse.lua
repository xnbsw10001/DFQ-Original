--[[
	desc: MOUSE, a lib that encapsulate mouse function.
	author: Musoucrow
	since: 2018-5-22
	alter: 2018-12-5
]]--

local _INPUT = require("lib.input")

local _Caller = require("core.caller")

local _x = 0
local _y = 0
local _dx = 0
local _dy = 0
local _map = {}

---@type table<string, Core.Caller>
local _callerMap = {
	onPressed = _Caller.New(),
	onReleased = _Caller.New(),
	onMoved = _Caller.New()
}

local _MOUSE = {} ---@class Lib.MOUSE

---@param type string
---@param obj table
---@param Func func
function _MOUSE.AddListener(type, obj, Func)
	_callerMap[type]:AddListener(obj, Func)
end

---@param type string
---@param obj table
---@param Func func
function _MOUSE.DelListener(type, obj, Func)
	_callerMap[type]:DelListener(obj, Func)
end

---@param sx int
---@param sy int
---@return number
function _MOUSE.GetPosition(sx, sy)
	sx = sx or 1
	sy = sy or 1
	
	return _x / sx, _y / sy
end

---@param sx int
---@param sy int
---@return number @mx & my
function _MOUSE.GetMoving(sx, sy)
	sx = sx or 1
	sy = sy or 1
	
	return _dx / sx, _dy / sy
end

---@param key int @1:primary, 2:secondary, 3:middle.
---@return bool
function _MOUSE.IsPressed(key)
	return _INPUT.IsPressed(_map, key)
end

---@param key int @1:primary, 2:secondary, 3:middle.
---@return bool
function _MOUSE.IsHold(key)
	return _INPUT.IsHold(_map, key)
end

---@param key int @1:primary, 2:secondary, 3:middle.
---@return bool
function _MOUSE.IsReleased(key)
	return _INPUT.IsReleased(_map, key)
end

---@param x int
---@param y int
---@param dx int
---@param dy int
function _MOUSE.Moved(x, y, dx, dy)
	_x = x
	_y = y
	_dx = dx
	_dy = dy

	_callerMap.onMoved:Call(x, y, dx, dy)
end

---@param key int @1:primary, 2:secondary, 3:middle.
function _MOUSE.Pressed(key)
	_INPUT.OnPressed(_map, key)
	_callerMap.onPressed:Call(key)
end

---@param key int @1:primary, 2:secondary, 3:middle.
function _MOUSE.Released(key)
	_INPUT.OnReleased(_map, key)
	_callerMap.onReleased:Call(key)
end

function _MOUSE.LateUpdate()
	_INPUT.Update(_map)
	_dx = 0
	_dy = 0
end

return _MOUSE