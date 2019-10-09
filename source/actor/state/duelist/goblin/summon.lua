--[[
	desc: Summon, a state of goblinChief.
	author: SkyFvcker
	since: 2018-9-6
	alter: 2019-8-9
]]--

local _SOUND = require("lib.sound")
local _DUELIST = require("actor.service.duelist")
local _EFFECT = require("actor.service.effect")
local _BUFF = require("actor.service.buff")

local _Base = require("actor.state.base")

---@class Actor.State.Duelist.Goblin.Summon:Actor.State
local _Summon = require("core.class")(_Base)

---@param skill Actor.Skill
function _Summon:Tick(lateState, skill)
    local target = skill:GetAITarget() or self._entity
    local x, y = target.transform.position:Get()

    _SOUND.Play(self._soundDataSet)
    self._buffDatas.skill = skill

    local entity = _DUELIST.Summon(self._entity, self._actorDataSet, x, y)
    local buff = _BUFF.AddBuff(entity, self._buffDatas)

    return true
end

return _Summon