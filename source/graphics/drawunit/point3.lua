--[[
	desc:
		* Point3, one of Drawunit.
		* It is a struct that be created by FFI, to do so is for saving memory.
		* It has two kinds of struct: integer and float.
	author: Musoucrow
	since: 2018-10-30
	alter: 2019-4-17
]]--

local _GRAPHICS = require("lib.graphics")
local _TABLE = require("lib.table")
local _FFI = require("ffi") --LuaJIT's lib.

---@class Graphics.Drawunit.Point3
---@field public x number
---@field public y number
---@field public z number
local _Point = {}

local _metatable = {
    __index = _Point,
    __pairs = _TABLE.NewCdataPairs({
        x = true,
        y = true,
        z = true
    })
}

---@param x int
---@param y int
---@param z int
function _Point:Set(x, y, z)
    self.x = x or self.x
    self.y = y or self.y
    self.z = z or self.z
end

---@param point Graphics.Drawunit.Point | Graphics.Drawunit.Point3
function _Point:SetByPoint(point)
    self:Set(point:Get())
end

---@param x int
---@param y int
---@param z int
function _Point:Move(x, y, z)
    self.x = self.x + x
    self.y = self.y + y
    self.z = self.z + z
end

---@param name string @If it is null, that will return all values.
---@return int
function _Point:Get(name)
    if (name) then
        return self[name]
    else
        return self.x, self.y, self.z
    end
end

---@return boolean
function _Point:IsRaw()
    return self.x == 0 and self.y == 0 and self.z == 0
end

---@param another Graphics.Drawunit.Point | Graphics.Drawunit.Point3
---@return boolean
function _Point:Compare(another)
    local x, y, z = another:Get()
    z = z or 0

    return self.x == x and self.y == y and self.z == z
end

---@param size int
---@param color Graphics.Drawunit.Color
function _Point:Draw(size, color)
    if (color) then
        color:Apply()
    end

    _GRAPHICS.DrawLine(self.x, self.y, self.x, self.y + self.z)
    _GRAPHICS.DrawCircle(self.x, self.y, size)
    _GRAPHICS.DrawCircle(self.x, self.y + self.z, size)

    if (color) then
        _GRAPHICS.ResetColor()
    end
end

_FFI.cdef ("typedef struct {int x, y, z;} integerPoint3;")
local _IntegerPoint = _FFI.metatype ("integerPoint3", _metatable)

_FFI.cdef ("typedef struct {double x, y, z;} floatPoint3;")
local _FloatPoint = _FFI.metatype ("floatPoint3", _metatable)

---@param isInt boolean
---@param x number @default=0
---@param y number @default=0
---@param z number @default=0
local function _New(isInt, x, y, z)
    x = x or 0
    y = y or 0
    z = z or 0

    if (isInt) then
        return _IntegerPoint (x, y, z)
    else
        return _FloatPoint (x, y, z)
    end
end

return {
    New = _New
}
