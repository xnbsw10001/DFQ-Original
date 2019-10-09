--[[
	desc: Stun, a state of Duelist.
	author: Musoucrow
	since: 2018-8-21
	alter: 2019-5-26
]]--

local _MATH = require("lib.math")
local _ASPECT = require("actor.service.aspect")
local _STATE = require("actor.service.state")
local _EFFECT = require("actor.service.effect")

local _Timer = require("util.gear.timer")
local _Easemove = require("actor.gear.easemove")
local _Base = require("actor.state.base")

---@class Actor.State.Duelist.Stun:Actor.State
---@field protected _index int
---@field protected _length int
---@field protected _timer Util.Gear.Timer
---@field protected _subTimer Util.Gear.Timer
---@field protected _easemove Actor.Gear.Easemove
---@field protected _flagMap table<string, boolean>
---@field protected _Func function
local _Stun = require("core.class")(_Base)

function _Stun:Init(entity)
    _Base.Init(self, entity)

    self._timer = _Timer.New()
    self._subTimer = _Timer.New()
    self._easemove = _Easemove.New(self._entity.transform, self._entity.aspect)
end

function _Stun:NormalUpdate(dt, rate)
    if (self._flagMap.hold) then
        return
    end

    self._easemove:Update(rate)
    self._timer:Update(dt)

    if (not self._timer.isRunning) then
        _STATE.Play(self._entity.states, self._nextState)
    elseif (self._flagMap.animation) then
        self._subTimer:Update(dt)

        if (not self._subTimer.isRunning) then
            self._index = self._index - 1
            self:PlayAnimation(self._index)
            self._subTimer:Enter()
        end
    end

    self:_Func("update")
end

---@param lateState Actor.State
---@param time number
---@param power number
---@param speed number
---@param direction direction
---@param flagMap table<string, boolean>
---@param Func function
function _Stun:Enter(lateState, time, power, speed, direction, flagMap, Func)
    _Base.Enter(self)

    time = time * self._entity.attributes.stunRate

    self._easemove:Enter("x", _MATH.GetFixedDecimal(power), _MATH.GetFixedDecimal(speed), direction)
    self._timer:Enter(time)
    self._flagMap = flagMap
    self._Func = Func
    self._length = #self._frameaniDataSets

    if (self._flagMap.animation) then
        self._index = self._length
        self._subTimer:Enter(math.floor(time / self._length))
    elseif (self._flagMap.pingpong and self == lateState) then
        self._index = self._index + 1

        if (self._index > self._length) then
            self._index = 1
        end
    else
        self._index = math.random(1, self._length)
    end

    if (self._flagMap.figure) then
        _EFFECT.NewFigure(self._entity.transform, self._entity.aspect, _ASPECT.GetPart(self._entity.aspect):GetData())
    end

    self:PlayAnimation(self._index)
    self:_Func("enter")
end

---@param nextState Actor.State
function _Stun:Exit(nextState)
    _Base.Exit(self)

    if (self._flagMap.only and self == nextState) then
        return false
    end

    self:_Func("exit")
end

---@param index int
function _Stun:PlayAnimation(index)
    _ASPECT.Play(self._entity.aspect, self._frameaniDataSets[index])
end

return _Stun