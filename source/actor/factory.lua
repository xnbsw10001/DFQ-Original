--[[
	desc: FACTORY, a factory of actor.
	author: Musoucrow
	since: 2018-3-20
	alter: 2019-1-9
]]--

local _TABLE = require("lib.table")
local _RESMGR = require("actor.resmgr")
local _ECSMGR = require("actor.ecsmgr")

local _Transform = require("actor.component.transform")
local _Identity = require("actor.component.identity")
local _Input = require("actor.component.input")
local _Attacker = require("actor.component.attacker")
local _Onceplay = require("actor.component.onceplay")
local _Buffs = require("actor.component.buffs")

---@class Actor.FACTORY
local _FACTORY = {}

local _count = 0
local _emptyTable = {}

local _pool = {} ---@type table<string, Actor.Entity>
setmetatable(_pool, {__mode = 'v'})

local _newFuncGroup = {
    duelist = function(entity, data, param)
        _ECSMGR.AddComponent(entity, "input", _Input.New())

        if (not data.buffs) then
            _ECSMGR.AddComponent(entity, "buffs", _Buffs.New())
        end
    end,
    effect = function(entity, data, param)
        if (not entity.onceplay and data.onceplay ~= false) then
            _ECSMGR.AddComponent(entity, "onceplay", _Onceplay.New(_, param))
        end
    end,
    bullet = function(entity, data, param)
        _ECSMGR.AddComponent(entity, "attacker", _Attacker.New())
    end
}

---@param data Actor.RESMGR.InstanceData
---@return Actor.Entity
function _FACTORY.New(data, param)
    if (type(data) == "string") then
        data = _RESMGR.GetInstanceData(data)
    end
    
    local path = data.path
    local pos = string.find(path, "/")
    local _type = string.sub(path, 1, pos-1)
    _count = _count + 1

    ---@class Actor.Entity
    ---@field public aspect Actor.Component.Aspect
    ---@field public attributes Actor.Component.Attributes
    ---@field public identity Actor.Component.Identity
    ---@field public transform Actor.Component.Transform
    ---@field public input Actor.Component.Input
    ---@field public states Actor.Component.States
    ---@field public duelist Actor.Component.Duelist
    ---@field public attacker Actor.Component.Attacker
    ---@field public battle Actor.Component.Battle
    ---@field public ais Actor.Component.Ais
    ---@field public skills Actor.Component.Skills
    ---@field public onceplay Actor.Component.Onceplay
    ---@field public effect Actor.Component.Effect
    ---@field public obstacle Actor.Component.Obstacle
    ---@field public transparency Actor.Component.Transparency
    ---@field public buffs Actor.Component.Buffs
    ---@field public equipments Actor.Component.Equipments
    ---@field public dropItem Actor.Component.DropItem
    ---@field public bullet Actor.Component.Bullet
    ---@field public article Actor.Component.Article
    ---@field public topic Actor.Component.Topic
    ---@field public npc Actor.Component.Npc
    ---@field public summon Actor.Component.Summon
    ---@field public transport Actor.Component.Transport
    ---@field public sound Actor.Component.Sound
    ---@field public trigger Actor.Component.Trigger
    ---@field public follow Actor.Component.Follow
    local entity = {}
    _ECSMGR.AddComponent(entity, "identity", _Identity.New(data, param, _type, _count))

    for k, v in pairs(data) do
        if (type(v) == "table" and k ~= "identity" and v.class) then
            _ECSMGR.AddComponent(entity, k, v.class.New(v, param, data))
        end
    end

    if (_newFuncGroup[_type]) then
        _newFuncGroup[_type](entity, data, param)
    end

    if (entity.transform == nil) then
        _ECSMGR.AddComponent(entity, "transform", _Transform.New(_, param))
    end

    if (param.obstacle == false) then
        entity.obstacle = nil
    end

    if (entity.battle and not entity.attacker) then
        _ECSMGR.AddComponent(entity, "attacker", _Attacker.New())
    end

    _pool[path] = entity

    return entity
end

---@param data Actor.RESMGR.InstanceData
---@param param table
---@param pool table<int, Actor.Entity>
---@return Actor.Entity @ New an entity with pool, it's a entity's pool.
function _FACTORY.NewWithPool(data, param, pool)
    local entity ---@type Actor.Entity

    for n=1, #pool do
        if (pool[n].identity.destroyProcess == 2) then
            entity = pool[n]
            break
        end
    end

    if (not entity) then
        entity = _FACTORY.New(data, param)
        table.insert(pool, entity)

        return entity
    end

    for k, v in pairs(entity) do
        if (v.Reborn) then
            v:Reborn(param)
        end
    end

    for k, v in pairs(entity) do
        _ECSMGR.AddComponent(entity, k, v)
    end

    return entity
end

function _FACTORY.GetPool()
    return _pool
end

return _FACTORY