--[[
	desc: Rush, A buff of rush.
	author: Musoucrow
    since: 2019-5-21
]]--

local _INPUT = require("actor.service.input")

local _Timer = require("util.gear.timer")
local _Base = require("actor.buff.base")

---@class Actor.Buff.Rush : Actor.Buff
---@field public key string
---@field public noCooldown boolean
---@field protected _useTimer Util.Gear.Timer
local _Rush = require("core.class")(_Base)

function _Rush:Ctor(entity, data)
    _Base.Ctor(self, entity, data)

    self.key = data.key
    self.noCooldown = data.noCooldown or false
    self._useTimer = _Timer.New(data.interval)
end

function _Rush:OnUpdate(dt)
    self._useTimer:Update(dt)

    if (not self._useTimer.isRunning) then
        _INPUT.Press(self._entity.input, self.key)
        self._useTimer:Enter()
    end

    if (self.noCooldown) then
        local skill = self._entity.skills.container:Get(self.key) ---@type Actor.Skill

        if (skill:InCoolDown()) then
            skill:SetNowTime(skill.time) -- Exit cooldown.
        end
    end
end

return _Rush