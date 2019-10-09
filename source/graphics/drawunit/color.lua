--[[
	desc: 
		* Color, one of Drawunit.
		* It is a struct that be created by FFI, to do so is for saving memory.
	author: Musoucrow
	since: 2018-3-13
	alter: 2018-4-17
]]--

local _GRAPHICS = require("lib.graphics")
local _TABLE = require("lib.table")
local _FFI = require("ffi") --LuaJIT's lib. 

---@class Graphics.Drawunit.Color
---@field public red int
---@field public green int
---@field public blue int
---@field public alpha int
local _Color = {}

---@param red int
---@param green int
---@param blue int
---@param alpha int
function _Color:Set(red, green, blue, alpha)
	self.red = red or self.red
	self.green = green or self.green
	self.blue = blue or self.blue
	self.alpha = alpha or self.alpha
end

---@param color Graphics.Drawunit.Color
function _Color:SetByColor(color)
	self:Set(color:Get())
end

---@param name string @If it is null, that will return all values.
---@return number
function _Color:Get(name)
	if (name) then
		return self[name]
	else
		return self.red, self.green, self.blue, self.alpha
	end
end

---@return boolean
function _Color:IsRaw()
	return self.red == 255 and self.green == 255 and self.blue == 255 and self.alpha == 255
end

---@param another Graphics.Drawunit.Color
---@return boolean
function _Color:Compare(another)
	local red, green, blue, alpha = another:Get()

	return self.red == red and self.green == green and self.blue == blue and self.alpha == alpha
end

function _Color:Apply()
	_GRAPHICS.SetColor(self.red, self.green, self.blue, self.alpha)
end

_FFI.cdef("typedef struct {int red, green, blue, alpha;} color;")

local _NewColor = _FFI.metatype("color",
	{
		__index = _Color,
		__pairs = _TABLE.NewCdataPairs({
			red = true,
			green = true,
			blue = true,
			alpha = true
		})
	}
)

---@param red int
---@param green int
---@param blue int
---@param alpha int
---@return Graphics.Drawunit.Color
local function _New(red, green, blue, alpha)
	red = red or 255
	green = green or 255
	blue = blue or 255
	alpha = alpha or 255
	
	return _NewColor(red, green, blue, alpha)
end

return {
	New = _New,
	white = _New(),
	black = _New(0, 0, 0, 255),
	red = _New(255, 0, 0, 255),
	yellow = _New(255, 255, 0, 255),
	alpha = _New(255, 255, 255, 127),
	blue = _New(99, 126, 180, 255)
}