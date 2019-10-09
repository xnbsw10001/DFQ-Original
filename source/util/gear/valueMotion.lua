--[[
	desc: ValueMotion, a gear of moving a value.
	author: Musoucrow
	since: 2018-7-4
	alter: 2019-4-19
]]--

local _MATH = require("lib.math")

local _Gear = require("core.gear")

---@class Util.Gear.ValueMotion:Core.Gear
---@field public from number
---@field public to number
---@field public value number
---@field public direction direction
---@field public isRound boolean
---@field public speed number
local valueMotion = require("core.class")(_Gear)

function valueMotion:Ctor()
    _Gear.Ctor(self)

    self.from = 0
    self.to = 0
    self.value = 0
    self.speed = 0
    self.direction = 1
    self.isRound = false
end

---@param rate number
function valueMotion:Update(rate)
    if (not self.isRunning) then
        return
    end

    self.value = self.value + _MATH.GetFixedDecimal(self.speed * self.direction * rate)

    if (self.speed > 0 and ((self.direction == 1 and self.value >= self.to) or (self.direction == -1 and self.value <= self.to))) then
        self.value = self.to

        if (self.isRound) then
            self:Enter(self.to, self.from, self.speed, self.isRound)
        else
            self:Exit()
        end
    end
end

---@param from number
---@param to number
---@param speed number
---@param isRound boolean
function valueMotion:Enter(from, to, speed, isRound)
    _Gear.Enter(self)

    self.from = from
    self.to = to
    self.value = self.from
    self.speed = speed
    self.isRound = isRound
    self.direction = self.from < self.to and 1 or -1
end

return valueMotion