--[[
	desc: QuickList, be responsible for saving object.
	author: Musoucrow
	since: 2018-3-26
	alter: 2019-3-26
]]--

local _MATH = require("lib.math")

---@class Core.QuickList
---@field protected _list table
---@field protected _map table
local _QuickList = require("core.class")()

---@param self Core.QuickList
---@param start int @defalut=1
local function _Refresh(self, start)
    start = start or 1

    for n=start, #self._list do
        self._map[self._list[n]] = n
    end
end

function _QuickList:Ctor()
    self._list = {}
    self._map = {}

    self._SortSetting = function(list, index)
        self._map[list[index]] = index
    end
end

---@param order int
function _QuickList:Add(obj, order)
    if (self._map[obj]) then
        self:Del(obj)
    end

    local max = #self._list + 1
    order = order or max

    if (order > max) then
        order = max
    end

    table.insert(self._list, order, obj)
    _Refresh(self, order)
end

function _QuickList:Del(obj)
    if (self._map[obj]) then
        table.remove(self._list, self._map[obj])
        _Refresh(self, self._map[obj])
        self._map[obj] = nil
    end
end

function _QuickList:GetLength()
    return #self._list
end

function _QuickList:Get(index)
    return self._list[index]
end

function _QuickList:GetIndexWithValue(obj)
    return self._map[obj]
end

function _QuickList:HasValue(obj)
    return self._map[obj] ~= nil
end

function _QuickList:Sort(Func)
    _MATH.QuickSort(self._list, 1, #self._list, Func, self._SortSetting)
end

function _QuickList:Clear()
    self._list = {}
    self._map = {}
end

return _QuickList