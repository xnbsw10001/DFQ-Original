--[[
	desc: Stay, a state of Swordman.
	author: Musoucrow
	since: 2019-5-26
]]--

local _ASPECT = require("actor.service.aspect")

local _Timer = require("util.gear.timer")
local _Base = require("actor.state.duelist.stay")

---@class Actor.State.Duelist.Swordman.Stay:Actor.State.Duelist.Stay
---@field protected _timer Util.Gear.Timer
---@field protected _resting boolean
---@field protected _restTime milli
local _Stay = require("core.class")(_Base)

function _Stay:Ctor(data, ...)
    _Base.Ctor(self, data, ...)

    self._restTime = data.restTime
    self._timer = _Timer.New(self._restTime[1])
end

function _Stay:NormalUpdate(dt, rate)
    _Base.NormalUpdate(self)

    self._timer:Update(dt)

    if (not self._resting and not self._timer.isRunning) then
        self._resting = true
        _ASPECT.Play(self._entity.aspect, self._frameaniDataSets[2 + self._process])

        if (self._process == 1) then
            self._time = self._time + self._timer.to

            if (self._time >= self._restTime[2]) then
                self._process = 2
            end
        end
    end

    if (self._resting and _ASPECT.GetPart(self._entity.aspect):TickEnd()) then
        _ASPECT.Play(self._entity.aspect, self._frameaniDataSets[self._process])
        self._resting = false
        self._timer:Enter()
    end
end

function _Stay:Enter(lateState, skill)
    _Base.Enter(self)

    self._timer:Enter()
    self._resting = false
    self._process = 1
    self._time = 0
end

return _Stay