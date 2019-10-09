--[[
   desc: ECSMGR, a manager of entity, component and system.
   author: Musoucrow
   since: 2018-5-22
   alter: 2019-3-21
]]--

local _TABLE = require("lib.table")

local _Combo = require("actor.combo")

local _combos = {} ---@type table<number, Actor.Combo>
local _combosMap = {} ---@type table<string, table<number, Actor.Combo>>
local _addComponentCmds = {}
local _delComponentCmds = {}

local function _AddComponent(entity, key)
    if (not entity[key]) then
        return
    end

    if (not _combosMap[key]) then
        _combosMap[key] = {}

        for n=1, #_combos do
            if (_combos[n]:CheckPassed(key)) then
                table.insert(_combosMap[key], _combos[n])
            end
        end
    end

    for n=1, #_combosMap[key] do
        _combosMap[key][n]:AddEntity(entity)
    end
end

local function _DelComponent(entity, key)
    if (_combosMap[key]) then
        for n=1, #_combosMap[key] do
            _combosMap[key][n]:DelEntity(entity, key)
        end
    end
end

---@class Actor.ECSMGR
local _ECSMGR = {}

---@param entity Actor.Entity
---@param key string
---@param component table
function _ECSMGR.AddComponent(entity, key, component)
    entity[key] = component
    table.insert(_addComponentCmds, {entity = entity, key = key})
end

---@param entity Actor.Entity
---@param key string
function _ECSMGR.DelComponent(entity, key)
    table.insert(_delComponentCmds, {entity = entity, key = key})
end

---@return Core.QuickList
function _ECSMGR.NewComboList(passMap, OnAdd, OnDel)
    local combo = _Combo.New(passMap, OnAdd, OnDel)
    table.insert(_combos, combo)

    return combo:GetList()
end

---@return boolean
function _ECSMGR.AddComponentTick()
    if (#_addComponentCmds > 0) then
        for n in ipairs(_addComponentCmds) do
            _AddComponent(_addComponentCmds[n].entity, _addComponentCmds[n].key)
        end

        _addComponentCmds = {}

        return true
    end

    return false
end

---@return boolean
function _ECSMGR.DelComponentTick()
    for n in ipairs(_delComponentCmds) do
        _DelComponent(_delComponentCmds[n].entity, _delComponentCmds[n].key)
    end

    if (#_delComponentCmds > 0) then
        _delComponentCmds = {}
        return true
    end

    return false
end

return _ECSMGR