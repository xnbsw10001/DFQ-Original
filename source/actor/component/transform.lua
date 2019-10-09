--[[
	desc: Transform, a component with position, direction, scale and radian.
	author: Musoucrow
	since: 2018-3-20
	alter: 2019-3-28
]]--

local _Point = require("graphics.drawunit.point")
local _Point3 = require("graphics.drawunit.point3")
local _Radian = require("graphics.drawunit.radian")
local _Caller = require("core.caller")

---@class Actor.Component.Transform
---@field public position Graphics.Drawunit.Point3
---@field public shake Graphics.Drawunit.Point
---@field public shift Graphics.Drawunit.Point
---@field public direction int
---@field public scale Graphics.Drawunit.Point
---@field public radian Graphics.Drawunit.Radian
---@field public positionTick boolean
---@field public scaleTick boolean
---@field public radianTick boolean
---@field public obstructCaller Core.Caller
local _Transform = require("core.class")()

function _Transform:Ctor(data, param)
    self.position = _Point3.New(false, param.x, param.y, param.z)
    self.shake = _Point.New(true)
    self.shift = _Point.New()
    self.direction = param.direction or 1
    self.scale = _Point.New(false, 1, 1)
    self.radian = _Radian.New()
    self.positionTick = true
    self.scaleTick = true
    self.radianTick = true
    self.obstructCaller = _Caller.New()

    if (data) then
        if (data.scale) then
            self.scale:Set(data.scale.x, data.scale.y)
        end

        if (data.angle) then
            self.radian:Set(data.angle * self.direction, true)
        end
    end
end

return _Transform