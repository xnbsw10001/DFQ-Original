--[[
	desc: 
		* Point, one of Drawunit.
		* It is a struct that be created by FFI, to do so is for saving memory.
		* It has two kinds of struct: integer and float.
	author: Musoucrow
	since: 2018-3-13
	alter: 2018-6-8
]]--

local _FFI = require("ffi") --LuaJIT's lib. 
local _GRAPHICS = require("lib.graphics")
local _TABLE = require("lib.table")

---@class Graphics.Drawunit.Point
---@field public x number
---@field public y number
local _Point = {}

local _metatable = {
    __index = _Point,
    __pairs = _TABLE.NewCdataPairs({
        x = true,
        y = true
    })
}

---@param x int
---@param y int
function _Point:Set(x, y)
	self.x = x or self.x
	self.y = y or self.y
end

---@param point Graphics.Drawunit.Point
function _Point:SetByPoint(point)
	self:Set(point:Get())
end

---@param x int
---@param y int
function _Point:Move(x, y)
	self.x = self.x + x
	self.y = self.y + y
end

---@param name string @If it is null, that will return all values.
---@return int
function _Point:Get(name)
	if (name) then
		return self[name]
	else
		return self.x, self.y
	end
end

---@return boolean
function _Point:IsRaw()
	return self.x == 0 and self.y == 0
end

---@param another Graphics.Drawunit.Point
---@return boolean
function _Point:Compare(another)
	local x, y = another:Get()
	
	return self.x == x and self.y == y
end

---@param size int
---@param color Graphics.Drawunit.Color
function _Point:Draw(size, color)
	if (color) then
		color:Apply()
	end

	_GRAPHICS.DrawCircle(self.x, self.y, size)
	
	if (color) then
		_GRAPHICS.ResetColor()
	end
end

_FFI.cdef ("typedef struct {int x, y;} integerPoint;")
local _IntegerPoint = _FFI.metatype ("integerPoint", _metatable)

_FFI.cdef ("typedef struct {double x, y;} floatPoint;")
local _FloatPoint = _FFI.metatype ("floatPoint", _metatable)

---@param isInt boolean
---@param x number @default=0
---@param y number @default=0
local function _New(isInt, x, y)
	x = x or 0
	y = y or 0

	if (isInt) then
		return _IntegerPoint (x, y)
	else
		return _FloatPoint (x, y)
	end
end

return {
	New = _New
}