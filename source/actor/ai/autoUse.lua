--[[
	desc: AutoUse, a Ai of auto use action.
	author: Musoucrow
	since: 2018-9-6
]]--

local _INPUT = require("actor.service.input")

local _Base = require("actor.ai.base")

---@class Actor.Ai.AutoUse : Actor.Ai
---@field public skill Actor.Skill
local _AutoUse = require("core.class")(_Base)

---@param entity Actor.Entity
function _AutoUse.NewWithConfig(entity, data, skill)
    return _AutoUse.New(entity, skill)
end

---@param entity Actor.Entity
---@param skill Actor.Skill
function _AutoUse:Ctor(entity, skill)
    _Base.Ctor(self, entity)

    self.skill = skill
end

function _AutoUse:Tick()
    if (not self:CanRun()) then
        return false
    end

    if (self.skill:CanUse()) then
        _INPUT.Press(self._entity.input, self.skill:GetKey())
    end

    return false
end

return _AutoUse