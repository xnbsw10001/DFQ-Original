--[[
	desc: Recovery, A module of Recovery buff.
	author: SkyFvcker
    since: 2018-11-15
    alter: 2019-6-2
]]--

local _SOUND = require("lib.sound")
local _RESMGR = require("actor.resmgr")
local _FACTORY = require("actor.factory")
local _ATTRIBUTE = require("actor.service.attribute")
local _Timer = require("util.gear.timer")

local _Base = require("actor.buff.base")

---@class Actor.Buff.Recovery : Actor.Buff
---@field protected _interval int
---@field protected _intervalTimer Util.Gear.Timer
---@field protected _healRate table
local _Recovery = require("core.class")(_Base)

function _Recovery:Ctor(entity, data)
    _Base.Ctor(self, entity, data)

    self._healRate = data.healRate
    self._intervalTimer = _Timer.New(data.interval)
    self:Process()
end

function _Recovery:OnUpdate(dt)
    self._intervalTimer:Update(dt)

    if (not self._intervalTimer.isRunning) then
        self:Process()
        self._intervalTimer:Enter()
    end
end

function _Recovery:Process()
    local value = self._entity.attributes.maxHp
    local healValue = math.floor(value * self._healRate.hp)
    _ATTRIBUTE.AddHpWithEffect(self._entity, healValue)
end

return _Recovery