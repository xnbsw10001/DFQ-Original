--[[
	desc: Jumonji, a state of Swordman.
	author: Musoucrow
	since: 2018-6-15
]]--

local _SOUND = require("lib.sound")
local _FACTORY = require("actor.factory")
local _ASPECT = require("actor.service.aspect")
local _STATE = require("actor.service.state")

local _Attack = require("actor.gear.attack")
local _Easemove = require("actor.gear.easemove")
local _Base = require("actor.state.base")

---@class Actor.State.Duelist.Swordman.Jumonji:Actor.State
---@field protected _attack Actor.Gear.Attack
---@field protected _skill Actor.Skill
---@field protected _ticks table
---@field protected _effect Actor.Entity
local _Jumonji = require("core.class")(_Base)

function _Jumonji:Ctor(data, ...)
    _Base.Ctor(self, data, ...)

    self._ticks = data.ticks
    self._easemoveParam = data.easemove
end

function _Jumonji:Init(entity, ...)
    _Base.Init(self, entity, ...)

    self._attack = _Attack.New(self._entity)
    self._easemove = _Easemove.New(self._entity.transform, self._entity.aspect)

    ---@param effect Actor.Entity
    self._NewBullet = function(effect)
        local t = effect.transform
        local param = {
            x = t.position.x,
            y = t.position.y,
            z = t.position.z,
            direction = t.direction,
            entity = self._entity,
            attackValue = self._skill.attackValues[2]
        }

        _FACTORY.New(self._actorDataSet[2], param)
        _FACTORY.New(self._actorDataSet[3], param)
    end
end

function _Jumonji:NormalUpdate(dt, rate)
    local main = _ASPECT.GetPart(self._entity.aspect) ---@type Graphics.Drawable.Frameani
    local tick = main:GetTick()

    self._attack:Update()
    self._easemove:Update(rate)

    if (tick == self._ticks[1]) then
        self._effect = _FACTORY.New(self._actorDataSet[1], {entity = self._entity})
        self._attack:Enter(self._attackDataSet[1], self._skill.attackValues[1], _, _, true)
        self._attack.collision[_ASPECT.GetPart(self._effect.aspect)] = "attack"

        _SOUND.Play(self._soundDataSet.swing)
    elseif (tick == self._ticks[2]) then
        local param = self._easemoveParam
        self._easemove:Enter("x", param.power, param.speed, self._entity.transform.direction)

        self._effect.effect.lockDirection = false
        self._effect.effect.positionType = nil

        self._attack:Enter(self._attackDataSet[2], self._skill.attackValues[1], _, _, true)
        self._attack.collision[_ASPECT.GetPart(self._effect.aspect)] = "attack"

        _SOUND.Play(self._soundDataSet.swing)
    elseif (tick == self._ticks[3]) then
        self._effect.effect.state = nil
        self._effect.effect.lockStop = false
        self._effect.identity.destroyCaller:AddListener(self._effect, self._NewBullet)
        self._effect = nil
    end

    _STATE.AutoPlayEnd(self._entity.states, self._entity.aspect, self._nextState)
end

function _Jumonji:Enter(laterState, skill)
    _Base.Enter(self)

    self._skill = skill
    self._attack:Exit()
    self._easemove:Exit()

    _SOUND.Play(self._soundDataSet.voice)
end

return _Jumonji