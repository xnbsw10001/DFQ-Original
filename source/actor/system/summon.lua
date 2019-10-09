--[[
	desc: Summon, a system for summon business.
	author: Musoucrow
    since: 2019-5-4
    alter: 2019-6-15
]]--

local _FACTORY = require("actor.factory")

local _Base = require("actor.system.base")

---@class Actor.System.Summon : Actor.System
local _Summon = require("core.class")(_Base)

---@param entity Actor.Entity
local function _NewActor(entity, param)
    local t = entity.transform
    local p = {}
    setmetatable(p, {__index = param})
    
    p.x = t.position.x
    p.y = t.position.y
    p.z = p.z or t.position.z
    p.direction = p.direction or t.direction
    p.entity = p.isSuperior and entity.identity.superior or entity
    _FACTORY.New(p.path, p)
end

function _Summon:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        summon = true
    }, "summon")
end

---@param entity Actor.Entity
function _Summon:OnEnter(entity)
    local summons = entity.summon.summons

    for n=1, #summons do
        if (not summons[n].inDestroy) then
            _NewActor(entity, summons[n])
        end
    end
end

---@param entity Actor.Entity
function _Summon:OnExit(entity)
    local summons = entity.summon.summons

    for n=1, #summons do
        if (summons[n].inDestroy) then
            _NewActor(entity, summons[n])
        end
    end
end

return _Summon