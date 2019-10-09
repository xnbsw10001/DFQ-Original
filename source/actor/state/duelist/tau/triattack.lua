--[[
	desc: Triattack, a state of tauAssaulter.
	author: SkyFvcker
	since: 2018-9-7
	alter: 2019-5-16
]]--

local _SOUND = require("lib.sound")
local _TABLE = require("lib.table")
local _RESMGR = require("actor.resmgr")
local _FACTORY = require("actor.factory")
local _ASPECT = require("actor.service.aspect")
local _STATE = require("actor.service.state")
local _BUFF = require("actor.service.buff")
local _EFFECT = require("actor.service.effect")

local _Gear_Attack = require("actor.gear.attack")
local _Base = require("actor.state.base")

---@class Actor.State.Duelist.Tau.Triattack:Actor.State
---@field protected _process int
---@field protected _skill Actor.Skill
---@field protected _attack Actor.Gear.Attack
---@field protected _rate number
---@field protected _stopTime int
---@field protected _effectOffset table
---@field protected _endTime table
local _Triattack = require("core.class")(_Base)

function _Triattack:Ctor(data, ...)
    _Base.Ctor(self, data, ...)

    self._rate = data.rate
    self._stopTime = data.stopTime
    self._effectOffset = data.effectOffset
    self._endTime = data.endTime
end

function _Triattack:Init(entity)
    _Base.Init(self, entity)

    self._attack = _Gear_Attack.New(entity)
end

function _Triattack:NormalUpdate(dt, rate)
    self._attack:Update()

    local main = _ASPECT.GetPart(self._entity.aspect) ---@type Graphics.Drawable.Frameani
    local tick = main:GetTick()

    if (tick == 2 and self._process == 3) then
        main:SetTime(self._stopTime)
    elseif (tick == 4) then
        _SOUND.Play(self._soundDataSet.attack)
        _SOUND.Play(self._soundDataSet.axe)

        local t = self._entity.transform
        local param = {
            x = t.position.x + t.direction * self._effectOffset.x,
            y = t.position.y + self._effectOffset.y,
            z = t.position.z,
            direction = t.direction,
            entity = self._entity
        }

        local effect = _FACTORY.New(self._actorDataSet[1], param)
        self._attack:Enter(self._attackDataSet, self._skill.attackValues[1])
        self._attack.collision[_ASPECT.GetPart(effect.aspect)] = "attack"
    elseif (tick == 5 and self._process == 3) then
        _SOUND.Play(self._soundDataSet.crash)

        local t = self._entity.transform
        local param = {
            x = t.position.x + t.direction * self._effectOffset.x,
            y = t.position.y + self._effectOffset.y,
            z = t.position.z,
            direction = t.direction,
            entity = self._entity,
            attackValue = self._skill.attackValues[2]
        }

        _FACTORY.New(self._actorDataSet[2], param)
    elseif (tick == 6 and self._process < 3) then
        main:SetTime(self._endTime)
    elseif (tick == 7) then
        if (self._process == 3) then
            _STATE.Play(self._entity.states, self._nextState)
        else
            _ASPECT.Play(self._entity.aspect, self._frameaniDataSets, false)
        end

        self._attack:Exit()
        self._process = self._process + 1
        self._entity.aspect.rate = self._entity.aspect.rate * self._rate
    end
end

function _Triattack:Enter(laterState, skill)
    _Base.Enter(self)

    self._skill = skill
    self._process = 1

    _ASPECT.Play(self._entity.aspect, self._frameaniDataSets, false)
    self._entity.aspect.rate = self._entity.aspect.rate * self._rate

    self._buff = _BUFF.AddBuff(self._entity, self._buffDatas)
end

function _Triattack:Exit(nextState)
    _Base.Exit(self)

    if (self._buff) then
        self._buff:Exit()
    end

    self._attack:Exit()
end

return _Triattack