--[[
	desc: SKILL, a service for skill.
	author: Musoucrow
	since: 2018-7-2
	alter: 2019-9-16
]]--

local _RESMGR = require("actor.resmgr")

---@class Actor.Service.SKILL
local _SKILL = {}

local _keys = {"normalAttack", "skill1", "skill2", "skill3", "skill4", "skill5", "skill6"}

---@param entity Actor.Entity
---@param key string
---@param data Actor.RESMGR.SkillData
function _SKILL.Set(entity, key, data)
    local skill = entity.skills.container:Get(key) ---@type Actor.Skill

    if (skill) then
        skill:Exit()
    end

    if (not data) then
        entity.skills.container:Del(key)
    else
        local eskill = data.class.New(entity, key, data) ---@type Actor.Skill
        entity.skills.container:Add(eskill, key)
    end

    entity.skills.caller:Call(key)
end

---@param entity Actor.Entity
---@param data Actor.RESMGR.SkillData
---@return string
function _SKILL.Add(entity, data)
    local key

    for n=1, #_keys do
        local skill = entity.skills.container:Get(_keys[n]) ---@type Actor.Skill
        
        if (skill) then
            local sdata = skill:GetData()

            if (sdata == data) then
                return "same"
            elseif (sdata.origin == data.origin) then
                return "origin"
            end
        elseif (not skill and not key) then
            key = _keys[n]
        end
    end

    if (key) then
        _SKILL.Set(entity, key, data)

        return key
    end
end

---@param skills Actor.Component.Skills
---@param path string
---@return Actor.Skill
function _SKILL.GetSkillWithPath(skills, path)
    for n=1, skills.container:GetLength() do
        local skill = skills.container:GetWithIndex(n)
        local data = skill:GetData() ---@type Actor.RESMGR.SkillData

        if (data.path == path) then
            return skill
        end
    end
end

---@param skills Actor.Component.Skills
---@param path string
---@return Actor.Skill
function _SKILL.GetSkillWithOrigin(skills, path)
    for n=1, skills.container:GetLength() do
        local skill = skills.container:GetWithIndex(n)
        local data = skill:GetData() ---@type Actor.RESMGR.SkillData

        if (data.origin == path) then
            return skill
        end
    end
end

return _SKILL