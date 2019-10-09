--[[
	desc: Skills, a system of skill management.
	author: Musoucrow
	since: 2018-5-9
	alter: 2019-8-30
]]--

local _SKILL = require("actor.service.skill")

local _Base = require("actor.system.base")

---@class Actor.System.Skills : Actor.System
local _Skills = require("core.class")(_Base)

---@param a Actor.Skill
---@param b Actor.Skill
---@return boolean
local function _SkillSorting(a, b)
    return a.order > b.order
end

function _Skills:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        skills = true
    }, "skills")
end

---@param entity Actor.Entity
function _Skills:OnEnter(entity)
    local skills = entity.skills

    for k, v in pairs(skills.data) do
        if (k ~= "class" and type(v) == "table") then
            _SKILL.Set(entity, k, v)
        end
    end

    skills.data = nil
    skills.container:Sort(_SkillSorting)
end

function _Skills:Update(dt)
    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity
        e.skills.container:RunEvent_All("Update", dt * e.identity.rate)
    end
end

return _Skills