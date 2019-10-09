--[[
	desc: State, A business's place.
	author: Musoucrow
	since: 2018-6-22
	alter: 2019-7-8
]]--

local _STRING = require("lib.string")
local _RESOURCE = require("lib.resource")
local _RESMGR = require("actor.resmgr")
local _ASPECT = require("actor.service.aspect")
local _DUELIST = require("actor.service.duelist")
local _STATE = require("actor.service.state")
local _EFFECT = require("actor.service.effect")
local _MOTION = require("actor.service.motion")

---@class Actor.State:Core.Gear
---@field protected _entity Actor.Entity
---@field protected _name string
---@field protected _tagMap table<string, boolean>
---@field protected _frameaniPathSet table
---@field protected _attackDataSet table
---@field protected _soundDataSet table
---@field protected _actorDataSet table
---@field protected _colliderDataSet table
---@field protected _frameaniDataSets table
---@field protected _buffDatas table<int, Actor.RESMGR.BuffData>
---@field protected _talkSet table
---@field protected _nextState string
local _State = require("core.class")()

function _State.HandleData(data)
    if (data.sound) then
        data.soundDataSet = _RESOURCE.Recur(_RESMGR.GetSoundData, data.sound)
        data.sound = nil
    end

    if (data.attack) then
        data.attackDataSet = _RESOURCE.Recur(_RESMGR.GetAttackData, data.attack, "effect")
        data.attack = nil
    end

    if (data.actor) then
        data.actorDataSet = _RESOURCE.Recur(_RESMGR.GetInstanceData, data.actor, "aspect")
        data.actor = nil
    end

    if (data.collider) then
        data.colliderDataSet = _RESOURCE.Recur(_RESMGR.GetColliderData, data.collider, "x")
        data.collider = nil
    end

    if (data.talk) then
        if (data.talk.cn) then
            data.talk = _STRING.GetVersion(data.talk)
        else
            data.talk = _RESOURCE.Recur(_STRING.GetVersion, data.talk, "cn")
        end
    end

    if (data.buff) then
        if (#data.buff == 0) then
            data.buff = _RESMGR.NewBuffData(data.buff.path, data.buff)
        else
            for n=1, #data.buff do
                data.buff[n] = _RESMGR.NewBuffData(data.buff[n].path, data.buff[n])
            end
        end
    end

    data.frameaniPathSet = data.frameaniPath
    data.frameani = nil
    --data.tagMap = data.tagMap or {}
end

---@param entity Actor.Entity
---@param name string
---@param data Actor.RESMGR.StateData
function _State:Ctor(data, param, name)
    self._tagMap = data.tagMap
    self._name = name
    self._frameaniPathSet = data.frameaniPathSet
    self._soundDataSet = data.soundDataSet
    self._attackDataSet = data.attackDataSet
    self._actorDataSet = data.actorDataSet
    self._colliderDataSet = data.colliderDataSet
    self._buffDatas = data.buff
    self._talkSet = data.talk
    self._nextState = data.nextState
end

function _State:Init(entity)
    self._entity = entity
    self:InitFrameaniDataSets()
end

function _State:Update(dt, rate)
    if (not self._entity.identity.isPaused) then
        self:NormalUpdate(dt, rate)
    end
end

function _State:NormalUpdate(dt, rate)
    if (self:HasTag("autoEnd")) then
        _STATE.AutoPlayEnd(self._entity.states, self._entity.aspect, self._nextState)
    end
end

---@param playFrameani boolean
function _State:Enter()
    if (self:HasTag("autoPlay")) then
        local data = #self._frameaniDataSets > 0 and self._frameaniDataSets[1] or self._frameaniDataSets
        _ASPECT.Play(self._entity.aspect, data)
    end

    if (self:HasTag("attackRate")) then
        self._entity.aspect.rate = self._entity.attributes.attackRate
    end
end

function _State:Exit(nextState)
    if (self:HasTag("attackRate")) then
        self._entity.aspect.rate = 1
    end

    if (nextState and self:HasTag("attack") and nextState:HasTag("attack")) then
        local data = _ASPECT.GetPart(self._entity.aspect):GetData()

        if (data) then
            _EFFECT.NewFigure(self._entity.transform, self._entity.aspect, data)
        end

        if (not nextState:HasTag("lock")) then
            _MOTION.TurnDirection(self._entity.transform, self._entity.input)
        end
    end
end

---@param tag string
---@return boolean
function _State:HasTag(tag)
    return self._tagMap[tag] == true
end

---@return string
function _State:GetName()
    return self._name
end

function _State:InitFrameaniDataSets()
    if (self._frameaniPathSet == nil) then
        return
    end
    
    local aspect = self._entity.aspect
    self._frameaniDataSets = self._frameaniDataSets or {}

    if (type(self._frameaniPathSet) == "string") then
        _ASPECT.StuffFrameaniDataSet(aspect, self._frameaniPathSet, self._frameaniDataSets)
    else
        for k, v in pairs(self._frameaniPathSet) do
            self._frameaniDataSets[k] = self._frameaniDataSets[k] or {}
            _ASPECT.StuffFrameaniDataSet(aspect, v, self._frameaniDataSets[k])
        end
    end
end

return _State