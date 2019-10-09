--[[
	desc: 
		* Radian, one of Drawunit.
		* It is a struct that be created by FFI, to do so is for saving memory.
	author: Musoucrow
	since: 2018-3-13
]]--

local _MATH = require("lib.math") ---@type Lib.MATH

local _FFI = require("ffi") --LuaJIT's lib. 
_FFI.cdef ("typedef struct {double value; int angle;} radian;")

---@class Graphics.Drawunit.Radian
---@field public value number
---@field public angle int
local _Radian = {}

---@param value number
---@param isAngle boolean
function _Radian:Set(value, isAngle)
	if (isAngle) then
		self.angle = value or self.angle
		self.value = _MATH.AngleToRadian(self.angle)
	else
		self.value = value or self.value
		self.angle = _MATH.RadianToAngle(self.value)
	end
end

---@param isAngle boolean
---@return number
function _Radian:Get(isAngle)
	if (isAngle) then
		return self.angle
	else
		return self.value
	end
end

---@return boolean
function _Radian:IsRaw()
	return self.value == 0
end

---@param another Graphics.Drawunit.Radian
---@return boolean
function _Radian:Compare(another)
	return self.value == another:Get()
end

local _NewRadian = _FFI.metatype ("radian",
	{
		__index = _Radian
	}
)

return {
	New = _NewRadian
}