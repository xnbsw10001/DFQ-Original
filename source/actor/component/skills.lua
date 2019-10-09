--[[
	desc: Skills, a component of skill set.
	author: Musoucrow
	since: 2018-5-9
	alter: 2018-12-12
]]--

local _RESMGR = require("actor.resmgr")
local _SKILL = require("actor.service.skill")

local _Caller = require("core.caller")
local _Container = require("core.container")

---@class Actor.Component.Skills
---@field public container Core.Container
---@field public caller Core.Caller
---@field public defaultMap table<string, Actor.RESMGR.SkillData>
local _Skills = require("core.class")()

function _Skills.HandleData(data)
    for k, v in pairs(data) do
        if (k ~= "class" and type(v) ~= "boolean") then
            data[k] = _RESMGR.GetSkillData(v)
        end
    end
end

function _Skills:Ctor(data)
    self.container = _Container.New()
    self.caller = _Caller.New()
    self.data = data
end

return _Skills