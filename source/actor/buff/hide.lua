--[[
	desc: Hide, A module of hide buff.
	author: SkyFvcker
    since: 2018-11-10
    alter: 2019-4-10
]]--

local _SOUND = require("lib.sound")
local _RESMGR = require("actor.resmgr")
local _ASPECT = require("actor.service.aspect")
local _STATE = require("actor.service.state")

local _Color = require("graphics.drawunit.color")
local _Base = require("actor.buff.base")

---@class Actor.Buff.Hide : Actor.Buff
---@field protected _alpha table
---@field protected _color Graphics.Drawunit.Color
---@field protected _colorTweener Util.Gear.MockTweener
---@field protected _colorSwitch boolean
---@field protected _Call function
---@field protected _process int
local _Hide = require("core.class")(_Base)

function _Hide.HandleData(data)
    data.sound = _RESMGR.GetSoundData(data.sound)
end

function _Hide:Ctor(entity, data)
    _Base.Ctor(self, entity, data)

    self._alpha = data.alpha
    self._process = 2
    self._colorSwitch = false
    self._color = _Color.New(entity.aspect.color:Get())
    self._color.alpha = self._alpha[1]

    self._colorTweener = _ASPECT.NewColorTweener(entity.aspect)
    self._colorTweener:SetTarget(self._color)
    self._colorTweener:Enter(data.interval)

    self._entity.battle.banCountMap.hide = self._entity.battle.banCountMap.hide + 1

    _SOUND.Play(data.sound)
end

function _Hide:OnUpdate(dt)
    self._colorTweener:Update(dt)

    if (self._process < 4 and self._timer:GetProcess() > 0.9) then
        self._color.alpha = self._alpha[4]
        self._colorTweener:Enter(self._timer.to - self._timer.from)
        self._process = 4
    elseif (self._process ~= 1 and _STATE.HasTag(self._entity.states, "stay")) then
        self._color.alpha = self._alpha[3]
        self._colorTweener:Enter()
        self._process = 1
    elseif (self._process ~= 3 and not _STATE.HasTag(self._entity.states, "free")) then
        self._color.alpha = self._alpha[4]
        self._colorTweener:Enter()
        self._process = 3
    elseif (self._process ~= 2 and _STATE.HasTag(self._entity.states, "free")) then
        self._process = 2
    elseif (self._process == 2 and not self._colorTweener.isRunning) then
        local index = self._colorSwitch and 1 or 2
        self._color.alpha = self._alpha[index]
        self._colorSwitch = not self._colorSwitch
        self._colorTweener:Enter()
    end
end

function _Hide:Exit()
    if (_Base.Exit(self)) then
        self._entity.aspect.color.alpha = 255
        self._entity.aspect.colorTick = true

        self._entity.battle.banCountMap.hide = self._entity.battle.banCountMap.hide - 1
    end
end

return _Hide