--[[
	desc: Overturn, a state of Duelist.
	author: Musoucrow
	since: 2018-10-30
	alter: 2018-5-28
]]--

local _MOTION = require("actor.service.motion")
local _STATE = require("actor.service.state")
local _BATTLE = require("actor.service.battle")
local _ASPECT = require("actor.service.aspect")

local _Timer = require("util.gear.timer")
local _IBeaten = require("actor.state.duelist.ibeaten")
local _Base = require("actor.state.base")

local _processEnum = {run = 1, delay = 2}
local _defaultFlightParam = {
    power_z = 4,
    power_x = 0.5
}

---@class Actor.State.Duelist.Overturn:Actor.State
---@field protected _moveTweener Util.Gear.MockTweener
---@field protected _timer Util.Gear.Timer
---@field protected _process int
---@field protected _flightParam table
---@field protected _flagMap table<string, boolean>
---@field protected _Func function
local _Overturn = require("core.class")(_Base, _IBeaten)

function _Overturn:Ctor(...)
    _Base.Ctor(self, ...)
end

function _Overturn:Init(entity)
    _Base.Init(self, entity)

    self._moveTweener = _MOTION.NewMoveTweener(self._entity.transform, self._entity.aspect)
    self._timer = _Timer.New()
    self._process = 0
end

function _Overturn:Update(dt)
    _IBeaten.Update(self)
    _Base.Update(self, dt)
end

function _Overturn:NormalUpdate(dt)
    if (self._process == _processEnum.run) then
        self._moveTweener:Update(dt)

        local subject = self._moveTweener:GetSubject()
        local position = self._entity.transform.position
        local x = subject.x - position.x
        local y = subject.y - position.y

        self._entity.transform.shift:Set(x, y)

        if (not self._moveTweener.isRunning) then
            self._process = _processEnum.delay
        end
    elseif (self._process == _processEnum.delay) then
        self._timer:Update(dt)

        if (not self._timer.isRunning) then
            self._process = 0
            
            if (self._entity.transform.position.z ~= 0) then
                _BATTLE.Flight(self._entity.battle, self._entity.states, unpack(self._flightParam))
            else
                _STATE.Play(self._entity.states, self._nextState)
            end
        end
    end

    self:_Func("update")
end

function _Overturn:OnBeaten(isBeaten)
    local index = isBeaten and 2 or 1
    _ASPECT.Play(self._entity.aspect, self._frameaniDataSets[index])
end

---@param lateState Actor.State
---@param x int
---@param y int
---@param z int
---@param movingTime milli
---@param delayTime milli
---@param easing string
---@param flightParam table
---@param flagMap table<string, boolean>
---@param Func function @can null
function _Overturn:Enter(lateState, x, y, z, movingTime, delayTime, easing, flightParam, flagMap, Func)
    _Base.Enter(self)
    _IBeaten.Enter(self)

    self._moveTweener.target.x = x
    self._moveTweener.target.y = y
    self._moveTweener.target.z = z

    self._moveTweener:Enter(movingTime, self._entity.transform.position, _, easing)
    self._timer:Enter(delayTime)
    self._flightParam = flightParam or _defaultFlightParam
    self._flagMap = flagMap
    self._Func = Func
    self._process = _processEnum.run
    self:_Func("enter")
end

---@param nextState Actor.State
function _Overturn:Exit(nextState)
    _Base.Exit(self)

    if (self._entity.transform.position.z ~= 0 and not nextState:HasTag("flight")) then
        self._entity.transform.position.z = 0
        self._entity.transform.positionTick = true
    end

    self._entity.transform.shift:Set(0, 0)
    self:_Func("exit")
end

return _Overturn