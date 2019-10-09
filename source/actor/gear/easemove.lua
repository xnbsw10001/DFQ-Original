--[[
	desc: Easemove, a gear for ease moving business.
	author: Musoucrow
	since: 2018-8-22
	alter: 2019-5-24
]]--

local _MOTION = require("actor.service.motion")

local _ValueMotion = require("util.gear.valueMotion")
local _Gear = require("core.gear")

---@class Actor.Gear.Easemove:Core.Gear
---@field protected _valueMotion Util.Gear.ValueMotion
---@field public transform Actor.Component.Transform
---@field public aspect Actor.Component.Aspect
---@field public type string
---@field public direction direction
local _Easemove = require("core.class")(_Gear)

---@param transform Actor.Component.Transform
---@param aspect Actor.Component.Aspect
function _Easemove:Ctor(transform, aspect)
    _Gear.Ctor(self)

    self.transform = transform
    self.aspect = aspect
    self._valueMotion = _ValueMotion.New()
end

function _Easemove:Update(rate)
    if (not self.isRunning) then
        return
    end

    self._valueMotion:Update(rate)

    if (self._valueMotion.isRunning) then
        _MOTION.Move(self.transform, self.aspect, self.type, self._valueMotion.value * self.direction * rate)
    else
        self:Exit()
    end
end

---@param type string
---@param power number
---@param speed number
---@param direction direction
function _Easemove:Enter(type, power, speed, direction)
    _Gear.Enter(self)

    self._valueMotion:Enter(power, 0, speed)
    self.type = type
    self.direction = direction or 1
end

---@return number
function _Easemove:GetPower()
    return self._valueMotion.value
end

function _Easemove:GetSpeed()
    return self._valueMotion.speed
end

---@param value number
function _Easemove:SetPower(value)
    self._valueMotion.value = value
end

return _Easemove