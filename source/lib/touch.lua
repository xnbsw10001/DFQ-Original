--[[
	desc: TOUCH, a lib that encapsulate touch function.
	author: Musoucrow
	since: 2018-5-27
	alter: 2019-8-19
]]--

local _INPUT = require("lib.input")

local _Caller = require("core.caller")

local _pointMap = {} ---@type table<id, Lib.TOUCH.Point>

---@type table<string, Core.Caller>
local _callerMap = {
	onPressed = _Caller.New(),
	onReleased = _Caller.New(),
	onMoved = _Caller.New()
}

---@param point Lib.TOUCH.Point
---@return boolean
local function _IsPressed(point)
	return point.status == _INPUT.enum.pressed
end

---@param point Lib.TOUCH.Point
---@return boolean
local function _IsReleased(point)
	return point.status == _INPUT.enum.released
end

---@param point Lib.TOUCH.Point
---@return boolean
local function _IsHold(point)
	return point.status == _INPUT.enum.hold
end

local function _NewPoint(id, x, y, dx, dy, pressure)
	if (_pointMap[id]) then
		_pointMap[id].x = x
		_pointMap[id].y = y
		_pointMap[id].dx = dx
		_pointMap[id].dy = dy
		_pointMap[id].pressure = pressure
		_pointMap[id].moving = true
	else
		---@class Lib.TOUCH.Point
		_pointMap[id] = {x = x, y = y, dx = dx, dy = dy, pressure = pressure, moving = true, IsPressed = _IsPressed, IsReleased = _IsReleased, IsHold = _IsHold}
	end
end

local _TOUCH = {} ---@class Lib.TOUCH

---@param type string
---@param obj table
---@param Func func
function _TOUCH.AddListener(type, obj, Func)
	_callerMap[type]:AddListener(obj, Func)
end

---@param type string
---@param obj table
---@param Func func
function _TOUCH.DelListener(type, obj, Func)
	_callerMap[type]:DelListener(obj, Func)
end

---@return table<id, Lib.TOUCH.Point>
function _TOUCH.GetPoints()
	return _pointMap
end

---@return Lib.TOUCH.Point
function _TOUCH.GetPoint(id)
    return _pointMap[id]
end

---@param id any
---@param x int
---@param y int
---@param dx int
---@param dy int
---@param pressure int @It always is 1.
function _TOUCH.Moved(id, x, y, dx, dy, pressure)
	_NewPoint(id, x, y, dx, dy, pressure)
	_callerMap.onMoved:Call(id, x, y, dx, dy, pressure)
end

---@param id any
---@param x int
---@param y int
---@param dx int
---@param dy int
---@param pressure int @It always is 1.
function _TOUCH.Pressed(id, x, y, dx, dy, pressure)
	_NewPoint(id, x, y, dx, dy, pressure)
	_pointMap[id].status = _INPUT.enum.pressed
	_callerMap.onPressed:Call(id, x, y, dx, dy, pressure)
end

---@param id any
---@param x int
---@param y int
---@param dx int
---@param dy int
---@param pressure int @It always is 1.
function _TOUCH.Released(id, x, y, dx, dy, pressure)
	_NewPoint(id, x, y, dx, dy, pressure)
	_pointMap[id].status = _INPUT.enum.released
	_callerMap.onReleased:Call(id, x, y, dx, dy, pressure)
end

function _TOUCH.LateUpdate()
	for k, v in pairs(_pointMap) do
		if (v.moving) then
			v.moving = false
		elseif (v.moving == false) then
			v.dx = 0
			v.dy = 0
			v.moving = nil
		end

		if (v.status == _INPUT.enum.pressed) then
			v.status = _INPUT.enum.hold
		elseif (v.status == _INPUT.enum.released) then
			_pointMap[k] = nil
		end
	end
end

return _TOUCH