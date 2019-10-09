--[[
	desc: Illusion, a state of Duelist.
	author: Musoucrow
	since: 2019-6-16
]]--

local _ECSMGR = require("actor.ecsmgr")
local _FACTORY = require("actor.factory")
local _STATE = require("actor.service.state")
local _ASPECT = require("actor.service.aspect")
local _EFFECT = require("actor.service.effect")

local _Base = require("actor.state.base")

---@class Actor.State.Duelist.Illusion:Actor.State
local _Illusion = require("core.class")(_Base)

---@param skill Actor.Skill
function _Illusion:Tick(lateState, skill)
    local t = self._entity.transform
    local param = {
        x = t.position.x,
        y = t.position.y,
        z = t.position.z,
        direction = t.direction,
        entity = self._entity,
        skill = skill
    }

    _FACTORY.New(self._actorDataSet, param)

    return true
end

return _Illusion