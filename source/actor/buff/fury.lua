--[[
	desc: Fury, A buff.
	author: SkyFvcker
	since: 2018-9-18
	alter: 2019-3-31
]]--

local _ATTRIBUTE = require("actor.service.attribute")
local _SOUND = require("lib.sound")
local _RESMGR = require("actor.resmgr")

local _Color = require("graphics.drawunit.color")
local _Tweener = require("util.gear.tweener")
local _Base = require("actor.buff.base")

---@class Actor.Buff.Fury : Actor.Buff
---@field protected _colorTime int
---@field protected _colorTweener Util.Gear.MockTweener
---@field protected _color Graphics.Drawunit.Color
---@field protected _soundData SoundData
---@field protected _rate number
local _Fury = require("core.class")(_Base)

function _Fury.HandleData(data)
    data.soundData = _RESMGR.GetSoundData(data.sound)
end

---@param entity Actor.Entity
---@param data Actor.RESMGR.BuffData
---@return boolean
function _Fury.CanNew(entity, data)
    return _Base.CanNew(entity, data) and entity.ais
end

function _Fury:Ctor(entity, data)
    _Base.Ctor(self, entity, data)
    
    self._colorTime = data.colorTime
    self._soundData = data.soundData
    self._color = _Color.New(data.color.red, data.color.green, data.color.blue, data.color.alpha)
    self._colorTweener = _Tweener.New(entity.aspect.pureColor)
    self._colorTweener:Enter(self._colorTime, self._color)
    self._rate = data.value or 1

    local useSkill = entity.ais and entity.ais.container:Get("useSkill") ---@type Actor.Ai.UseSkill
    local searchMove = entity.ais and entity.ais.container:Get("searchMove") ---@type Actor.Ai.SearchMove

    if (useSkill) then
        useSkill.coolDownTimeSection.x = math.floor(useSkill.coolDownTimeSection.x * self._rate)
        useSkill.coolDownTimeSection.y = math.floor(useSkill.coolDownTimeSection.y * self._rate)
        useSkill.judgeTimeSection.x = math.floor(useSkill.judgeTimeSection.x * self._rate)
        useSkill.judgeTimeSection.y = math.floor(useSkill.judgeTimeSection.y * self._rate)
    end

    if (searchMove) then
        searchMove.intervalSection.x = math.floor(searchMove.intervalSection.x * self._rate)
        searchMove.intervalSection.y = math.floor(searchMove.intervalSection.y * self._rate)
    end

    _SOUND.Play(self._soundData)
end

function _Fury:OnUpdate(dt)
    if (not self._entity.identity.isPaused) then
        self._colorTweener:Update(dt)

        if (not self._colorTweener.isRunning) then
            self._colorTweener:Enter(self._colorTime, self._color)
        end
    elseif (self._colorTweener.isRunning) then
        self._colorTweener:Exit()
    end
end

function _Fury:Exit()
    if (_Base.Exit(self)) then
        local useSkill = self._entity.ais and self._entity.ais.container:Get("useSkill") ---@type Actor.Ai.UseSkill
        local searchMove = self._entity.ais and self._entity.ais.container:Get("searchMove") ---@type Actor.Ai.SearchMove
    
        if (useSkill) then
            useSkill.coolDownTimeSection.x = math.floor(useSkill.coolDownTimeSection.x / self._rate)
            useSkill.coolDownTimeSection.y = math.floor(useSkill.coolDownTimeSection.y / self._rate)
            useSkill.judgeTimeSection.x = math.floor(useSkill.judgeTimeSection.x / self._rate)
            useSkill.judgeTimeSection.y = math.floor(useSkill.judgeTimeSection.y / self._rate)
        end
    
        if (searchMove) then
            searchMove.intervalSection.x = math.floor(searchMove.intervalSection.x / self._rate)
            searchMove.intervalSection.y = math.floor(searchMove.intervalSection.y / self._rate)
        end
    end
end

return _Fury