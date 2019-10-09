--[[
	desc: Combo, a list of components combo.
	author: Musoucrow
	since: 2018-5-27
	alter: 2019-5-10
]]--

local _TABLE = require("lib.table")

local _QuickList = require("core.quickList")

local _emptyFunc = function() end

---@class Actor.Combo
---@field protected _list Core.QuickList
---@field protected _passMap table<string, boolean>
---@field protected _OnAdd function
---@field protected _OnDel function
local _Combo = require("core.class")()

function _Combo:Ctor(passMap, OnAdd, OnDel, OnInit)
    self._list = _QuickList.New()
    self._passMap = passMap
    self._OnAdd = OnAdd or _emptyFunc
    self._OnDel = OnDel or _emptyFunc
    self._OnInit = OnInit or _emptyFunc
end

function _Combo:Filter(entity)
    for k in pairs(self._passMap) do
        if (not entity[k]) then
            return false
        end
    end

    return true
end

---@param key string
---@return boolean
function _Combo:CheckPassed(key)
    return self._passMap[key]
end

function _Combo:GetList()
    return self._list
end

---@return boolean
function _Combo:AddEntity(entity)
    if (not self._list:HasValue(entity) and self:Filter(entity)) then
        self._list:Add(entity)
        self._OnAdd(entity)

        return true
    end

    return false
end

---@param entity Actor.Entity
---@param key string
---@return boolean
function _Combo:DelEntity(entity, key)
    if (self._list:HasValue(entity) and self:CheckPassed(key)) then
        self._list:Del(entity)
        self._OnDel(entity)

        return true
    end

    return false
end

return _Combo