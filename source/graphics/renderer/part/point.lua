--[[
	desc: a type of Attri and a part of Renderer.
	author: Musoucrow
	since: 2018-3-7
	alter: 2019-9-17
]]--

local _Color = require("graphics.drawunit.color")

---@type Graphics.Renderer.Part
local _Base = require("graphics.renderer.part.base")

---@class Graphics.Renderer.Part.Point:Graphics.Renderer.Part
local _Point = require("core.class")(_Base)

---@param upperEvent event
---@param isInt boolean
---@param listenerName string
---@param type string
function _Point:Ctor(upperEvent, isInt, listenerName, type)
	_Base.Ctor(self, upperEvent, upperEvent.GetUpperDrawunit(type), listenerName, "point", false, isInt)
end

function _Point:_OnSet()
	if (self._drawunitGroup.synthetic) then
		local ux, uy = self._drawunitGroup.upper:Get()
		local bx, by = self._drawunitGroup.base:Get()
		
		self._drawunitGroup.synthetic:Set(bx + ux, by + uy)
	end
end

function _Point:Draw()
	self._drawunitGroup.reality:Draw(4, _Color.white)
end

return _Point