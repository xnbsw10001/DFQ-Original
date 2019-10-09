--[[
	desc: multidash, a state of Tau.
	author: SkyFvcker
	since: 2018-9-8
	alter: 2019-8-9
]]--

local _MATH = require("lib.math")
local _MOTION = require("actor.service.motion")
local _STATE = require("actor.service.state")
local _BUFF = require("actor.service.buff")
local _DUELIST = require("actor.service.duelist")

local _Attack = require("actor.gear.attack")
local _Base = require("actor.state.duelist.tau.dashAction")

---@class Actor.State.Duelist.Tau.Multidash:Actor.State.Duelist.Tau.DashAction
---@field protected _attack Actor.Gear.Attack
---@field protected _buff Actor.Buff
---@field protected _moveTime int
---@field protected _length int
---@field protected _angle table
---@field protected _countMax int
---@field protected _count int
local _Dash = require("core.class")(_Base)

function _Dash:Ctor(data, ...)
    _Base.Ctor(self, data, ...)

    self._angle = data.angle
    self._moveTime = data.moveTime
    self._length = data.length
    self._countMax = data.useCount
end

function _Dash:Init(entity)
    _Base.Init(self, entity)

    self._attack = _Attack.New(entity)
    self._moveTweener = _MOTION.NewMoveTweener(self._entity.transform, self._entity.aspect)
    self._moveTweener:SetEasing("outQuadFixed")
end

function _Dash:NormalUpdate(dt, rate)
    _Base.NormalUpdate(self, dt, rate)

    self._attack:Update()
    self._moveTweener:Update(dt)

    if (self._process == 2) then
        local process = self._moveTweener:GetProcess()
        
        if (process > 0.3 and not self._buff) then
            self._buff = _BUFF.AddBuff(self._entity, self._buffDatas)
        elseif (process < 0.3 and process > 0.2 and self._buff) then
            self._buff:Exit()
            self._buff = nil
        end

        if (not self._moveTweener.isRunning) then
            self._count = self._count - 1
    
            if (self._count == 0) then
                _STATE.Play(self._entity.states, self._nextState)
            else
                self._attack:Exit()
                self:Enter(self, self._skill)
            end
        end
    end 
end

function _Dash:Enter(lateState, skill)
    _Base.Enter(self, lateState, skill)

    local tx, ty
    local transform = self._entity.transform
    local target = _DUELIST.GetAnEnemy(self._entity.battle.camp)
    local px, py = transform.position:Get()

    if (target) then
        tx, ty = target.transform.position:Get()
    else
        tx, ty = transform.position:Get()
        tx = tx + transform.direction
    end

    local _, radian = _MATH.GetRadianWithFan2(px, py, tx, ty, math.rad(self._angle))
    local x, y = _MATH.RotatePoint(px + self._length, py, px, py, -radian)

    self._moveTweener:Exit()
    self._moveTweener.target.x = x
    self._moveTweener.target.y = y

    transform.direction = px > x and -1 or 1
    transform.scaleTick = true

    if (lateState ~= self) then
        self._count = self._countMax
    end

    if (not self._buff) then
        self._buff = _BUFF.AddBuff(self._entity, self._buffDatas)
    end
end

function _Dash:Exit()
    _Base.Exit(self)

    self._attack:Exit()

    if (self._buff) then
        self._buff:Exit()
        self._buff = nil
    end
end

function _Dash:OnKeyTick()
    self._moveTweener:Enter(self._moveTime, self._entity.transform.position)
    self._attack:Enter(self._attackDataSet, self._skill.attackValues)
end

return _Dash