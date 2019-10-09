--[[
	desc: Selfbomb, a state of selfbomb for Goblin.
	author: Musoucrow
	since: 2018-9-17
	alter: 2019-8-9
]]--

local _FACTORY = require("actor.factory")

local _Base = require("actor.state.base")

---@class Actor.State.Duelist.Goblin.Selfbomb:Actor.State
local _Selfbomb = require("core.class")(_Base)

---@param skill Actor.Skill
function _Selfbomb:Tick(lateState, skill)
    _FACTORY.New(self._actorDataSet, {
        entity = self._entity,
        attackValue = skill.attackValues[1]
    })

    self._entity.attributes.hp = 0
    self._entity.battle.deadProcess = 1

    return true
end

return _Selfbomb