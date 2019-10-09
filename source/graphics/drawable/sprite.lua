--[[
	desc: Sprite, a Drawable of Image.
	author: Musoucrow
	since: 2018-4-26
	alter: 2019-9-17
]]--

local _Color = require("graphics.drawunit.color")
local _Base = require("graphics.drawable.base")
local _IRect = require("graphics.drawable.iRect")
local _IPath = require("graphics.drawable.iPath")

local _emptyTable = {}

---@class Graphics.Drawable.Sprite:Graphics.Drawable
---@field protected _data Lib.RESOURCE.SpriteData
---@field protected _drawableObj Image
local _Sprite = require("core.class")(_Base, _IRect, _IPath)

---@param upperEvent event
---@param data Lib.RESOURCE.SpriteData
---@param rectEnabled boolean @default=false
function _Sprite:Ctor(upperEvent, data, rectEnabled)
	_Base.Ctor(self, upperEvent)
	_IRect.Ctor(self, rectEnabled)
	_IPath.Ctor(self)

	if (data) then
		self:SetData(data)
	end
end

---@param data Lib.RESOURCE.SpriteData
---@param forced boolean @forced setting
---@return boolean
function _Sprite:SetData(data, forced)
	if (self._data == data and not forced) then
		return false
	end

	local rectEnabled = self._rectEnabled
	self._rectEnabled = false
	data = data or _emptyTable
    self._data = data

    local ox = data.ox or 0
    local oy = data.oy or 0
    local sx = data.sx or 1
    local sy = data.sy or 1
    local angle = data.angle or 0
    local color = data.color or _Color.white
    local blendmode = data.blendmode or "alpha"

    self:SetImage(data.image, data.path)
    self:SetQuad(data.quad)
    self:SetAttri("origin", ox, oy)
    self:SetAttri("scale", sx, sy)
    self:SetAttri("radian", angle, true)
    self:SetAttri("color", color:Get())
    self:SetAttri("blendmode", blendmode)
	
	if (data.shader) then
		self:SetAttri("shader", data.shader)
	end

	self._rectEnabled = rectEnabled
	self:AdjustDimensions()

	return true
end

---@param image Image
---@param path string
function _Sprite:SetImage(image, path)
	self._drawableObj = image
	self._path = path or ""
end

---@param quad Quad
function _Sprite:SetQuad(quad)
	_Base.SetQuad(self, quad)
    self:AdjustDimensions()
end

---@param notAdjustRect boolean @can null
function _Sprite:AdjustDimensions(notAdjustRect)	
	local _, _, w, h = self:GetQuadValues()
	local iw, ih = self:GetImageDimensions()

	self._width = w or iw
	self._height = h or ih
	
	if (not notAdjustRect) then
		self:AdjustRect()
	end
end

---@return int @w & h
function _Sprite:GetImageDimensions()
	if (self._drawableObj) then
		return self._drawableObj:getDimensions()
	else
		return 0, 0
	end
end

function _Sprite:_OnDraw()
	self._renderer:DrawObj(self._drawableObj)
end

return _Sprite