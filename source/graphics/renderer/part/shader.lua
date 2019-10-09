--[[
	desc: a type of Attri and a part of Renderer.
	author: Musoucrow
	since: 2018-3-7
	alter: 2019-9-17
]]--

---@type Graphics.Renderer.Part
local _Base = require("graphics.renderer.part.base")

---@class Graphics.Renderer.Part.Shader:Graphics.Renderer.Part
local _Shader = require("core.class")(_Base)

---@param upperEvent event
function _Shader:Ctor(upperEvent)
	_Base.Ctor(self, upperEvent, upperEvent.GetUpperDrawunit("shader"), "setShader", "shader", true)
end

return _Shader