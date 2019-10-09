--[[
	desc: Sit, a state of Duelist.
	author: Musoucrow
    since: 2018-5-28
    alter: 2019-6-9
]]--

local _ASPECT = require("actor.service.aspect")

local _Base = require("actor.state.base")
local _ITimeEnd = require("actor.state.itimeEnd")

---@class Actor.State.Sit : Actor.State
---@field protected _time milli
---@field protected _Func Func
local _Sit = require("core.class")(_Base, _ITimeEnd)

function _Sit:Ctor(data, ...)
    _Base.Ctor(self, data, ...)
    _ITimeEnd.Ctor(self, data.time)

    self._time = data.time
end

function _Sit:NormalUpdate(dt)
    _ITimeEnd.Update(self, dt)
end

function _Sit:Enter(laterState, Func, time)
    _Base.Enter(self)
    _ITimeEnd.Enter(self, time or self._time)

    if (Func) then
        Func()
    end

    self._entity.battle.banCountMap.attack = self._entity.battle.banCountMap.attack + 1
end

function _Sit:Exit()
    _Base.Exit(self)

    self._entity.battle.banCountMap.attack = self._entity.battle.banCountMap.attack - 1
end

return _Sit