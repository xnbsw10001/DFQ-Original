--[[
	desc: System, a business center.
	author: Musoucrow
	since: 2018-5-22
	alter: 2019-3-24
]]--

local _ECSMGR = require("actor.ecsmgr")

local _count = 0

---@class Actor.System
---@field protected _upperEvent event
---@field protected _list Core.QuickList
---@field protected _id int
---@field protected _name string
---@field protected _adds table<int, Actor.Entity>
---@field protected _dels table<int, Actor.Entity>
local _System = require("core.class")()

function _System:Ctor(upperEvent, passMap, name)
    _count = _count + 1

    ---@param entity Actor.Entity
    local Add = function(entity)
        if (self._list:GetLength() == 1) then
            self._upperEvent.AddSystem(self)
        end
        
        if (self._adds) then
            table.insert(self._adds, entity)
            
            if (#self._adds == 1) then
                self._upperEvent.Add(self)
            end
        end
    end

    ---@param entity Actor.Entity
    local Del = function(entity)
        if (self._list:GetLength() == 0) then
            self._upperEvent.DelSystem(self)
        end

        if (self._dels) then
            table.insert(self._dels, entity)

            if (#self._dels == 1) then
                self._upperEvent.Del(self)
            end
        end
    end

    self._upperEvent = upperEvent
    self._id = _count
    self._list = _ECSMGR.NewComboList(passMap, Add, Del)
    self._name = name

    if (self.OnEnter or self.OnInit) then
        self._adds = {}
    end

    if (self.OnExit) then
        self._dels = {}
    end
end

---@return int
function _System:GetID()
    return self._id
end

---@return string
function _System:GetName()
    return self._name
end

function _System:Enter()
    if (not self.OnEnter) then
        return
    end

    for n=1, #self._adds do
        self:OnEnter(self._adds[n])
    end
end

function _System:Init()
    if (self.OnInit) then
        for n=1, #self._adds do
            self:OnInit(self._adds[n])
        end
    end

    self._adds = {}
end

function _System:Exit()
    for n=1, #self._dels do
        self:OnExit(self._dels[n])
    end

    self._dels = {}
end

return _System