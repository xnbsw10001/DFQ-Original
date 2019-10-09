--[[
	desc: Triattack, a state of goblinChief.
	author: SkyFvcker
	since: 2018-9-4
	alter: 2019-8-29
]]--

local _SOUND = require("lib.sound")
local _ASPECT = require("actor.service.aspect")
local _STATE = require("actor.service.state")
local _BUFF = require("actor.service.buff")

local _Gear_Attack = require("actor.gear.attack")
local _Base = require("actor.state.base")

---@class Actor.State.Duelist.Goblin.Triattack:Actor.State
---@field protected _process int
---@field protected _skill Actor.Skill
---@field protected _attack Actor.Gear.Attack
---@field protected _stopTime int
---@field protected _addRate number
---@field protected _addStun number
---@field protected _stopTime milli
local _Triattack = require("core.class")(_Base)

function _Triattack:Ctor(data, ...)
    _Base.Ctor(self, data, ...)

    self._addRate = data.addRate
    self._addStun = data.addStun
    self._stopTime = data.stopTime
end

function _Triattack:Init(entity)
    _Base.Init(self, entity)

    self._attack = _Gear_Attack.New(entity)
end

function _Triattack:NormalUpdate(dt, rate)
    self._attack:Update()

    local main = _ASPECT.GetPart(self._entity.aspect) ---@type Graphics.Drawable.Frameani
    local tick = main:GetTick()

    if (tick == 1) then
        self._entity.aspect.rate = self._entity.aspect.rate + self._addRate
    elseif (tick == 3) then
        self._attack:Enter(self._attackDataSet, self._skill.attackValues)
        self._attack.stun.power = self._attack.stun.power * self._addStun * self._process
        _SOUND.Play(self._soundDataSet.swing)
    elseif (tick == 4) then
        self._process = self._process + 1
        self._attack:Exit()

        if (self._buff and self._process == 3) then
            self._buff:Exit()
            self._buff = nil
        end

        _ASPECT.Play(self._entity.aspect, self._frameaniDataSets, false)
    end

    if (self._process == 4) then
        _STATE.Play(self._entity.states, self._nextState)
    end
end

function _Triattack:Enter(laterState, skill)
    _Base.Enter(self)

    self._skill = skill
    self._process = 1

    _SOUND.Play(self._soundDataSet.voice)

    _ASPECT.Play(self._entity.aspect, self._frameaniDataSets, false)
    _ASPECT.GetPart(self._entity.aspect):SetTime(self._stopTime)

    self._buff = _BUFF.AddBuff(self._entity, self._buffDatas)
end

function _Triattack:Exit(nextState)
    _Base.Exit(self)

    if (self._buff) then
        self._buff:Exit()
        self._buff = nil
    end

    self._attack:Exit()
end

return _Triattack