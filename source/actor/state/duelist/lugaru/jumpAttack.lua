--[[
	desc: JumpAttack, a state of Lugaru.
	author: SkyFvcker
    since: 2018-11-6
    alter: 2019-4-7
]]--

local _ASPECT = require("actor.service.aspect")
local _STATE = require("actor.service.state")
local _MOTION = require("actor.service.motion")
local _SOUND = require("lib.sound")

local _Jump = require("actor.gear.jump")
local _Easemove = require("actor.gear.easemove")
local _Gear_Attack = require("actor.gear.attack")
local _Base = require("actor.state.base")

---@class Actor.State.Duelist.Lugaru.JumpAttack:Actor.State
---@field protected _skill Actor.Skill
---@field protected _stopTime milli
---@field protected _attack Actor.Gear.Attack
---@field protected _process int
---@field protected _jump Actor.Gear.Jump
---@field protected _easemoveX Actor.Gear.Easemove
---@field protected _easemoveParams table
---@field protected _biteState string
local _JumpAttack = require("core.class")(_Base)

function _JumpAttack:Ctor(data, ...)
    _Base.Ctor(self, data, ...)

    self._easemoveParams = data.easemove
    self._stopTime = data.stopTime
    self._biteState = data.biteState
end

function _JumpAttack:Init(entity)
    _Base.Init(self, entity)

    self._attack = _Gear_Attack.New(entity)
    self._easemoveX = _Easemove.New(self._entity.transform, self._entity.aspect)
    self._jump = _Jump.New(self._entity.transform, self._entity.aspect, function (jump, process)
        self:PlayFrameani(process + 1)

        if (process == 2) then
            self._attack:Enter(self._attackDataSet[1], self._skill.attackValues[1])
            _SOUND.Play(self._soundDataSet[2])
        end
    end)

    if (self._biteState) then
        ---@param enemy Actor.Entity
        self._OnHit = function(attack, enemy)
            local p = enemy.transform.position
            self._entity.transform.position:Set(p.x, p.y)
            self._entity.transform.positionTick = true

            _STATE.Play(self._entity.states, self._biteState, true, self._skill)
        end
    end
end

function _JumpAttack:NormalUpdate(dt, rate)
    local main = _ASPECT.GetPart(self._entity.aspect) ---@type Graphics.Drawable.Frameani

    self._attack:Update()
    self._easemoveX:Update(rate)
    self._jump:Update(rate)

    if (self._process == 1 and (main:TickEnd() or self._entity.transform.position.z < 0)) then
        self._process = 2

        local x = self._easemoveParams[1]
        local z = self._easemoveParams[2]

        self._easemoveX:Enter("x", x.power, x.speed, self._entity.transform.direction)

        local power = self._entity.transform.position.z < 0 and math.floor(z.power * 0.5) or z.power
        self._jump:Enter(power, z.upSpeed, z.downSpeed)

        if (self._biteState) then
            self._attack:Enter(self._attackDataSet[2], self._skill.attackValues[2], self._OnHit)
        end

        _SOUND.Play(self._soundDataSet[1])
    elseif (self._process == 2 and not self._jump.isRunning) then
        self._process = 3
        self._easemoveX:Exit()
    elseif (self._process == 3) then
        _STATE.AutoPlayEnd(self._entity.states, self._entity.aspect, self._nextState)
    end
end

function _JumpAttack:Enter(lateState, skill)
    _Base.Enter(self)

    self._skill = skill
    self._process = 1
    _ASPECT.GetPart(self._entity.aspect):SetTime(self._stopTime)
end

function _JumpAttack:Exit()
    _Base.Exit(self)

    self._attack:Exit()
    self._easemoveX:Exit()
    self._jump:Exit()
end

---@param index int
function _JumpAttack:PlayFrameani(index)
    _ASPECT.Play(self._entity.aspect, self._frameaniDataSets[index])
end

return _JumpAttack