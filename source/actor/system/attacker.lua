--[[
	desc: Attacker, a system for attacker.
	author: Musoucrow
	since: 2018-5-9
	alter: 2019-8-9
]]--

local _Base = require("actor.system.base")

---@class Actor.System.Attacker : Actor.System
local _Attacker = require("core.class")(_Base)

function _Attacker:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        attacker = true,
        identity = true
    }, "attacker")
end

function _Attacker:Update(dt)
    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity
        local timer = e.attacker.hitstopTimer

        if (timer.isRunning) then
            timer:Update(dt * e.identity.rate)

            if (not timer.isRunning) then
                e.identity.isPaused = false
                e.attacker.enable = true
            end
        end
    end
end

return _Attacker