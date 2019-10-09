--[[
	desc: UpperSlash, a state of Swordman.
	author: SkyFvcker
	since: 2018-7-30
	alter: 2019-5-16
]]--

local _SOUND = require("lib.sound")
local _TABLE = require("lib.table")
local _FACTORY = require("actor.factory")
local _RESMGR = require("actor.resmgr")
local _ASPECT = require("actor.service.aspect")
local _STATE = require("actor.service.state")
local _INPUT = require("actor.service.input")
local _EQUIPMENT = require("actor.service.equipment")
local _BUFF = require("actor.service.buff")
local _EFFECT = require("actor.service.effect")
local _MOTION = require("actor.service.motion")

local _Easemove = require("actor.gear.easemove")
local _Attack = require("actor.gear.attack")
local _Base = require("actor.state.base")

---@class Actor.State.Duelist.Swordman.UpperSlash:Actor.State
---@field protected _attack Actor.Gear.Attack
---@field protected _skill Actor.Skill
---@field protected _effect Actor.Entity
---@field protected _easemoveTick int
---@field protected _easemoveParams table
---@field protected _easemove Actor.Gear.Easemove
---@field protected _hitstopMap table
---@field protected _effectTick int
---@field protected _cutTime int
---@field protected _line int
---@field protected _buff Actor.Buff
---@field protected _ascend boolean
---@field protected _breaking boolean
---@field protected _process int
---@field protected _figureData Lib.RESOURCE.SpriteData
local _UpperSlash = require("core.class")(_Base)

---@param attack Actor.Gear.Attack
---@param entity Actor.Entity
local function _Collide(attack, entity)
    local isdone, x, y, z = _Attack.DefaultCollide(attack, entity)

    if (isdone) then
        return isdone, x, y, z, _, _, entity.battle.banCountMap.flight > 0
    end

    return false
end

function _UpperSlash:Ctor(data, ...)
    _Base.Ctor(self, data, ...)

    self._easemoveTick = data.easemoveTick
    self._easemoveParams = data.easemove
    self._hitstopMap = data.hitstop
    self._effectTick = data.effectTick
    self._ascend = data.ascend
    self._breaking = data.breaking

    if (data.comboBuff) then
        self._comboBuffData = _RESMGR.NewBuffData(data.comboBuff.path, data.comboBuff)
    end
end

function _UpperSlash:Init(entity)
    _Base.Init(self, entity)

    self._easemove = _Easemove.New(self._entity.transform, self._entity.aspect)
    self._attack = _Attack.New(self._entity)
end

function _UpperSlash:NormalUpdate(dt, rate)
    self._easemove:Update(rate)

    local main = _ASPECT.GetPart(self._entity.aspect) ---@type Graphics.Drawable.Frameani
    local tick = main:GetTick()

    if (tick == self._effectTick) then
        local t = self._entity.transform
        local param = {
            x = t.x,
            y = t.y,
            z = t.z,
            direction = t.direction,
            entity = self._entity
        }

        self._effect = _FACTORY.New(self._actorDataSet[self._process], param)

        if(self._ascend and self._process == 2) then
            _SOUND.Play(self._soundDataSet.voice[self._process])
            _SOUND.Play(self._soundDataSet.effect[self._process])

            self._attack:Enter(self._attackDataSet[self._process], self._skill.attackValues[1], _, _, true)
            self._attack.collision[_ASPECT.GetPart(self._effect.aspect)] = "attack"
        end
    elseif (tick == self._easemoveTick) then
        local direction = self._entity.transform.direction
        local arrowDirection = _INPUT.GetArrowDirection(self._entity.input, direction)

        if (arrowDirection >= 0) then
            local easemoveParam = self._easemoveParams[arrowDirection + 1]
            self._easemove:Enter("x", easemoveParam.power, easemoveParam.speed, direction)
        end
    end

    if(self._ascend) then
        if (self._process == 1 and tick == self._effectTick + 2) then
            _BUFF.AddBuff(self._entity, self._comboBuffData)
            self._skill:Reset()
        elseif (self._process == 2) then
            if (tick == self._effectTick) then
                self._figureData = main:GetData()
            elseif (tick == self._effectTick + 1) then
                _EFFECT.NewFigure(self._entity.transform, self._entity.aspect, self._figureData)
            end
        end
    end

    self._attack:Update()

    _STATE.AutoPlayEnd(self._entity.states, self._entity.aspect, self._nextState)
end

function _UpperSlash:Enter(laterState, skill)
    local buff = self._comboBuffData and _BUFF.GetBuff(self._entity.buffs, self._comboBuffData.path)
    
    if (buff) then
        if (laterState ~= self) then
            _Base.Enter(self)
        else
            _MOTION.TurnDirection(self._entity.transform, self._entity.input)
        end

        self._process = 2
        _ASPECT.Play(self._entity.aspect, self._frameaniDataSets[2])
        buff:Exit()
    elseif (laterState ~= self) then
        _Base.Enter(self)
        
        self._process = 1
        self._easemove:Exit()
        self._skill = skill
    
        if (self._breaking) then
            self._attack:Enter(self._attackDataSet[self._process], self._skill.attackValues[1], _, _Collide)
        else
            self._attack:Enter(self._attackDataSet[self._process], self._skill.attackValues[1])
        end

        local kind = _EQUIPMENT.GetSubKind(self._entity.equipments, "weapon")
        table.insert(self._attack.soundDataSet, self._soundDataSet.hitting[kind])
    
        local hitstop = self._hitstopMap[kind]
        self._attack.hitstop = hitstop[1]
        self._attack.selfstop = hitstop[2]
        self._attack.shake.time = hitstop[1]
    
        _SOUND.Play(self._soundDataSet.voice[self._process])
        _SOUND.Play(self._soundDataSet.effect[self._process])
    
        self._buff = _BUFF.AddBuff(self._entity, self._buffDatas)

        if (self._comboBuffData) then
            self._comboBuffData.skill = self._skill
        end
    end
end

function _UpperSlash:Exit(nextState)
    if (nextState == self) then
        return
    end
    
    _Base.Exit(self, nextState)

    if (self._effect) then
        self._effect.identity.destroyProcess = 1
        self._effect = nil
    end

    if (self._buff) then
        self._buff:Exit()
    end
end

return _UpperSlash

