--[[
	desc: Renderer, be responsible for drawing.
	author: Musoucrow
	since: 2018-3-7
	alter: 2019-9-17
]]--

local _GRAPHICS = require("lib.graphics")

local _Caller = require("core.caller")
local _Blendmode = require("graphics.renderer.part.blendmode")
local _Color = require("graphics.renderer.part.color")
local _Point = require("graphics.renderer.part.point")
local _Radian = require("graphics.renderer.part.radian")
local _Scale = require("graphics.renderer.part.scale")
local _Shader = require("graphics.renderer.part.shader")

local function _SetPosition(self)
	self._valueGroup.px, self._valueGroup.py = self._partGroup.position:Get(false)
end

local function _SetRadian(self)
	self._valueGroup.rd = self._partGroup.radian:Get(false)
end

local function _SetScale(self)
	self._valueGroup.sx, self._valueGroup.sy = self._partGroup.scale:Get(false)
end

local function _SetOrigin(self)
	self._valueGroup.ox, self._valueGroup.oy = self._partGroup.origin:Get(false)
end

local function _SetShear(self)
	self._valueGroup.kx, self._valueGroup.ky = self._partGroup.shear:Get(false)
end

---@class Graphics.Renderer
---@field protected _upperEvent event
---@field protected _event event
---@field protected _callerMap table<string, Core.Caller>
---@field protected _upperDrawunitGroup table<string, Graphics.Drawunit>
---@field protected _partGroup Graphics.Renderer.PartGroup
---@field protected _valueGroup map
---@field public quad Quad
local _Renderer = require("core.class")()

---@param upperEvent event @can null
---@param eventName_impartFromUpper string @can null
---@param eventName_addListenerToUpper string @can null
function _Renderer:Ctor(upperEvent, eventName_impartFromUpper, eventName_addListenerToUpper)
	self._upperEvent = upperEvent
	self._event = {
		AddListenerToUpper = self._upperEvent[eventName_addListenerToUpper],
		Call = function(type, ...)
			return self._callerMap[type]:Call(...)
		end,
		GetUpperDrawunit = function(...)
			return self._upperDrawunitGroup[...]
		end
	}

	self._callerMap = {
		setPosition = _Caller.New(),
		setRadian = _Caller.New(),
		setScale = _Caller.New(),
		setOrigin = _Caller.New(),
		setShear = _Caller.New(),
		setBlendmode = _Caller.New(),
		setColor = _Caller.New(),
		setShader = _Caller.New()
	}

	self._upperDrawunitGroup = {}
	
	if (eventName_impartFromUpper) then
		self._upperEvent[eventName_impartFromUpper](self) --Set upper drawunit in self._upperDrawunitGroup
	end

	---@type table<string, Graphics.Renderer.Part>
	self._partGroup = {
		position = _Point.New(self._event, true, "setPosition", "position"),
		radian = _Radian.New(self._event),
		scale = _Scale.New(self._event),
		origin = _Point.New(self._event, true, "setOrigin", "origin"),
		shear = _Point.New(self._event, false, "setShear", "shear"),
		color = _Color.New(self._event),
		blendmode = _Blendmode.New(self._event),
		shader = _Shader.New(self._event)
	}
	
	self._partGroup.origin:SwitchLock(true)
	
	self._valueGroup = {
		px = 0,
		py = 0,
		rd = 0,
		sx = 1,
		sy = 1,
		ox = 0,
		oy = 0,
		kx = 0,
		ky = 0
	}

	self:AddListener("setPosition", self, _SetPosition)
	self:AddListener("setRadian", self, _SetRadian)
	self:AddListener("setScale", self, _SetScale)
	self:AddListener("setOrigin", self, _SetOrigin)
	self:AddListener("setShear", self, _SetShear)
	
	for k, v in pairs(self._partGroup) do
		if (v.Set) then
			v:Set()
		end
	end
end

function _Renderer:Apply()
	self._partGroup.color:Apply()
	self._partGroup.blendmode:Apply()
	self._partGroup.shader:Apply()
end

function _Renderer:Reset()
	self._partGroup.color:Reset()
	self._partGroup.blendmode:Reset()
	self._partGroup.shader:Reset()
end

---@param type string @color, blendmode, shader
---@param isBan boolean
function _Renderer:SetBan(type, isBan)
	self._partGroup[type]:SetBan(isBan)
end

---@param obj Drawable
function _Renderer:DrawObj(obj)
	if (not obj) then
		return
	end
	
	local valueGroup = self._valueGroup
	
	if (self.quad) then
		_GRAPHICS.DrawObj(obj, self.quad, valueGroup.px, valueGroup.py, valueGroup.rd, valueGroup.sx, valueGroup.sy, valueGroup.ox, valueGroup.oy, valueGroup.kx, valueGroup.ky)
	else
		_GRAPHICS.DrawObj(obj, valueGroup.px, valueGroup.py, valueGroup.rd, valueGroup.sx, valueGroup.sy, valueGroup.ox, valueGroup.oy, valueGroup.kx, valueGroup.ky)
	end
end

---@param obj Drawable
---@param quad Quad
---@param px int
---@param py int
---@param rd number
---@param sx number
---@param sy number
---@param ox int
---@param oy int
---@param kx number
---@param kx number
function _Renderer:DrawObj_Custom(obj, quad, px, py, rd, sx, sy, ox, oy, kx, ky)
	if (not obj) then
		return
	end
	
	local valueGroup = self._valueGroup
	px = px or valueGroup.px
	py = py or valueGroup.py
	quad = quad or self.quad
	rd = rd or valueGroup.rd
	sx = sx or valueGroup.sx
	sy = sy or valueGroup.sy
	ox = ox or valueGroup.ox
	oy = oy or valueGroup.oy
	kx = kx or valueGroup.kx
	ky = ky or valueGroup.ky
	
	if (quad) then
		_GRAPHICS.DrawObj(obj, quad, px, py, rd, sx, sy, ox, oy, kx, ky)
	else
		_GRAPHICS.DrawObj(obj, px, py, rd, sx, sy, ox, oy, kx, ky)
	end
end

function _Renderer:DrawPosition()
	self._partGroup.position:Draw()
end

---@param type string
---@param isSelf boolean
---@param name string
function _Renderer:GetAttri(type, isSelf, name)
	return self._partGroup[type]:Get(isSelf, name)
end

---@param type string
function _Renderer:SetAttri(type, ...)
	self._partGroup[type]:Set(...)
end

---@param type string
---@param unlock boolean
function _Renderer:SwitchAttriLock(type, unlock)
	self._partGroup[type]:SwitchLock(unlock)
end

---@param type string
---@param obj table
---@param Func function
function _Renderer:AddListener(type, obj, Func)
	self._callerMap[type]:AddListener(obj, Func)
end

---@param type string
---@param obj table
---@param Func function
function _Renderer:DelListener(type, obj, Func)
	self._callerMap[type]:DelListener(obj, Func)
end

---@param renderer Graphics.Renderer
function _Renderer:Impart(renderer)
	for k, v in pairs(self._partGroup) do
		renderer:SetUpperDrawunit(k, v:GetDrawunit_Reality())
	end
end

---@param type string
---@param drawunit Graphics.Drawunit
function _Renderer:SetUpperDrawunit(type, drawunit)
	self._upperDrawunitGroup[type] = drawunit
end

return _Renderer