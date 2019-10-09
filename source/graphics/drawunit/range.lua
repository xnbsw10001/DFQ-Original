--[[
	desc:
		* Range, one of Drawunit.
		* It is a struct that be created by FFI, to do so is for saving memory.
	author: Musoucrow
	since: 2018-5-14
	alter: 2018-10-2
]]--

local _TABLE = require("lib.table")
local _GRAPHICS = require("lib.graphics")
local _FFI = require("ffi") --LuaJIT's lib.

---@class Graphics.Drawunit.Range
---@field public xa int
---@field public xb int
---@field public ya int
---@field public yb int
local _Range = {}

---@param xa int
---@param xb int
---@param ya int
---@param yb int
function _Range:Set(xa, xb, ya, yb)
    self.xa = xa or self.xa
    self.xb = xb or self.xb
    self.ya = ya or self.ya
    self.yb = yb or self.yb
end

function _Range:Get()
    return self.xa, self.xb, self.ya, self.yb
end

---@param x int
---@param y int
---@param ox int
---@param oy int
---@return boolean
function _Range:Collide(x, y, ox, oy)
    return ox > x + self.xa and ox < x + self.xb and oy > y + self.ya and oy < y + self.yb
end

function _Range:Draw(x, y)
    _GRAPHICS.DrawRect(x + self.xa, y + self.ya, self.xb - self.xa, self.yb - self.ya)
end

_FFI.cdef("typedef struct {int xa, xb, ya, yb;} range;")

local _NewRange = _FFI.metatype("range",
        {
            __index = _Range,
            __pairs = _TABLE.NewCdataPairs({
                xa = true,
                xb = true,
                ya = true,
                yb = true
            })
        }
)

---@param xa int
---@param xb int
---@param ya int
---@param yb int
---@return Graphics.Drawunit.Range
local function _New(xa, xb, ya, yb)
    xa = xa or 0
    xb = xb or 0
    ya = ya or 0
    yb = yb or 0

    return _NewRange(xa, xb, ya, yb)
end

return {
    New = _New
}