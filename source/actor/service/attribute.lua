--[[
	desc: ATTRIBUTE, a service for attribute.
	author: Musoucrow
    since: 2018-6-25
    alter: 2019-7-22
]]--

local _SOUND = require("lib.sound")
local _RESMGR = require("actor.resmgr")
local _WORLD = require("actor.world")
local _FACTORY = require("actor.factory")

---@class Actor.Service.ATTRIBUTE
local _ATTRIBUTE = {}

local _hpSoundData = _RESMGR.GetSoundData("hpRecovered")
local _hpEffectData = _RESMGR.GetInstanceData("effect/hitting/heal")

---@param attributes Actor.Component.Attributes
---@param value number
function _ATTRIBUTE.AddHp(attributes, value)
    attributes.hp = attributes.hp + value
    local max = attributes.maxHp - attributes.negativeHp

    if (attributes.hp < 0) then
        attributes.hp = 0
    elseif (attributes.hp > max) then
        attributes.hp = max
    end
end

---@param attributes Actor.Component.Attributes
---@param operation string @"+" or "*"
---@param key string
---@param value number
---@return table
function _ATTRIBUTE.Add(attributes, operation, key, value)
    operation = operation or "+"
    local mark = {operation = operation, key = key, value = value}
    local value = operation == "+" and value or attributes.origin[key] * value

    attributes[key] = attributes[key] + value
    attributes.journal[mark] = true

    if (key == "maxHp" and attributes.hp > attributes.maxHp) then
        attributes.hp = attributes.maxHp
    end

    return mark
end

---@param attributes Actor.Component.Attributes
---@param mark table
function _ATTRIBUTE.Del(attributes, mark)
    local value = mark.operation == "+" and mark.value or attributes.origin[mark.key] * mark.value

    attributes[mark.key] = attributes[mark.key] - value
    attributes.journal[mark] = nil

    if (mark.key == "maxHp" and attributes.hp > attributes.maxHp) then
        attributes.hp = attributes.maxHp
    end
end

---@param attributes Actor.Component.Attributes
function _ATTRIBUTE.Adjust(attributes)
    for k, v in pairs(attributes.origin) do
        attributes[k] = v
    end

    for k in pairs(attributes.journal) do
        local value = k.operation == "+" and k.value or attributes.origin[k.key] * k.value
        attributes[k.key] = attributes[k.key] + value
    end
end

---@param entity Actor.Entity
---@param value int
function _ATTRIBUTE.AddHpWithEffect(entity, value)
    _ATTRIBUTE.AddHp(entity.attributes, value)
    _SOUND.Play(_hpSoundData)

    local pos = entity.transform.position
    _WORLD.AddDamageTip(value, "hp", pos.x, pos.y + pos.z)

    _FACTORY.New(_hpEffectData, {entity = entity})
end

return _ATTRIBUTE