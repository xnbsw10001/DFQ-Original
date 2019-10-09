--[[
	desc: a type of Attri and a part of Renderer.
	author: Musoucrow
	since: 2018-3-9
	alter: 2019-9-17
]]--

local _MATH = require("lib.math") ---@type Lib.MATH

local _Base = require("graphics.renderer.part.base") ---@type Graphics.Renderer.Part

---@class Graphics.Renderer.Part.Scale:Graphics.Renderer.Part
local _Scale = require("core.class")(_Base)

---@param upperEvent event
function _Scale:Ctor(upperEvent)
	_Base.Ctor(self, upperEvent, upperEvent.GetUpperDrawunit("scale"), "setScale", "point", false, false, 1, 1)
end

function _Scale:_OnSet()
	local sx, sy = self._drawunitGroup.base:Get()
	self._drawunitGroup.base:Set(sx, sy)

	if (self._drawunitGroup.synthetic) then
		local ux, uy = self._drawunitGroup.upper:Get()
		local bx, by = self._drawunitGroup.base:Get()

		self._drawunitGroup.synthetic:Set (bx * ux, by * uy)
	end
end

return _Scale