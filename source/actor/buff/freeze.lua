--[[
	desc: Freeze, A buff of freeze.
	author: Musoucrow
	since: 2018-6-2
	alter: 2019-5-11
]]--

local _SOUND = require("lib.sound")
local _RESOURCE = require("lib.resource")
local _RESMGR = require("actor.resmgr")
local _FACTORY = require("actor.factory")
local _ASPECT = require("actor.service.aspect")
local _STATE = require("actor.service.state")
local _BATTLE = require("actor.service.battle")

local _Point = require("graphics.drawunit.point")
local _Base = require("actor.buff.base")

---@class Actor.Buff.Freeze : Actor.Buff
---@field protected _flagMap table
---@field protected _effectDataMap table<string, Actor.RESMGR.InstanceData>
---@field protected _soundDataMap table<string, SoundData>
---@field protected _scale Graphics.Drawunit.Point
---@field protected _front Actor.Entity
---@field protected _back Actor.Entity
local _Freeze = require("core.class")(_Base)

---@param entity Actor.Entity
---@param data Actor.RESMGR.BuffData
---@return boolean
function _Freeze.CanNew(entity, data)
    return _Base.CanNew(entity, data) and entity.transform.position.z == 0 and entity.states and not _STATE.HasTag(entity.states, "fall")
end

---@param data Actor.RESMGR.BuffData
function _Freeze.HandleData(data)
    data.effect = _RESOURCE.Recur(_RESMGR.GetInstanceData, data.effect, "aspect")
    data.sound = _RESOURCE.Recur(_RESMGR.GetSoundData, data.sound)
end

function _Freeze:Ctor(entity, data)
    _Base.Ctor(self, entity, data)

    self._flagMap = {hold = true}
    self._effectDataMap = data.effect
    self._soundDataMap = data.sound

    local battle = entity.battle
    local ret = _BATTLE.Stun(battle, entity.states, 100, 0, 0, 1, self._flagMap)

    local banCountMap = battle.banCountMap
    banCountMap.stun = banCountMap.stun + 1
    banCountMap.flight = banCountMap.flight + 1
    banCountMap.overturn = banCountMap.overturn + 1
    banCountMap.dmgSound = banCountMap.dmgSound + 1
    banCountMap.turn = banCountMap.turn + 1

    local t = entity.transform
    local param = {
        x = t.position.x,
        y = t.position.y,
        z = t.position.z,
        direction = t.direction,
        entity = entity
    }

    self._back = _FACTORY.New(self._effectDataMap.back, param)
    self._front = _FACTORY.New(self._effectDataMap.front, param)

    local main = _ASPECT.GetPart(entity.aspect) ---@type Graphics.Drawable.IRect
    local backPart = _ASPECT.GetPart(self._back.aspect) ---@type Graphics.Drawable.IRect
    local sx = main:GetWidth() / backPart:GetWidth()
    local sy = main:GetHeight() / (backPart:GetHeight() + 30)

    self._scale = _Point.New(false, sx, sy)
    self._back.transform.scale:Set(sx, sy)
    self._front.transform.scale:Set(sx, sy)

    entity.battle.beatenCaller:AddListener(self, self.OnBeaten)
    entity.states.caller:AddListener(self, self.OnStateSwitch)

    _SOUND.Play(self._soundDataMap.enter)

    if (not ret) then
        self._timer.from = self._timer.to
    end
end

function _Freeze:Exit()
    if (_Base.Exit(self)) then
        self._back.identity.destroyProcess = 1
        self._front.identity.destroyProcess = 1
        self._flagMap.hold = false

        local t = self._entity.transform
        local param = {
            x = t.position.x,
            y = t.position.y,
            z = t.position.z,
            direction = t.direction,
            entity = self._entity
        }

        local effect = _FACTORY.New(self._effectDataMap.die, param)
        effect.transform.scale:Set(self._scale:Get())

        local battle = self._entity.battle
        battle.banCountMap.stun = battle.banCountMap.stun - 1
        battle.banCountMap.flight = battle.banCountMap.flight - 1
        battle.banCountMap.overturn = battle.banCountMap.overturn - 1
        battle.banCountMap.dmgSound = battle.banCountMap.dmgSound - 1
        battle.banCountMap.turn = battle.banCountMap.turn - 1

        self._entity.battle.beatenCaller:DelListener(self, self.OnBeaten)
        self._entity.states.caller:AddListener(self, self.OnStateSwitch)
        _SOUND.Play(self._soundDataMap.exit)

        return true
    end

    return false
end

function _Freeze:OnBeaten()
    if (self._entity.battle.beatenConfig.element == "fire") then
        self:Exit()
    end
end

function _Freeze:OnStateSwitch()
    if (not _STATE.HasTag(self._entity.states, "stun")) then
        self:Exit()
    end
end

return _Freeze