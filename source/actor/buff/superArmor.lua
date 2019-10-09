--[[
	desc: SuperArmor, A buff of super armor.
	author: Musoucrow
	since: 2018-8-8
	alter: 2019-7-8
]]--

local _RESMGR = require("actor.resmgr")
local _FACTORY = require("actor.factory")

local _Stroke = require("actor.buff.stroke")

---@class Actor.Buff.SuperArmor : Actor.Buff.Stroke
---@field protected _onlyFront boolean
---@field protected _actorData Actor.RESMGR.InstanceData
local _SuperArmor = require("core.class")(_Stroke)

---@param self Actor.Buff.SuperArmor
local function _OnBeaten(self)
    if (self._entity.battle.beatenConfig.isTurn) then
        self:Exit()
    else
        local t = self._entity.transform
        local param = {
            x = t.position.x,
            y = t.position.y,
            z = t.position.z,
            direction = t.direction,
            entity = self._entity
        }
        
        _FACTORY.New(self._actorData, param)
    end
end

function _SuperArmor.HandleData(data)
    _Stroke.HandleData(data)

    data.actor = _RESMGR.GetInstanceData(data.actor)
end

---@param entity Actor.Entity
function _SuperArmor:Ctor(entity, data)
    _Stroke.Ctor(self, entity, data)

    self._onlyFront = data.onlyFront or false
    self._actorData = data.actor

    local battle = entity.battle
    battle.banCountMap.flight = battle.banCountMap.flight + 1
    battle.banCountMap.overturn = battle.banCountMap.overturn + 1
    battle.banCountMap.stun = battle.banCountMap.stun + 1
    battle.banCountMap.dmgSound = battle.banCountMap.dmgSound + 1

    if (not self._onlyFront) then
        battle.banCountMap.turn = battle.banCountMap.turn + 1
    else
        battle.beatenCaller:AddListener(self, _OnBeaten)
    end

    entity.duelist.weight = entity.duelist.weight + 10
end

function _SuperArmor:Exit()
    if (_Stroke.Exit(self)) then
        local battle = self._entity.battle
        battle.banCountMap.flight = battle.banCountMap.flight - 1
        battle.banCountMap.overturn = battle.banCountMap.overturn - 1
        battle.banCountMap.stun = battle.banCountMap.stun - 1
        battle.banCountMap.dmgSound = battle.banCountMap.dmgSound - 1

        if (not self._onlyFront) then
            battle.banCountMap.turn = battle.banCountMap.turn - 1
        else
            battle.beatenCaller:DelListener(self, _OnBeaten)
        end

        self._entity.duelist.weight = self._entity.duelist.weight - 10

        return true
    end

    return false
end

return _SuperArmor