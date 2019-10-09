--[[
	desc: NormalAttack, a state of Swordman.
	author: Musoucrow
	since: 2018-12-18
	alter: 2019-5-30
]]--

local _TABLE = require("lib.table")
local _SOUND = require("lib.sound")
local _ASPECT = require("actor.service.aspect")
local _STATE = require("actor.service.state")
local _INPUT = require("actor.service.input")
local _MOTION = require("actor.service.motion")
local _EQUIPMENT = require("actor.service.equipment")
local _ATTRIBUTE = require("actor.service.attribute")

local _Easemove = require("actor.gear.easemove")
local _Attack = require("actor.gear.attack")
local _BattleJudge = require("actor.ai.battleJudge")

local _Base = require("actor.state.base")

---@class Actor.State.Duelist.Swordman.NormalAttack:Actor.State
---@field protected _process int
---@field protected _easemove Actor.Gear.Easemove
---@field protected _attack Actor.Gear.Attack
---@field protected _hasPressed boolean
---@field protected _judgeAis table<number, Actor.Ai.Judge>
---@field protected _skill Actor.Skill
---@field protected _colliderDatas table<number, Actor.RESMGR.ColliderData>
---@field protected _easemoveParams table
---@field protected _frames table
---@field protected _ticks table
---@field protected _hitstopMap table
---@field protected _coolDown table
local _NormalAttack = require("core.class")(_Base)

function _NormalAttack:Ctor(data, ...)
    _Base.Ctor(self, data, ...)

    self._easemoveParams = data.easemove
    self._frames = data.frames
    self._ticks = data.ticks
    self._hitstopMap = data.hitstop
    self._coolDown = data.coolDown
end

function _NormalAttack:Init(entity)
    _Base.Init(self, entity)

    self._easemove = _Easemove.New(self._entity.transform, self._entity.aspect)
    self._attack = _Attack.New(self._entity)
    self._judgeAis = {}
    self._aiFrame = 0

    for n=1, #self._colliderDataSet do
        self._judgeAis[n] = _BattleJudge.New(self._entity, self._colliderDataSet[n])
    end

    ---@param attack Actor.Gear.Attack
    self._OnHit = function(attack)
        if (not attack:HasAttacked()) then
            local kind = _EQUIPMENT.GetSubKind(self._entity.equipments, "weapon")
            --_ATTRIBUTE.AddMp(self._entity.attributes, self._mpRecovery[kind])

            local cds = {}

            ---@param v Actor.Skill
            for k, v in self._entity.skills.container:Pairs() do
                if (v:InCoolDown() and not v.isUltimate) then
                    table.insert(cds, v)
                end
            end

            if (#cds > 0) then
                local skill = cds[math.random(1, #cds)] ---@type Actor.Skill
                skill:SetNowTime(skill:GetNowTime() + self._coolDown[kind])
            end
        end
    end
end

function _NormalAttack:NormalUpdate(dt, rate)
    local main = _ASPECT.GetPart(self._entity.aspect) ---@type Graphics.Drawable.Frameani
    local frame = main:GetFrame()
    local tick = main:GetTick()

    self._easemove:Update(rate)

    if (self:HasTick()) then
        self:EnterAttack()
    end

    self._attack:Update()

    if (tick == self._easemoveParams[self._process].tick) then
        local direction = self._entity.transform.direction
        local arrowDirection = _INPUT.GetArrowDirection(self._entity.input, direction)

        if (arrowDirection >= 0) then
            local easemoveParam = self._easemoveParams[self._process][arrowDirection + 1]
            self._easemove:Enter("x", easemoveParam.power, easemoveParam.speed, direction)
        end
    end

    local isEnd = self._process > #self._frames
    local keyFrame = not isEnd and self._frames[self._process] - 1 or 0

    if (not isEnd) then
        if (tick >= self._aiFrame) then
            self._judgeAis[self._process]:Tick()
        end
    end

    if (not isEnd and self._hasPressed and frame > keyFrame) then
        self:SetProcess(self._process + 1)
    elseif (main:TickEnd()) then
        _STATE.Play(self._entity.states, self._nextState)
    end
end

function _NormalAttack:Enter(lateState, skill)
    if (lateState ~= self) then
        _Base.Enter(self)

        self._skill = skill

        for n=1, #self._judgeAis do
            self._judgeAis[n].key = self._skill:GetKey()
        end

        self._easemove:Exit()
        self:SetProcess(1)
    else
        self._hasPressed = true
    end
end

function _NormalAttack:Exit(nextState)
    if (nextState == self) then
        return
    else
        _Base.Exit(self, nextState)
    end
end

---@param process int
function _NormalAttack:SetProcess(process)
    self._process = process
    self._hasPressed = false
    self._skill:Reset()
    _MOTION.TurnDirection(self._entity.transform, self._entity.input)

    if (self._frames[self._process]) then
        local maxFrame = _ASPECT.GetPart(self._entity.aspect):GetLength()
        self._aiFrame = math.random(self._frames[self._process] - 1, maxFrame)
    else
        self._aiFrame = 0
    end

    local n = math.random(1, _TABLE.Len(self._soundDataSet.voice))
    _SOUND.Play(self._soundDataSet.voice[n])

    local kind = _EQUIPMENT.GetSubKind(self._entity.equipments, "weapon")
    local soundDatas = self._soundDataSet.swing[kind]
    n = math.random(1, _TABLE.Len(soundDatas))
    _SOUND.Play(soundDatas[n])

    _ASPECT.Play(self._entity.aspect, self._frameaniDataSets[process])
end

function _NormalAttack:EnterAttack()
    self._attack:Enter(self._attackDataSet[self._process], self._skill.attackValues[1], self._OnHit)

    local kind = _EQUIPMENT.GetSubKind(self._entity.equipments, "weapon")
    local hitstop = self._hitstopMap[kind]
    self._attack.hitstop = hitstop[1]
    self._attack.selfstop = hitstop[2]
    self._attack.shake.time = hitstop[1]

    local soundDatas = self._soundDataSet.hitting[kind]
    self._attack.soundDataSet[#self._attack.soundDataSet + 1] = soundDatas
end

---@return boolean
function _NormalAttack:HasTick()
    return _ASPECT.GetPart(self._entity.aspect):GetTick() == self._ticks[self._process]
end

---@return int
function _NormalAttack:GetProcess()
    return self._process
end

return _NormalAttack

