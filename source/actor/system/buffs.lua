--[[
	desc: Buffs, a system of buff management.
	author: Musoucrow
	since: 2018-6-2
	alter: 2019-7-5
]]--

local _BUFF = require("actor.service.buff")

local _Base = require("actor.system.base")

---@class Actor.System.Buffs : Actor.System
local _Buffs = require("core.class")(_Base)

function _Buffs:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        buffs = true
    }, "buffs")
end

---@param entity Actor.Entity
function _Buffs:OnEnter(entity)
    local buffs = entity.buffs
    
    if (buffs.data) then
        for n=1, #buffs.data do
            _BUFF.AddBuff(entity, buffs.data[n])
        end

        buffs.data = nil 
    end
end

---@param entity Actor.Entity
function _Buffs:OnExit(entity)
    for n=1, #entity.buffs.list do
        entity.buffs.list[n]:Exit()
    end

    entity.buffs.list = {}
end

function _Buffs:Update(dt)
    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity
        local buffs = e.buffs
        local ndt = dt * e.identity.rate

        for m=#buffs.list, 1, -1 do
            buffs.list[m]:Update(ndt)
        end
    end
end

function _Buffs:LateUpdate(dt)
    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity
        local buffs = e.buffs
        local ndt = dt * e.identity.rate

        for m=#buffs.list, 1, -1 do
            buffs.list[m]:LateUpdate(ndt)

            if (not buffs.list[m]:IsRunning()) then
                table.remove(buffs.list, m)
            end
        end
    end
end

return _Buffs

