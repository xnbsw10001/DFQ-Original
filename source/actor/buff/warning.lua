--[[
	desc: Warning, A buff.
	author: Musoucrow
	since: 2019-7-8
]]--

local _FACTORY = require("actor.factory")
local _RESMGR = require("actor.resmgr")
local _SOUND = require("lib.sound")
local _STATE = require("actor.service.state")

local _Color = require("graphics.drawunit.color")
local _Tweener = require("util.gear.tweener")
local _Base = require("actor.buff.base")

---@class Actor.Buff.Warning : Actor.Buff
---@field protected _colorTweener Util.Gear.MockTweener
---@field protected _state string
---@field protected _skill Actor.Skill
local _Warning = require("core.class")(_Base)

---@param data Actor.RESMGR.BuffData
function _Warning.HandleData(data)
    data.sound = _RESMGR.GetSoundData(data.sound)
end

function _Warning:Ctor(entity, data)
    _Base.Ctor(self, entity, data)

    self._colorTweener = _Tweener.New(entity.aspect.pureColor)
    self._colorTweener:Enter(math.floor(data.time * 0.1), _Color.New(data.color.red, data.color.green, data.color.blue, data.color.alpha))

    _SOUND.Play(data.sound)
    self._state = data.state
    self._skill = data.skill
end

function _Warning:OnUpdate(dt)
    self._colorTweener:Update(dt)

    if (not self._colorTweener.isRunning) then
        local target = self._colorTweener:GetTarget()
        target.alpha = target.alpha == 0 and 255 or 0

        local time = self._timer.to - self._timer.from
        self._colorTweener:Enter(math.floor(time * 0.1))
    end
end

function _Warning:Exit()
    if (_Base.Exit(self)) then
        _STATE.Play(self._entity.states, self._state, false, self._skill)
        self._entity.aspect.pureColor.alpha = 0

        return true
    end

    return false
end

return _Warning