--[[
	desc: a basic interface of time end.
	author: Musoucrow
	since: 2018-9-30
	alter: 2018-5-28
]]--

local _STATE = require("actor.service.state")

local _Timer = require("util.gear.timer")

---@class Actor.State.ITimeEnd
---@field protected _timer Util.Gear.Timer
local _ITimeEnd = require("core.class")()

function _ITimeEnd:Ctor(time)
    self._timer = _Timer.New(time)
end

function _ITimeEnd:Update(dt)
    self._timer:Update(dt)

    if (not self._timer.isRunning) then
        _STATE.Play(self._entity.states, self._nextState)
    end
end

function _ITimeEnd:Enter(time)
    self._timer:Enter(time)
end

return _ITimeEnd