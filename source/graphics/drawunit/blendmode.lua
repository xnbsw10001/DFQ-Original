--[[
	desc: Blendmode, one of Drawunit.
	author: Musoucrow
	since: 2018-3-13
	alter: 2018-5-21
]]--

local _GRAPHICS = require("lib.graphics") ---@type Lib.GRAPHICS

---@class Graphics.Drawunit.Blendmode
---@field public value string
local _Blendmode = require("core.class")()

---@param value string
function _Blendmode:Ctor(value)
	self:Set(value) --Init value
end

---@param value string
function _Blendmode:Set(value)
	self.value = value or self.value or "alpha"
end

function _Blendmode:Get()
	return self.value
end

---@return boolean
function _Blendmode:IsRaw()
	return self.value == "alpha"
end

---@param another Graphics.Drawunit.Blendmode
---@return boolean
function _Blendmode:Compare(another)
	return self.value == another:Get()
end

function _Blendmode:Apply()
	_GRAPHICS.SetBlendmode(self.value)
end

return _Blendmode