--[[
	desc: Factory, a function that is responsible for producing Drawunit.
	author: Musoucrow
	since: 2018-3-21
	alter: 2018-10-30
]]--

local _Point = require("graphics.drawunit.point")
local _Point3 = require("graphics.drawunit.point3")
local _Radian = require("graphics.drawunit.radian")
local _Rect = require("graphics.drawunit.rect")
local _Blendmode = require("graphics.drawunit.blendmode")
local _Color = require("graphics.drawunit.color")
local _Shader = require("graphics.drawunit.shader")
local _SolidRect = require("graphics.drawunit.solidRect")

local _event = {
	point = function(...)
		return _Point.New(...)
	end,
	point3 = function(...)
		return _Point3.New(...)
	end,
	radian = function(...)
		return _Radian.New(...)
	end,
	rect = function(...)
		return _Rect.New(...)
	end,
	blendmode = function(...)
		return _Blendmode.New(...)
	end,
	color = function(...)
		return _Color.New(...)
	end,
	shader = function(...)
		return _Shader.New(...)
	end,
	solidRect = function(...)
		return _SolidRect.New(...)
	end
}

return function(type, ...)
	return _event[type](...)
end