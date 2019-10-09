--[[
	desc: UseSkill, a Ai of using skill.
	author: Musoucrow
	since: 2018-5-14
	alter: 2019-7-6
]]--

local _RESMGR = require("actor.resmgr")
local _FACTORY = require("actor.factory")
local _STATE = require("actor.service.state")
local _INPUT = require("actor.service.input")

local _Timer = require("util.gear.timer")
local _Point = require("graphics.drawunit.point")
local _Base = require("actor.ai.base")

---@class Actor.Ai.UseSkill : Actor.Ai
---@field protected _timer Util.Gear.Timer
---@field protected _action Actor.Skill
---@field public judgeTimeSection Graphics.Drawunit.Point
---@field public coolDownTimeSection Graphics.Drawunit.Point
---@field public readyTimeSection Graphics.Drawunit.Point
---@field public immediately boolean
local _UseSkill = require("core.class")(_Base)

local _warningData = _RESMGR.GetInstanceData("effect/warning")

---@param container Core.Container
---@return Actor.Skill
local function _SkillTick(container)
    if (not container) then
        return
    end

    for n=1, container:GetLength() do
        local skill = container:GetWithIndex(n) ---@type Actor.Skill
        
        if (skill:AITick(true)) then
            return skill
        end
    end
end

---@param container Core.Container
---@return Actor.Skill
local function _SuptoolTick(container)
    if (not container) then
        return
    end

    local a = container:Get("suptool1") ---@type Actor.Skill
    local b = container:Get("suptool2") ---@type Actor.Skill

    if (a and a:AITick(true)) then
        return a
    elseif (b and b:AITick(true)) then
        return b
    end
end

---@param entity Actor.Entity
function _UseSkill.NewWithConfig(entity, data)
    return _UseSkill.New(entity, data.judgeTime, data.coolDownTime, data.readyTime)
end

---@param entity Actor.Entity
---@param judgeTimeSection Graphics.Drawunit.Point
---@param coolDownTimeSection Graphics.Drawunit.Point
---@param readyTimeSection Graphics.Drawunit.Point
function _UseSkill:Ctor(entity, judgeTimeSection, coolDownTimeSection, readyTimeSection)
    _Base.Ctor(self, entity)

    self.judgeTimeSection = _Point.New(true, judgeTimeSection.x, judgeTimeSection.y)
    self.coolDownTimeSection = _Point.New(true, coolDownTimeSection.x, coolDownTimeSection.y)
    self.readyTimeSection = readyTimeSection and _Point.New(true, readyTimeSection.x, readyTimeSection.y) or _Point.New(true)
    self._timer = _Timer.New()
end

function _UseSkill:Update(dt)
    if (not self:CanRun()) then
        return
    end

    self._timer:Update(dt)

    if (not self._timer.isRunning) then
        if (self._action) then
            _INPUT.Press(self._entity.input, self._action:GetKey())

            local section = self.coolDownTimeSection
            self._timer:Enter(math.random(section.x, section.y))
            self._action = nil

            return true
        else
            local a = self._entity.skills and self._entity.skills.container or nil
            local b = self._entity.equipments and self._entity.equipments.container or nil
            self._action = _SkillTick(a) or _SuptoolTick(b)
            

            if (not self.immediately) then
                local section = self._action and self.readyTimeSection or self.judgeTimeSection
                self._timer:Enter(math.random(section.x, section.y))
            else
                self.immediately = false
                self._timer:Exit()
            end

            if (self._action and self._timer.to > 0) then
                _FACTORY.New(_warningData, {entity = self._entity})
            end
        end
    end
end

function _UseSkill:Tick()
    self._action = nil
    self._timer:Exit()
    self.immediately = true
end

return _UseSkill