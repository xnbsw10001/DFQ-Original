--[[
	desc: SolidRect, its a solid rect.
	author: Musoucrow
	since: 2018-7-17
	alter: 2019-6-5
]]--

local _Rect = require("graphics.drawunit.rect")

---@class Graphics.Drawunit.SolidRect
---@field protected _x int
---@field protected _y int
---@field protected _z int
---@field protected _sx number
---@field protected _sy number
---@field protected _r number
---@field protected _struct table
---@field public rectGroup table<string, Actor.Drawable.Rectangle>
local _SolidRect = require("core.class")()

---@param a table<number, Graphics.Drawunit.SolidRect>
---@param b table<number, Graphics.Drawunit.SolidRect>
---@return boolean
function _SolidRect.CollideWithList(a, b)
	if (a == nil or b == nil) then
		return false
	end

	for n=1, #a do
		for m=1, #b do
			local isdone, x, y, z = a[n]:Collide(b[m])

			if (isdone) then
				return true, x, y, z
			end
		end
	end

	return false
end

---@param x int
---@param y1 int
---@param y2 int
---@param z int
---@param w int
---@param h int
function _SolidRect:Ctor(x, y1, y2, z, w, h)
	self._x = 0
	self._y = 0
	self._z = 0
	self._sx = 1
	self._sy = 1
	self._r = 0

	self._struct = {
		x = 0,
		y1 = 0,
		y2 = 0,
		z = 0,
		w = 0,
		h = 0
	}

	self.rectGroup = {
		xy = _Rect.New(),
		xz = _Rect.New()
	}

	self:SetStruct(x, y1, y2, z, w, h)
end

---@param x int
---@param y int
---@param z int
---@param sx number
---@param sy number
---@param r number
function _SolidRect:Set(x, y, z, sx, sy, r)
	self._x = x or self._x
	self._y = y or self._y
	self._z = z or self._z
	self._sx = sx or self._sx
	self._sy = sy or self._sy
	self._r = r or self._r

	self:Adjust()
end

---@param name string @If it is null, that will return all values.
---@return number
function _SolidRect:Get(name)
	if (name) then
		return self["_" .. name]
	else
		return self._x, self._y, self._z, self._sx, self._sy, self._r
	end
end

---@param x int
---@param y1 int
---@param y2 int
---@param z int
---@param w int
---@param h int
function _SolidRect:SetStruct(x, y1, y2, z, w, h)
	self._struct.x = x
	self._struct.y1 = y1
	self._struct.y2 = y2
	self._struct.z = z
	self._struct.w = w
	self._struct.h = h

	self:Adjust()
end

---@param name string @If it is null, that will return all values.
---@return number
function _SolidRect:GetStruct(name)
	if (name) then
		return self._struct[name]
	else
		return self._struct.x, self._struct.y1, self._struct.y2, self._struct.z, self._struct.w, self._struct.h
	end
end

function _SolidRect:Adjust()
	local x = self._x + self._struct.x * self._sx
	local w = self._struct.w * math.abs(self._sx)

	local y1 = self._y + self._struct.y1 * self._sy
	local h1 = (self._struct.y2 - self._struct.y1) * math.abs(self._sy)

	local y2 = self._y + self._z + (-self._struct.z - self._struct.h) * math.abs(self._sy)
	local h2 = self._struct.h * math.abs(self._sy)

	if (self._sx < 0) then
		x = x - w
	end

	if (self._sy < 0) then
		y1 = y1 - h1
		y2 = y2 - h2
	end

	self.rectGroup.xy:Set(x, y1, w, h1, self._r, self._x, self._y)
	self.rectGroup.xz:Set(x, y2, w, h2, self._r, self._x, self._y)
end

---@return boolean
function _SolidRect:IsRaw()
	return self.rectGroup.xy:IsRaw() and self.rectGroup.xz:IsRaw()
end

---@param another Graphics.Drawunit.SolidRect
---@param onlyStruct boolean
---@return boolean
function _SolidRect:Compare(another, onlyStruct)
	local x, y1, y2, z, w, h = another:GetStruct()
	local structIsComparable = self._struct.x == x and self._struct.y1 == y1 and self._struct.y2 == y2 and self._struct.z == z and self._struct.w == w and self._struct.h == h

	if (onlyStruct) then
		return structIsComparable
	else
		local x, y, z, sx, sy, r = another:Get()

		return structIsComparable and x == self._x and y == self._y and z == self._z and sx == self._sx and sy == self._sy and r == self._r
	end
end

---@param solidRect Graphics.Drawunit.SolidRect
---@return boolean, int @isdone & x & y & z
function _SolidRect:Collide(solidRect)
	local xy = self.rectGroup.xy:CheckRect(solidRect.rectGroup.xy)
	local xz, x, z = self.rectGroup.xz:CheckRect(solidRect.rectGroup.xz)

	if (xy and xz) then
		return true, x, self._y, z - self._y
	end

	return false
end

function _SolidRect:CheckPoint(x, y, z)
    return self.rectGroup.xy:CheckPoint(x, y)
end

---@param color_xy Graphics.Drawunit.Color
---@param color_xz Graphics.Drawunit.Color
function _SolidRect:Draw(color_xy, color_xz)
	self.rectGroup.xy:Draw(color_xy)
	self.rectGroup.xz:Draw(color_xz)
end

return _SolidRect