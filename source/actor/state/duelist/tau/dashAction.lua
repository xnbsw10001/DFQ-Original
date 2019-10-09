--[[
	desc: DashAction, a state of base dash for Tau.
	author: Musoucrow
	since: 2018-9-20
]]--

local _SOUND = require("lib.sound")
local _ASPECT = require("actor.service.aspect")

local _Base = require("actor.state.base")

---@class Actor.State.Duelist.Tau.DashAction:Actor.State
---@field protected _skill Actor.Skill
---@field protected _stopTime milli
---@field protected _process int
local _DashAction = require("core.class")(_Base)

function _DashAction:Ctor(data, ...)
    _Base.Ctor(self, data, ...)

    self._stopTime = data.stopTime
end

function _DashAction:NormalUpdate(dt, rate)
    local main = _ASPECT.GetPart(self._entity.aspect) ---@type Graphics.Drawable.Frameani

    if (self._process == 1) then
        local tick = main:GetTick()
        local length = main:GetLength()

        if (self._stopTime and tick == length - 1) then
            main:SetTime(self._stopTime)
        elseif (tick == length) then
            self:OnKeyTick()
            self._process = 2
            _ASPECT.Play(self._entity.aspect, self._frameaniDataSets[self._process])
            _SOUND.Play(self._soundDataSet.voice)
            _SOUND.Play(self._soundDataSet.effect)
        end
    end
end

function _DashAction:Enter(laterState, skill)
    _Base.Enter(self, laterState)

    self._skill = skill
    self._process = 1

    _ASPECT.Play(self._entity.aspect, self._frameaniDataSets[self._process])
end

function _DashAction:OnKeyTick()
end

return _DashAction