--[[
	desc: Counterattack, a state of duelist.
	author: SkyFvcker
	since: 2018-8-5
	alter: 2019-8-10
]]--

local _SOUND = require("lib.sound")
local _TABLE = require("lib.table")
local _FACTORY = require("actor.factory")
local _ASPECT = require("actor.service.aspect")
local _STATE = require("actor.service.state")
local _BATTLE = require("actor.service.battle")
local _BUFF = require("actor.service.buff")

local _Timer = require( "util.gear.timer")
local _Attack = require("actor.gear.attack")
local _Easemove = require("actor.gear.easemove")
local _Base = require("actor.state.base")

---@class Actor.State.Duelist.Counterattack:Actor.State
---@field protected _skill Actor.Skill
---@field protected _effects table<int, Actor.Entity>
---@field protected _easemove_z Actor.Gear.Easemove
---@field protected _attack Actor.Gear.Attack
---@field protected _process int
---@field protected _stopTime table
---@field protected _fallSpeed int
---@field protected _falling boolean
---@field protected _timer boolean
---@field protected _buff Actor.Buff
---@field protected _shake table
local _Counterattack = require("core.class")(_Base)

function _Counterattack:Ctor(data, ...)
    _Base.Ctor(self, data, ...)

    self._stopTimes = data.stopTimes
    self._fallSpeed = data.fallSpeed
    self._shake = data.shake
    self._effects = {}
end

function _Counterattack:Init(entity)
    _Base.Init(self, entity)

    self._attack = _Attack.New(self._entity)
    self._easemove_z = _Easemove.New(entity.transform, entity.aspect)
    self._timer = _Timer.New()
end

function _Counterattack:NormalUpdate(dt, rate)
    self._attack:Update()

    if (self._falling) then
        if (self._process == 0) then
            self._easemove_z:Update(rate)

            if (self._entity.transform.position.z >= 0) then
                self._process = 1
                self._easemove_z.isRunning = false
                self._timer:Enter(self._stopTimes[2])
                self._entity.transform.position.z = 0
                self._entity.transform.positionTick = true
                self:AddEffect()
            end
        elseif (self._process == 1) then
            self._timer:Update(dt)

            if (not self._timer.isRunning) then
                _STATE.Play(self._entity.states, self._nextState)
            end
        end
    else
        local main = _ASPECT.GetPart(self._entity.aspect) ---@type Graphics.Drawable.Frameani

        if (self._process == 0 and main:GetTick() == main:GetLength() - 1) then
            main:SetTime(self._stopTimes[1])
            self._process = 1
        elseif (self._process == 1 and main:TickEnd()) then
            _STATE.Play(self._entity.states, self._nextState)
        end
    end
end

function _Counterattack:Enter(laterState, skill)
    _Base.Enter(self)

    self._skill = skill
    self._falling = laterState:HasTag("fall") or self._entity.transform.position.z < 0
    self._process = 0
    self._attack:Exit()

    local s = self._shake
    _BATTLE.Shake(self._entity.battle, s.time, s.xa, s.xb, s.ya, s.yb)

    if (self._falling) then
        _ASPECT.Play(self._entity.aspect, self._frameaniDataSets[2], false)
        self._easemove_z:Enter("z", 0, self._fallSpeed, 1)
        self._timer:Enter(self._stopTimes[2])
    else
        self:AddEffect()
    end

    if (self._soundDataSet.voice) then
        local index = self._falling and 2 or 1
        _SOUND.Play(self._soundDataSet.voice[index])
    end

    if (self._soundDataSet.effect) then
        _SOUND.Play(self._soundDataSet.effect)
    end

    self._buff = _BUFF.AddBuff(self._entity, self._buffDatas)
end

function _Counterattack:Exit()
    _Base.Exit(self)

    for n=1, #self._effects do
        self._effects[n].identity.destroyProcess = 1
    end

    self._effects = {}

    if (self._buff) then
        self._buff:Exit()
    end
end

function _Counterattack:AddEffect()
    local pos = self._entity.transform.position
    local param = {
        x = pos.x,
        y = pos.y,
        z = pos.z,
        direction = self._entity.transform.direction,
        entity = self._entity
    }

    self._effects[1] = _FACTORY.New(self._actorDataSet[1], param)
    self._effects[2] = _FACTORY.New(self._actorDataSet[2], param)

    self._attack:Enter(self._attackDataSet, self._skill.attackValues[1], _, _, true)
    self._attack.collision[_ASPECT.GetPart(self._effects[1].aspect)] = "attack"
end

return _Counterattack

