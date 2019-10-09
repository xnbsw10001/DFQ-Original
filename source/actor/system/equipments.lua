--[[
	desc: Equipments, a system of equipment management.
	author: Musoucrow
	since: 2018-6-25
	alter: 2019-9-3
]]--

local _ASPECT = require("actor.service.aspect")
local _EQUIPMENT = require("actor.service.equipment")

local _Base = require("actor.system.base")

---@class Actor.System.Equipments : Actor.System
local _Equipments = require("core.class")(_Base)

function _Equipments:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        equipments = true
    }, "equipments")
end

---@param entity Actor.Entity
function _Equipments:OnEnter(entity)
    for k, v in pairs(entity.equipments.data) do
        if (k ~= "class") then
            _EQUIPMENT.Set(entity, k, v)
        end
    end

    entity.equipments.data = nil
    _ASPECT.AdjustAvatar(entity.aspect, entity.states)
end

return _Equipments