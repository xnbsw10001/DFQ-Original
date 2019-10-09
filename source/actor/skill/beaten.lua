--[[
	desc: Beaten, a skill for beaten.
	author: Musoucrow
	since: 2018-8-5
	alter: 2019-4-21
]]--

local _STATE = require("actor.service.state")

local _Skill = require("actor.skill.base")

---@class Actor.Skill.Beaten:Actor.Skill
---@field public canFlight boolean
---@field public alsoNormal boolean
local _Beaten = require("core.class")(_Skill)

---@param entity Actor.Entity
---@param key string
---@param data Actor.RESMGR.SkillData
function _Beaten:Ctor(entity, key, data)
    _Skill.Ctor(self, entity, key, data)

    self.canStun = data.canStun == nil and true or data.canStun
    self.canFlight = data.canFlight or false
    self.canDown = data.canDown or false
    self.alsoNormal = data.alsoNormal or false
end

---@return boolean
function _Beaten:Cond()
    local stun = self.canStun and _STATE.HasTag(self._entity.states, "stun")
    local down = self.canDown and _STATE.HasTag(self._entity.states, "down")
    local flight = self.canFlight and _STATE.HasTag(self._entity.states, "damage") and self._entity.transform.position.z < 0
    local alsoNormal = self.alsoNormal and _Skill.Cond(self)

    return stun or down or flight or alsoNormal
end

---@return boolean
function _Beaten:IsActive()
    return self:Cond()
end

return _Beaten