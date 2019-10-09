--[[
	desc: Faint, A buff of faint.
	author: Musoucrow
	since: 2018-6-2
	alter: 2019-6-28
]]--

local _SOUND = require("lib.sound")
local _RESMGR = require("actor.resmgr")
local _FACTORY = require("actor.factory")
local _BATTLE = require("actor.service.battle")
local _STATE = require("actor.service.state")

local _Base = require("actor.buff.base")

---@class Actor.Buff.Faint : Actor.Buff
---@field protected _soundDataMap table<string, SoundData>
---@field protected _scale Graphics.Drawunit.Point
---@field protected _effect Actor.Entity
local _Faint = require("core.class")(_Base)

---@param entity Actor.Entity
---@param data Actor.RESMGR.BuffData
---@return boolean
function _Faint.CanNew(entity, data)
    return _Base.CanNew(entity, data) and entity.transform.position.z == 0 and entity.states and not _STATE.HasTag(entity.states, "fall")
end

---@param data Actor.RESMGR.BuffData
function _Faint.HandleData(data)
    data.effect = _RESMGR.GetInstanceData(data.effect)
    data.sound = _RESMGR.GetSoundData(data.sound)
end

function _Faint:Ctor(entity, data)
    _Base.Ctor(self, entity, data)

    local tmp = self._entity.battle.banCountMap.stun
    self._entity.battle.banCountMap.stun = 0
    self:Stun(self._entity.battle, self._entity.states, self._timer.to, 0, 0, 1)
    self._entity.battle.banCountMap.stun = tmp
end

function _Faint:OnStateSwitch()
    if (self._entity.states.current:GetName() == "stun") then
        return
    end

    self:Exit()
end

function _Faint:Stun(...)
    if (not _BATTLE.Stun(...)) then
        self._timer.from = self._timer.to
    else
        self._effect = _FACTORY.New(self._data.effect, {
            direction = self._entity.transform.direction,
            entity = self._entity
        })
    
        _SOUND.Play(self._data.sound)
        self._entity.states.caller:AddListener(self, self.OnStateSwitch)
    end
end

function _Faint:Exit()
    if (_Base.Exit(self)) then
        if (self._effect) then
            self._effect.identity.destroyProcess = 1
        end

        self._entity.states.caller:DelListener(self, self.OnStateSwitch)

        return true
    end

    return false
end

return _Faint