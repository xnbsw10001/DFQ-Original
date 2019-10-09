--[[
	desc: Guard, a buff for guard.
	author: Musoucrow
    since: 2019-4-2
    alter: 2019-8-15
]]--

local _SYNTAX = require("lib.syntax")
local _STATE = require("actor.service.state")

local _Timer = require("util.gear.timer")
local _Base = require("actor.buff.base")

---@class Actor.Buff.Guard : Actor.Buff
---@field protected _guard boolean
---@field protected _state string
---@field protected _timer Util.Gear.Timer
---@field protected _hpRate number
---@field protected _attackValues table<int, Actor.Gear.Attack.AttackValue>
local _Guard = require("core.class")(_Base)

---@param entity Actor.Entity
---@param data Actor.RESMGR.BuffData
function _Guard:Ctor(entity, data)
    _Base.Ctor(self, entity, data)
    
    self._guard = false
    self._state = data.state
    self._attackValues = data.attackValues
    self._intervalTimer = _Timer.New(data.interval)
    self._hpRate = _SYNTAX.ToDifficulty(data.hpRate) or 1

    if (data.inCoolDown) then
        self._intervalTimer:Enter()
    else
        self._intervalTimer:Exit()
    end
    
    entity.battle.beatenCaller:AddListener(self, self.OnGuard)
end

function _Guard:OnUpdate(dt)
    self._intervalTimer:Update(dt)

    if (self._guard) then
        self._guard = false
        _STATE.Play(self._entity.states, self._state, false, self._attackValues)
    end
end

function _Guard:Exit()
    if (_Base.Exit(self)) then
        self._entity.battle.beatenCaller:DelListener(self, self.OnGuard)
    end
end

---@param self Actor.Buff.Guard
function _Guard:OnGuard()
    if (not self._intervalTimer.isRunning and self._entity.transform.position.z == 0 and self:CondHpRate()) then
        self._guard = not self._entity.battle.beatenConfig.isTurn

        if (self._guard) then
            self._intervalTimer:Enter()
        end
    end
end

function _Guard:CondHpRate()
    return self._entity.attributes.hp / self._entity.attributes.maxHp <= self._hpRate
end

return _Guard