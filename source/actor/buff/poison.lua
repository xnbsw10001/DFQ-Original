--[[
	desc: Poison, A buff of Poison.
	author: SkyFvcker
    since: 2018-11-14
    alter: 2019-5-11
]]--

local _SOUND = require("lib.sound")
local _RESMGR = require("actor.resmgr")
local _FACTORY = require("actor.factory")
local _ASPECT = require("actor.service.aspect")

local _Timer = require("util.gear.timer")
local _Gear_Attack = require("actor.gear.attack")
local _Color = require("graphics.drawunit.color")
local _Base = require("actor.buff.base")

---@class Actor.Buff.Poison : Actor.Buff
---@field protected _attack Actor.Gear.Attack
---@field protected _attackTimer Util.Gear.Timer
---@field protected _attackData Actor.RESMGR.AttackData
---@field protected _attackValue Actor.Gear.Attack.AttackValue
---@field protected _soundData SoundData
---@field protected _effect Actor.Entity
local _Poison = require("core.class")(_Base)

---@param data Actor.RESMGR.BuffData
function _Poison.HandleData(data)
    data.attack = _RESMGR.GetAttackData(data.attack)
    data.effect = _RESMGR.GetInstanceData(data.effect)
end

---@param attack Actor.Gear.Attack
---@param entity Actor.Entity
local function _Collide(attack, entity)
    if (attack._entity == entity) then
        local x, y, z = entity.transform.position:Get()

        return true, x, y, z - _ASPECT.GetPart(entity.aspect):GetHeight(true) * 0.5
    end

    return false
end

function _Poison:Ctor(entity, data)
    _Base.Ctor(self, entity, data)

    self._attackTimer = _Timer.New(data.interval)
    self._attackData = data.attack
    self._attackValue = data.attackValue
    self._attack = _Gear_Attack.New(entity)

    self._effect = _FACTORY.New(data.effect, {entity = entity})
end

function _Poison:OnUpdate(dt)
    self._attackTimer:Update(dt)

    if (not self._attackTimer.isRunning) then
        self._attack:Enter(self._attackData, self._attackValue, _, _Collide)
        self._attack:Update()
        self._attackTimer:Enter()
    end
end

function _Poison:Exit()
    if (_Base.Exit(self)) then
        self._attackTimer:Exit()
        self._effect.identity.destroyProcess = 1
        
        return true
    end

    return false
end

return _Poison