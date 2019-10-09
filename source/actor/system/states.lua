--[[
	desc: States, a system of finite state machine.
	author: Musoucrow
	since: 2018-3-29
	alter: 2019-8-8
]]--

local _STATE = require("actor.service.state")

local _Base = require("actor.system.base")

---@class Actor.System.States : Actor.System
local _States = require("core.class")(_Base)

function _States:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        states = true
    }, "states")
end

---@param entity Actor.Entity
function _States:OnEnter(entity)
    for k, v in pairs(entity.states.map) do
        v:Init(entity)
    end

    _STATE.Play(entity.states, entity.states.firstState, true)
end

---@param entity Actor.Entity
function _States:OnExit(entity)
    _STATE.Reset(entity.states)
end

function _States:Update(dt, rate)
    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity
        e.states.current:Update(dt * e.identity.rate, rate * e.identity.rate)
    end
end

return _States