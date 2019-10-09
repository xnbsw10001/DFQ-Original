--[[
	desc: Battle, a component for battle business.
	author: Musoucrow
	since: 2018-3-29
	alter: 2019-4-10
]]--

local _TABLE = require("lib.table")
local _RESOURCE = require("lib.resource")
local _RESMGR = require("actor.resmgr")

local _Point3 = require("graphics.drawunit.point3")
local _Caller = require("core.caller")

---@class Actor.Component.Battle
---@field public camp int @1=we, 2=enemy
---@field public shaker Util.Gear.Shaker
---@field public pureColorTweener Util.Gear.Tweener
---@field public dmgSoundDatas table<number, SoundData>
---@field public dieSoundDatas table<number, SoundData>
---@field public beatenCaller Core.Caller
---@field public deadCaller Core.Caller
---@field public deadProcess int
---@field public overKill boolean
---@field public banCountMap table<string, int>
---@field public hasEffect boolean
---@field public hasDestroy boolean
local _Battle = require("core.class")()

local _emptyTab = {}

function _Battle.HandleData(data)
    if (data.dmgSound) then
        data.dmgSound = _RESOURCE.Recur(_RESMGR.GetSoundData, data.dmgSound)
    end

    if (data.dieSound) then
        data.dieSound = _RESOURCE.Recur(_RESMGR.GetSoundData, data.dieSound)
    end
end

function _Battle:Ctor(data, param)
    self.camp = param.camp or data.camp or 0
    self.deadProcess = 0
    self.overKill = false
    self.dmgSoundDatas = data.dmgSound
    self.dieSoundDatas = data.dieSound
    self.beatenCaller = _Caller.New()
    self.deadCaller = _Caller.New()
    self.hasEffect = data.hasEffect
    self.hasDestroy = data.hasDestroy

    if (self.hasEffect == nil) then
        self.hasEffect = true
    end

    if (self.hasDestroy == nil) then
        self.hasDestroy = true
    end

    local banCountMap = data.banCountMap or _emptyTab

    self.banCountMap = {
        stun = banCountMap.stun or 0,
        flight = banCountMap.flight or 0,
        overturn = banCountMap.overturn or 0,
        dmgSound = banCountMap.dmgSound or 0,
        attack = banCountMap.attack or 0,
        turn = banCountMap.turn or 0,
        die = banCountMap.die or 0,
        hide = banCountMap.hide or 0,
        pure = banCountMap.pure or 0,
    }

    self.beatenConfig = {
        position = _Point3.New(true),
        damage = 0,
        direction = 0,
        isPhysical = false,
        isCritical = false,
        isTurn = false,
        element = "",
        entity = nil, ---@type Actor.Entity
        attack = nil, ---@type Actor.Gear.Attack
    }
end

return _Battle