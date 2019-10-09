--[[
	desc: Roar, a state of tauAssaulter.
	author: SkyFvcker
	since: 2018-9-7
	alter: 2019-5-16
]]--

local _MAP = require("map.init")
local _SOUND = require("lib.sound")
local _FACTORY = require("actor.factory")
local _ASPECT = require("actor.service.aspect")
local _STATE = require("actor.service.state")
local _BUFF = require("actor.service.buff")
local _EFFECT = require("actor.service.effect")

local _Gear_Attack = require("actor.gear.attack")
local _Base = require("actor.state.base")

---@class Actor.State.Duelist.Tau.Roar:Actor.State
---@field protected _skill Actor.Skill
---@field protected _attack Actor.Gear.Attack
---@field protected _effectOffset table
---@field protected _shake table
---@field protected _faintTime int
---@field protected _buff Actor.Buff
---@field protected _Hit function
local _Roar = require("core.class")(_Base)

function _Roar:Ctor(data, ...)
    _Base.Ctor(self, data, ...)

    self._shake = data.shake
    self._effectOffset = data.effectOffset
    self._stopTime = data.stopTime
end

function _Roar:Init(entity)
    _Base.Init(self, entity)

    self._attack = _Gear_Attack.New(entity)
end

function _Roar:NormalUpdate(dt, rate)
    self._attack:Update()

    local main = _ASPECT.GetPart(self._entity.aspect) ---@type Graphics.Drawable.Frameani

    if (main:GetTick() == 1) then
        _SOUND.Play(self._soundDataSet)

        local t = self._entity.transform
        local param = {
            x = t.position.x + self._effectOffset.x * t.direction,
            y = t.position.y,
            z = t.position.z + self._effectOffset.z,
            direction = t.direction,
            entity = self._entity
        }

        local effect = _FACTORY.New(self._actorDataSet, param)
        self._attack:Enter(self._attackDataSet, self._skill.attackValues)
        self._attack.collision[_ASPECT.GetPart(effect.aspect)] = "attack"

        _MAP.camera:Shake(
            self._shake.time,
            self._shake.xa,
            self._shake.xb,
            self._shake.ya,
            self._shake.yb
        )
    end

    _STATE.AutoPlayEnd(self._entity.states, self._entity.aspect, self._nextState)
end

function _Roar:Enter(laterState, skill)
    _Base.Enter(self, laterState)

    self._skill = skill
    self._buff = _BUFF.AddBuff(self._entity, self._buffDatas)
    _ASPECT.GetPart(self._entity.aspect):SetTime(self._stopTime)
end

function _Roar:Exit(nextState)
    _Base.Exit(self)

    if (self._buff) then
        self._buff:Exit()
        self._buff = nil
    end
    
    local ai = self._entity.ais.container:Get("useSkill") ---@type Actor.Ai.UseSkill

    if (ai) then
        ai:Tick()
    end

    self._attack:Exit()
end

return _Roar