--[[
	desc: a type of Attri and a part of Renderer.
	author: Musoucrow
	since: 2018-3-7
	alter: 2019-9-17
]]--

---@type Graphics.Renderer.Part
local _Base = require("graphics.renderer.part.base")

---@class Graphics.Renderer.Part.Color:Graphics.Renderer.Part
local _Color = require("core.class")(_Base)

---@param upperEvent event
function _Color:Ctor(upperEvent)
	_Base.Ctor(self, upperEvent, upperEvent.GetUpperDrawunit("color"), "setColor", "color")
end

function _Color:_OnSet()
	if (self._drawunitGroup.synthetic) then
		local ured, ugreen, ublue, ualpha = self._drawunitGroup.upper:Get()
		local bred, bgreen, bblue, balpha = self._drawunitGroup.base:Get()
		
		self._drawunitGroup.synthetic:Set (bred * ured / 255, bgreen * ugreen / 255, bblue * ublue / 255, balpha * ualpha / 255)
	end
end

return _Color