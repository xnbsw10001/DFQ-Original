--[[
	desc: The Base of Actor's Drawable.
	author: Musoucrow
	since: 2018-6-27
	alter: 2018-8-8
]]--

local _GRAPHICS = require("lib.graphics")

local _Point = require("graphics.drawunit.point")

---@class Actor.Drawable
---@field protected _upperEvent event
---@field protected _shake Graphics.Drawunit.Point
---@field protected _type string
---@field protected _collider Actor.Collider
---@field protected _id int
---@field public hasShadow boolean
---@field public layer int
local _Base = require("core.class")()

local _idCount = 0

---@param upperEvent event
---@param hasShadow boolean @default=false
---@param type string
---@param layer int @default=0
function _Base:Ctor(upperEvent, hasShadow, type, order)
	hasShadow = hasShadow or false

	self._upperEvent = upperEvent
	self._type = type
	self._shake = _Point.New(true)
	self.hasShadow = hasShadow
	self.order = order or 0

    _idCount = _idCount + 1
	self._id = _idCount
end

function _Base:DrawShadow()
	if (not self.hasShadow) then
		return
	end

	local px, py = self._renderer:GetAttri("position")
	local sx, sy = self._renderer:GetAttri("scale")
	local kx = self._renderer:GetAttri("shear")
	local alpha = self._renderer:GetAttri("color", false, "alpha")

	py = py - self._upperEvent.GetZ() * 0.5
	kx = kx + sx * 0.5
	sx = sx * 0.8
	sy = sy * 0.5

	_GRAPHICS.SetColor(0, 0, 0, alpha * 0.4)

	self._renderer:DrawObj_Custom(self._drawableObj, _, px, py, _, sx, sy, _, _, kx)
end

---@param scale number
---@param pixel int
function _Base:DrawStroke(scale, pixel)
	local px, py = self._renderer:GetAttri("position")
	local sx, sy = self._renderer:GetAttri("scale")
	sx = sx * scale
	sy = sy * scale

    _GRAPHICS.SetBlendmode("add")

	self._renderer:DrawObj_Custom(self._drawableObj, _, px - pixel, py, _, sx , sy)
	self._renderer:DrawObj_Custom(self._drawableObj, _, px + pixel, py, _, sx, sy)
	self._renderer:DrawObj_Custom(self._drawableObj, _, px, py - pixel, _, sx, sy)
	self._renderer:DrawObj_Custom(self._drawableObj, _, px, py + pixel, _, sx, sy)

    _GRAPHICS.ResetBlendmode()
end

function _Base:DrawPurely()
	self._renderer:DrawObj(self._drawableObj)
end

function _Base:DrawCollider()
	if (not self._collider) then
		return
	end

	self._collider:Draw()
end

function _Base:GetType()
	return self._type
end

function _Base:GetID()
	return self._id
end

---@return Actor.Collider
function _Base:GetCollider()
	return self._collider
end

---@param collider Actor.Collider
function _Base:SetCollider(collider)
	self._collider = collider
	self:AdjustCollider()
end

function _Base:AdjustCollider()
	if (not self._collider) then
		return
	end

	local px, py = self._renderer:GetAttri("position")
	local pz = self._upperEvent.GetZ()
	local sx, sy = self._renderer:GetAttri("scale")

	py = py - pz

	self._collider:Set(px, py, pz, sx, sy, 0)
end

return _Base