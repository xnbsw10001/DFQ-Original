--[[
	desc: Trigger, a system for collison business.
	author: Musoucrow
    since: 2019-6-26
    alter: 2019-7-3
]]--

local _ECSMGR = require("actor.ecsmgr")
local _ASPECT = require("actor.service.aspect")
local _DUELIST = require("actor.service.duelist")
local _MOTION = require("actor.service.motion")

local _Base = require("actor.system.base")

---@class Actor.System.Trigger : Actor.System
local _Trigger = require("core.class")(_Base)

function _Trigger:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        trigger = true
    }, "trigger")
end

---@param entity Actor.Entity
function _Trigger:OnEnter(entity)
    if (entity.trigger.collider) then
        _MOTION.AdjustCollider(entity.transform, entity.trigger.collider)
    end    
end

function _Trigger:LateUpdate()
    local list = _DUELIST.GetList()
    
    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity
        local trigger = e.trigger
        local main = _ASPECT.GetPart(e.aspect) ---@type Graphics.Drawable.Frameani
        local collider = trigger.collider or main:GetCollider() ---@type Actor.Collider
        local obj ---@type Actor.Entity

        for m=1, list:GetLength() do
            local ee = list:Get(m) ---@type Actor.Entity

            if (trigger.camp == 0 or ee.battle.camp == trigger.camp) then
                local c = _ASPECT.GetPart(ee.aspect):GetCollider()

                if (c and collider:Collide(c)) then
                    obj = ee
                    break
                end
            end
        end

        if (obj) then
            trigger.caller:Call(obj)

            if (trigger.mode == "exit") then
                _ECSMGR.DelComponent(e, "trigger")
            else
                e.identity.destroyProcess = 1
            end
        end
    end
end
--[[
function _Trigger:Draw()
    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity
        if (e.trigger.collider) then
            e.trigger.collider:Draw()
        end        
    end
end
]]--
return _Trigger