--[[
	desc: Down, a state of Duelist.
	author: Musoucrow
	since: 2018-9-30
	alter: 2018-10-1
]]--

local _ASPECT = require("actor.service.aspect")
local _BATTLE = require("actor.service.battle")

local _IBeaten = require("actor.state.duelist.ibeaten")
local _ITimeEnd = require("actor.state.itimeEnd")
local _Base = require("actor.state.base")

---@class Actor.State.Duelist.Down : Actor.State
local _Down = require("core.class")(_Base, _IBeaten, _ITimeEnd)

function _Down:Ctor(data, ...)
    _Base.Ctor(self, data, ...)
    _ITimeEnd.Ctor(self, data.time)
end

function _Down:Update(dt)
    _IBeaten.Update(self)
    _Base.Update(self, dt)
end

function _Down:NormalUpdate(dt)
    _ITimeEnd.Update(self, dt)
end

function _Down:OnBeaten(isBeaten)
    local index = isBeaten and self._entity.battle.deadProcess == 0 and 2 or 1
    _ASPECT.Play(self._entity.aspect, self._frameaniDataSets[index])
end

function _Down:Enter()
    _Base.Enter(self)
    _ITimeEnd.Enter(self)

    local e = self._entity
    _BATTLE.DieTick(e.battle, e.attributes, e.transform, e.attacker, e.identity)

    _IBeaten.Enter(self)
end

return _Down