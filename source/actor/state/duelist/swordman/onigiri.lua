--[[
	desc: Onigiri, a state of Swordman.
	author: Musoucrow
	since: 2018-5-10
	alter: 2019-5-11
]]--

local _SOUND = require("lib.sound")
local _FACTORY = require("actor.factory")
local _ASPECT = require("actor.service.aspect")
local _STATE = require("actor.service.state")

local _Attack = require("actor.gear.attack")
local _Base = require("actor.state.base")

---@class Actor.State.Duelist.Swordman.Onigiri:Actor.State
---@field protected _attack Actor.Gear.Attack
---@field protected _skill Actor.Skill
---@field protected _scale number
local _Onigiri = require("core.class")(_Base)

function _Onigiri:Ctor(data, ...)
    _Base.Ctor(self, data, ...)

    self._scale = data.scale or 1
end

function _Onigiri:Init(entity, ...)
    _Base.Init(self, entity, ...)

    self._attack = _Attack.New(self._entity)
end

function _Onigiri:NormalUpdate()
    local main = _ASPECT.GetPart(self._entity.aspect) ---@type Graphics.Drawable.Frameani

    self._attack:Update()

    if (main:GetTick() == 3) then
        local t = self._entity.transform
        local param = {
            x = t.position.x,
            y = t.position.y,
            z = t.position.z,
            direction = t.direction,
            entity = self._entity
        }

        local effect = _FACTORY.New(self._actorDataSet, param)
        effect.transform.scale:Set(self._scale, self._scale)
        effect.transform.scaleTick = true

        local n = math.random(1, #self._soundDataSet.voice)
        _SOUND.Play(self._soundDataSet.voice[n])
        _SOUND.Play(self._soundDataSet.effect)

        self._attack:Enter(self._attackDataSet, self._skill.attackValues[1], _, _, true)
        self._attack.collision[_ASPECT.GetPart(effect.aspect)] = "attack"
    end

    _STATE.AutoPlayEnd(self._entity.states, self._entity.aspect, self._nextState)
end

function _Onigiri:Enter(laterState, skill)
    _Base.Enter(self)

    self._skill = skill
end

function _Onigiri:Exit(nextState)
    _Base.Exit(self, nextState)

    self._attack:Exit()
end

return _Onigiri