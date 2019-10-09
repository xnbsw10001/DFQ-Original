--[[
	desc: Equipment, duelist's equipment.
	author: Musoucrow
	since: 2018-6-25
	alter: 2019-6-6
]]--

local _TABLE = require("lib.table")
local _ASPECT = require("actor.service.aspect")
local _ATTRIBUTE = require("actor.service.attribute")
local _EQUIPMENT = require("actor.service.equipment")

---@class Actor.Equipment
---@field protected _entity Actor.Entity
---@field protected _key string
---@field protected _attributeMarks table
---@field protected _data Actor.RESMGR.EquipmentData
local _Equipment = require("core.class")()

---@param entity Actor.Entity
---@param key string
---@param data Actor.RESMGR.EquipmentData
function _Equipment:Ctor(entity, key, data)
    self._entity = entity
    self._key = key
    self._attributeMarks = {}
    self._data = data

    if (data.add) then
        for k, v in pairs(data.add) do
            local mark = _ATTRIBUTE.Add(entity.attributes, "+", k, v)
            table.insert(self._attributeMarks, mark)
        end
    end
    
    if (data.passMap) then
        for k, v in pairs(data.passMap) do
            _ASPECT.SetAvatarPass(entity.aspect, k, v)
        end
    end

    if (data.avatar) then
        for k, v in pairs(data.avatar) do
            _ASPECT.SetPartAvatar(entity.aspect, k, v)
        end
    end
end

function _Equipment:Exit()
    for n=1, #self._attributeMarks do
        _ATTRIBUTE.Del(self._entity.attributes, self._attributeMarks[n])
    end

    if (self._data.passMap) then
        for k, v in pairs(self._data.passMap) do
            _ASPECT.SetAvatarPass(self._entity.aspect, k, nil)
        end
    end

    if (self._data.avatar) then
        for k in pairs(self._data.avatar) do
            _ASPECT.SetPartAvatar(self._entity.aspect, k, nil)
        end
    end
end

---@return string
function _Equipment:GetKey()
    return self._key
end

---@return Actor.RESMGR.EquipmentData
function _Equipment:GetData()
    return self._data
end

---@return Actor.RESMGR.EquipmentData
function _Equipment:ToData()
    local data = {}
    setmetatable(data, {__index = _TABLE.GetOrigin(self._data, true)})

    return data
end

function _Equipment:Save()
    local data = _TABLE.LightClone(self._data)
    data.path = self._data.path

    return data
end

function _Equipment:Break()
    _EQUIPMENT.Del(self._entity, self._key)
end

return _Equipment