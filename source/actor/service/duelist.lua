--[[
	desc: DUELIST, a service for duelist.
	author: Musoucrow
	since: 2018-5-29
	alter: 2019-8-14
]]--

local _SOUND = require("lib.sound")
local _RESOURCE = require("lib.resource")
local _ECSMGR = require("actor.ecsmgr")
local _RESMGR = require("actor.resmgr")
local _FACTORY = require("actor.factory")
local _ASPECT = require("actor.service.aspect")
local _EFFECT = require("actor.service.effect")
local _BATTLE = require("actor.service.battle")
local _BUFF = require("actor.service.buff")

local _Caller = require("core.caller")

---@class Actor.Service.DUELIST
local _DUELIST = {}

local _enemyCount = 0
local _summon = {
    buffData = _RESMGR.NewBuffData("summon"),
    effectDatas = {
        _RESMGR.GetInstanceData("effect/summon/front"),
        _RESMGR.GetInstanceData("effect/summon/bottom"),
        _RESMGR.GetInstanceData("effect/summon/back")
    },
    soundData = _RESMGR.GetSoundData("summon")
}

local _auraDataMap = {
    boss = _RESMGR.GetInstanceData("effect/aura/boss"),
    named = _RESMGR.GetInstanceData("effect/aura/named"),
    partner = _RESMGR.GetInstanceData("effect/aura/partner"),
    player = _RESMGR.GetInstanceData("effect/aura/player")
}

local _callerMap = {
    add = _Caller.New(),
    del = _Caller.New(),
    appeared = _Caller.New(),
    clear = _Caller.New()
}

local _list = _ECSMGR.NewComboList({duelist = true},
    function(entity)
        if (entity.duelist.isEnemy) then
            _enemyCount = _enemyCount + 1

            _callerMap.add:Call(entity)

            if (_enemyCount == 1) then
                _callerMap.appeared:Call(entity)
            end
        end
    end,
    function(entity)
        if (entity.duelist.isEnemy) then
            _enemyCount = _enemyCount - 1

            _callerMap.del:Call(entity)

            if (_enemyCount == 0) then
                _callerMap.clear:Call(entity)
            end
        end
    end)

---@param range Graphics.Drawunit.Range
---@param collider Actor.Collider
function _DUELIST.StuffRangeWithCollider(range, collider)
    local solidRect = collider:GetList()[1]
    range:Set(solidRect:GetStruct("x"), solidRect:GetStruct("w"), solidRect:GetStruct("y1"), solidRect:GetStruct("y2"))
end

---@return int
function _DUELIST.GetEnemyCount()
    return _enemyCount
end

---@param camp int
function _DUELIST.GetPartnerCount(camp)
    local count = 0

    for n=1, _list:GetLength() do
        local e = _list:Get(n) ---@type Actor.Entity

        if (e.duelist and e.battle.camp == camp) then
            count = count + 1
        end
    end

    return count
end

---@param entity Actor.Entity
---@param camp int
---@param campType string
---@return Actor.Entity
function _DUELIST.GetAnEnemy(camp)
    for n=1, _list:GetLength() do
        local e = _list:Get(n) ---@type Actor.Entity

        if (_BATTLE.CondCamp(camp, e.battle.camp, "enemy")) then
            return e
        end
    end
end

---@param entity Actor.Entity
---@return Actor.Entity
function _DUELIST.GetAnPartner(entity)
    local camp = entity.battle.camp

    for n=1, _list:GetLength() do
        local e = _list:Get(n) ---@type Actor.Entity

        if (e.battle.camp == camp and entity ~= e) then
            return e
        end
    end
end

---@return Actor.Entity
function _DUELIST.Find(path)
    for n=1, _list:GetLength() do
        local e = _list:Get(n) ---@type Actor.Entity

        if (e.identity.path == path) then
            return e
        end
    end
end

---@param type string
function _DUELIST.AddListener(type, ...)
    _callerMap[type]:AddListener(...)
end

---@param type string
function _DUELIST.DelListener(type, ...)
    _callerMap[type]:DelListener(...)
end

---@return Core.QuickList
function _DUELIST.GetList()
    return _list
end

---@param aspect Actor.Component.Aspect
---@param pool table
---@param sx int
---@param sy int
---@param w int
---@param h int
function _DUELIST.GetIcon(aspect, pool, sx, sy, w, h)
    local data = aspect.portrait

    if (not pool or not pool[data]) then
        local iconData = {ox = math.floor(w * 0.5), oy = math.floor(h * 0.5)}
        setmetatable(iconData, {__index = data})

        local ox = math.floor(data.w * 0.5)
        local oy = 0
        local sw = data.image:getWidth()
        local sh = data.image:getHeight()

        if (data.quad) then
            local x, y = data.quad:getViewport()
            ox = ox + x
            oy = oy + y
        end

        iconData.quad = _RESOURCE.NewQuad(ox + sx, oy + sy, w, h, sw, sh)

        if (not pool) then
            return iconData
        else
            pool[data] = iconData
        end
    end

    return pool[data]
end

---@param entity Actor.Entity
---@param data Actor.RESMGR.InstanceData
---@param x int
---@param y int
---@param canCross boolean
---@return Actor.Entity
function _DUELIST.Summon(entity, data, x, y, canCross, noEffect)
    local param = {
        x = x,
        y = y,
        direction = entity.transform.direction,
        camp = entity.battle.camp,
        isEnemy = entity.duelist.isEnemy,
        canCross = canCross,
        noEffect = noEffect
    }
    
    return _DUELIST.SummonCustom(data, param)
end

---@param data Actor.RESMGR.InstanceData
---@param param table
---@return Actor.Entity
function _DUELIST.SummonCustom(data, param)
    local object = _FACTORY.New(data, param)
    _BUFF.AddBuff(object, _summon.buffData)

    if (not param.noEffect) then
        param.entity = object

        for n=1, #_summon.effectDatas do
            _FACTORY.New(_summon.effectDatas[n], param)
        end
    end

    _SOUND.Play(_summon.soundData)

    return object
end

---@param entity Actor.Entity
---@param type string
function _DUELIST.SetAura(entity, type)
    if (entity.duelist.aura) then
        entity.duelist.aura.identity.destroyProcess = 1
        entity.duelist.aura = nil
    end

    if (type) then
        entity.duelist.aura = _FACTORY.New(_auraDataMap[type], {entity = entity})
    end
end

---@param battle Actor.Component.Battle
---@param duelist Actor.Component.Duelist
---@return boolean
function _DUELIST.IsPartner(battle, duelist)
    return not duelist.isEnemy and battle.camp == 1
end

return _DUELIST