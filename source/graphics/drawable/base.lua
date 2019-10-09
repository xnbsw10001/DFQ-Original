--[[
	desc: Drawable, a Renderer's practice. Be used for drawing some resource.
	author: Musoucrow
	since: 2018-4-26
	alter: 2019-9-17
]]--

local _Renderer = require("graphics.renderer.init")

---@class Graphics.Drawable
---@field protected _upperEvent event
---@field protected _event event
---@field protected _renderer Graphics.Renderer
---@field protected _drawableObj Drawable
local _Base = require("core.class")()

---@param upperEvent event
function _Base:Ctor(upperEvent)
	self._upperEvent = upperEvent
	self._event = {
		AddListener = function(...)
			self._renderer:AddListener(...)
		end,
		Impart = function(...)
			self._renderer:Impart(...)
		end
	}
	
	if (self._upperEvent and self._upperEvent.AddListener and self._upperEvent.Impart) then
		self._event.AddListenerToUpper = self._upperEvent.AddListener
		self._event.ImpartFromUpper = self._upperEvent.Impart
		
		self._renderer = _Renderer.New(self._event, "ImpartFromUpper", "AddListenerToUpper")
	else
		self._renderer = _Renderer.New(self._event)
	end
end

---@param type string
function _Base:SetAttri(type, ...)
	self._renderer:SetAttri(type, ...)
end

---@param type string
---@param isSelf boolean
---@param name string
function _Base:GetAttri(type, isSelf, name)
	return self._renderer:GetAttri(type, isSelf, name)
end

---@param quad Quad
function _Base:SetQuad(quad)
    self._renderer.quad = quad
end

---@return number
function _Base:GetQuadValues()
    local quad = self._renderer.quad

    if (not quad) then
        return
    end

    local x, y, w, h = quad:getViewport()
    local sw, sh = quad:getTextureDimensions()

    return x, y, w, h, sw, sh
end

---@param type string @color, blendmode, shader
---@param isBan boolean
function _Base:SetBan(type, isBan)
	self._renderer:SetBan(type, isBan)
end

---@param type string
---@param unlock boolean
function _Base:SwitchAttriLock(type, unlock)
	self._renderer:SwitchAttriLock(type, unlock)
end

---@return Graphics.Drawable
function _Base:GetUpper()
	return self._upperEvent.GetUpper()
end

function _Base:GetData()
	return self._data
end

function _Base:Draw()
	self._renderer:Apply()
	self:_OnDraw()
	self._renderer:Reset()
end

function _Base:Update()
end

function _Base:_OnDraw()
end

return _Base