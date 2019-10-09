--[[
	desc: Rect, one of Drawunit.
	author: Musoucrow
	since: 2018-3-13
	alter: 2018-7-17
]]--

local _MATH = require("lib.math") ---@type Lib.MATH
local _GRAPHICS = require("lib.graphics") ---@type Lib.GRAPHICS

local _gettingList = {
	x = "_x",
	y = "_y",
	w = "_w",
	h = "_h",
	r = "_r",
	cx = "_cx",
	cy = "_cy",
	xw = "_xw",
	yh = "_yh"
}

---@param x number
---@param y number
---@return number @x & y
local function _RotatePoint (self, x, y)
	return _MATH.RotatePoint(x, y, self._cx, self._cy, self._r)
end

---@class Graphics.Drawunit.Rect
---@field protected _x int
---@field protected _y int
---@field protected _w int
---@field protected _h int
---@field protected _r number
---@field protected _cx int
---@field protected _cy int
---@field protected _pointList list
local _Rect = require("core.class")()

---@param x int
---@param y int
---@param w int
---@param h int
---@param r number
---@param cx int
---@param cy int
function _Rect:Ctor(x, y, w, h, r, cx, cy)
	self._x = x or 0
	self._y = y or 0
	self._w = w or 0
	self._h = h or 0
	self._r = r or 0
	self._cx = cx
	self._cy = cy
	
	self._pointList = {}
	self:Adjust() --Init xw, yh, cx, cy and pointList.
end

---@param x int
---@param y int
---@param w int
---@param h int
---@param r number
---@param cx int
---@param cy int
function _Rect:Set(x, y, w, h, r, cx, cy)
	x = x or self._x
	y = y or self._y
	w = w or self._w
	h = h or self._h
	r = r or self._r
	
	if (x ~= self._x or y ~= self._y or self._w ~= w or self._h ~= h or self._r ~= r or cx or cy) then
		self._x = x
		self._y = y
		self._w = w
		self._h = h
		self._r = r
		self._cx = cx
		self._cy = cy
		
		self:Adjust()
	end	
end

---@param rect Graphics.Drawunit.Rect
function _Rect:SetByRect(rect)
	self:Set(rect:Get())
end

---@param name string @If it is null, that will return all values.
---@return number
function _Rect:Get(name)
	if (name) then
		return self[_gettingList[name]]
	else
		return self._x, self._y, self._w, self._h, self._r, self._cx, self._cy, self._xw, self._yh
	end
end

function _Rect:Adjust()
	self._xw = self._x + self._w
	self._yh = self._y + self._h
	self._cx = self._cx or self._x + self._w * 0.5
	self._cy = self._cy or self._y + self._h * 0.5
	
	if (self._r == 0) then
		self._pointList[1] = self._x
		self._pointList[2] = self._y
		self._pointList[3] = self._x
		self._pointList[4] = self._yh
		self._pointList[5] = self._xw
		self._pointList[6] = self._yh
		self._pointList[7] = self._xw
		self._pointList[8] = self._y
	else
		self._pointList[1], self._pointList[2] = _RotatePoint(self, self._x, self._y)
		self._pointList[3], self._pointList[4] = _RotatePoint(self, self._x, self._yh)
		self._pointList[5], self._pointList[6] = _RotatePoint(self, self._xw, self._yh)
		self._pointList[7], self._pointList[8] = _RotatePoint(self, self._xw, self._y)
	end
end

---@param point Graphics.Drawunit.Point
---@return boolean
function _Rect:CheckPointByPoint(point)
	return self:CheckPoint(point:Get())
end

---@param x int
---@param y int
function _Rect:CheckPoint(x, y)
	local nx, ny
	
	if (self._r ~= 0) then
		self._r = -self._r
		nx, ny = _RotatePoint(self, x, y)
		self._r = -self._r
	else
		nx, ny = x, y
	end
	
	if (nx < self._x or nx > self._xw or ny < self._y or ny > self._yh) then
		return false
	end
	
	return true
end

---@param rect Graphics.Drawunit.Rect
---@return boolean
function _Rect:CheckRect(rect)
	local lx = math.max(self._x, rect:Get("x"))
	local ly = math.max(self._y, rect:Get("y"))
	local rx = math.min(self._xw, rect:Get("xw"))
	local ry = math.min(self._yh, rect:Get("yh"))

	if (lx > rx or ly > ry) then
		return false
	end
	
	return true, lx + (rx - lx) * 0.5 ,ly + (ry - ly) * 0.5
end

---@return boolean
function _Rect:IsRaw()
	return self._x == 0 and self._y == 0 and self._w == 0 and self._h == 0
end

---@param another Graphics.Drawunit.Rect
---@return boolean
function _Rect:Compare(another)
	local x, y, w, h, r = another:Get()
	
	return self._x == x and self._y == y and self._w == w and self._h == h and self._r == r
end

---@param color Graphics.Drawunit.Color
---@param mode string @null, cross
function _Rect:Draw(color, mode)
	if (color) then
		color:Apply ()
	end
	
	_GRAPHICS.DrawPolygon("line", self._pointList)
	
	if (mode == "cross") then
		_GRAPHICS.DrawLine(self._pointList[1], self._pointList[2], self._pointList[5], self._pointList[6])
		_GRAPHICS.DrawLine(self._pointList[7], self._pointList[8], self._pointList[3], self._pointList[4])
	end
	
	if (color) then
		_GRAPHICS.ResetColor()
	end
end

return _Rect