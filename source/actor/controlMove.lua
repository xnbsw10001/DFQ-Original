--[[
	desc: ControlMove, a util for control move business.
	author: Musoucrow
	since: 2018-7-28
]]--

local _TIME = require("lib.time")
local _CONFIG = require("config")
local _INPUT = require("actor.service.input")
local _MOTION = require("actor.service.motion")

local _Point = require("graphics.drawunit.point")

---@class Actor.ControlMove
---@field public aspect Actor.Component.Aspect
---@field public transform Actor.Component.Transform
---@field public input Actor.Component.Input
---@field public speed Graphics.Drawunit.Point
---@field public turnDirection boolean
---@field public OnReleased function
---@field protected _keyPressedFrame table<string, int>
---@field protected _axis Graphics.Drawunit.Point
local _ControlMove = require("core.class")()

---@param aspect Actor.Component.Aspect
---@param transform Actor.Component.Transform
---@param input Actor.Component.Input
---@param speed Graphics.Drawunit.Point
---@param turnDirection boolean
---@param OnReleased function
function _ControlMove:Ctor(aspect, transform, input, speed, turnDirection, OnReleased)
    self.aspect = aspect
    self.transform = transform
    self.input = input
    self.speed = speed
    self.turnDirection = turnDirection
    self.OnReleased = OnReleased
    self._keyPressedFrame = {up = 0, down = 0, left = 0, right = 0}
    self._axis = _Point.New(true)
end

function _ControlMove:Update()
    local up = _INPUT.IsHold(self.input, "up")
    local down = _INPUT.IsHold(self.input, "down")
    local right = _INPUT.IsHold(self.input, "right")
    local left = _INPUT.IsHold(self.input, "left")
    local axisX, axisY = 0, 0

    if (up or down) then
        if (up and down) then
            if (self._keyPressedFrame.up > self._keyPressedFrame.down) then
                axisY = -1
            else
                axisY = 1
            end
        elseif (up) then
            axisY = -1
        else
            axisY = 1
        end
    else
        axisY = 0
    end

    if (left or right) then
        if (left and right) then
            if (self._keyPressedFrame.left > self._keyPressedFrame.right) then
                axisX = -1
            else
                axisX = 1
            end
        elseif (left) then
            axisX = -1
        else
            axisX = 1
        end
    else
        axisX = 0
    end

    if (self.turnDirection and not _INPUT.IsHold(self.input, "lockOn") and axisX ~= 0 and self.transform.direction ~= axisX) then
        self.transform.direction = axisX
        self.transform.scaleTick = true
    end

    if (axisX ~= 0) then
        _MOTION.Move(self.transform, self.aspect, "x", self.speed.x * axisX)
    end

    if (axisY ~= 0) then
        _MOTION.Move(self.transform, self.aspect, "y", self.speed.y * axisY)
    end

    for n=1, #_CONFIG.arrow do
        if (_INPUT.IsPressed(self.input, _CONFIG.arrow[n])) then
            self._keyPressedFrame[_CONFIG.arrow[n]] = _TIME.GetFrame()
            break
        end
    end

    if (self.OnReleased and (self._axis.x ~= 0 or self._axis.y ~= 0) and not up and not down and not right and not left) then
        self.OnReleased()
    end

    self._axis:Set(axisX, axisY)
end

return _ControlMove