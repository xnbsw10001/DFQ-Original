--[[
	desc: a type of Attri and a part of Renderer.
	author: Musoucrow
	since: 2018-3-9
	alter: 2019-9-17
]]--

---@type Graphics.Renderer.Part
local _Base = require("graphics.renderer.part.base")--base class

---@class Graphics.Renderer.Part.Radian:Graphics.Renderer.Part
local _Radian = require("core.class")(_Base)

---@param upperEvent event
function _Radian:Ctor(upperEvent)
	_Base.Ctor(self, upperEvent, upperEvent.GetUpperDrawunit("radian"), "setRadian", "radian")
end

function _Radian:_OnSet()
	if (self._drawunitGroup.synthetic) then
		self._drawunitGroup.synthetic:Set(self._drawunitGroup.base:Get() + self._drawunitGroup.upper:Get())
	end
end

return _Radian