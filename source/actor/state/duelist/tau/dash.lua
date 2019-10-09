--[[
	desc: dash, a state of Tau.
	author: SkyFvcker
	since: 2018-9-2
	alter: 2019-5-16
]]--

local _RESMGR = require("actor.resmgr")
local _STATE = require("actor.service.state")
local _BUFF = require("actor.service.buff")

local _Easemove = require("actor.gear.easemove")
local _Gear_Attack = require("actor.gear.attack")
local _Base = require("actor.state.duelist.tau.dashAction")

---@class Actor.State.Duelist.Tau.Dash:Actor.State.Duelist.Tau.DashAction
---@field protected _attack Actor.Gear.Attack
---@field protected _easemove Actor.Gear.Easemove
---@field protected _easemoveParams table
---@field protected _buff Actor.Buff
local _Dash = require("core.class")(_Base)

function _Dash:Ctor(data, ...)
    _Base.Ctor(self, data, ...)

    self._easemoveParams = data.easemove
end

function _Dash:Init(entity)
    _Base.Init(self, entity)

    self._attack = _Gear_Attack.New(entity)
    self._easemove = _Easemove.New(self._entity.transform, self._entity.aspect)
end

function _Dash:NormalUpdate(dt, rate)
    _Base.NormalUpdate(self, dt, rate)

    self._easemove:Update(rate)
    self._attack:Update()

    if (self._process == 2 and not self._easemove.isRunning) then
        _STATE.Play(self._entity.states, self._nextState)
    end
end

function _Dash:Enter(laterState, skill)
    _Base.Enter(self, laterState, skill)

    self._easemove:Exit()
end

function _Dash:Exit()
    _Base.Exit(self)

    self._easemove:Exit()
    self._attack:Exit()

    if (self._buff) then
        self._buff:Exit()
    end
end

function _Dash:OnKeyTick()
    self._attack:Enter(self._attackDataSet, self._skill.attackValues)
    self._buff = _BUFF.AddBuff(self._entity, self._buffDatas)

    local direction = self._entity.transform.direction
    local easemoveParam = self._easemoveParams
    self._easemove:Enter("x", easemoveParam.power, easemoveParam.speed, direction)
end

return _Dash