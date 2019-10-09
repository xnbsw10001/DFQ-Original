--[[
	desc: Element, A module of element buff.
	author: Musoucrow
    since: 2019-6-26
]]--

local _RESMGR = require("actor.resmgr")
local _FACTORY = require("actor.factory")
local _BUFF = require("actor.service.buff")

local _Attack = require("actor.gear.attack")
local _Base = require("actor.buff.base")

---@class Actor.Buff.Element : Actor.Buff
---@field protected _effect Actor.Entity
---@field protected _attack Actor.Gear.Attack
---@field protected _attacking boolean
---@field protected _buffDatas table<int, Actor.RESMGR.BuffData>
---@field protected _antiElement string
local _Element = require("core.class")(_Base)

---@param attack Actor.Gear.Attack
---@param entity Actor.Entity
local function _Collide(attack, entity)
    if (attack._entity == entity.battle.beatenConfig.entity) then
        local x, y, z = entity.battle.beatenConfig.position:Get()
        return true, x, y, z
    end

    return false
end

function _Element.HandleData(data)
    data.actor = _RESMGR.GetInstanceData(data.actor)
    data.attack = _RESMGR.GetAttackData(data.attack)
    
    for n=1, #data.buff do
        data.buff[n] = _RESMGR.NewBuffData(data.buff[n].path, data.buff[n])
    end
end

function _Element:Ctor(entity, data)
    _Base.Ctor(self, entity, data)

    self._effect = _FACTORY.New(data.actor, {entity = entity})
    self._attack = _Attack.New(entity)
    self._attack:Enter(data.attack, _, _, _Collide)
    self._attacking = false
    self._buffDatas = data.buff
    self._antiElement = data.antiElement

    entity.battle.beatenCaller:AddListener(self, self.OnBeaten)
    entity.attacker.hitCaller:AddListener(self, self.OnHit)
end

function _Element:Exit()
    if (_Base.Exit(self)) then
        if (self._effect) then
            self._effect.identity.destroyProcess = 1
            self._effect = nil
        end

        self._entity.battle.beatenCaller:DelListener(self, self.OnBeaten)
        self._entity.attacker.hitCaller:DelListener(self, self.OnHit)
    end
end

---@param enemy Actor.Entity
function _Element:OnHit(enemy)
    if (self._attacking or not self:IsRunning()) then
        return
    end

    self._attacking = true
    self._attack:Reload()
    self._attack:Update()
    self._attacking = false
end

function _Element:OnBeaten()
    if (self._entity.battle.beatenConfig.element == self._antiElement) then
        local list = self._entity.buffs.list

        for n=1, #list do
            if (list[n]:GetData().tag == self._data.tag) then
                list[n]:Exit()
            end
        end

        for n=1, #self._buffDatas do
            _BUFF.AddBuff(self._entity, self._buffDatas[n])
        end
    end
end

return _Element