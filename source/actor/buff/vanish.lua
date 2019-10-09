--[[
	desc: Vanish, A buff of vanish.
	author: Musoucrow
    since: 2018-9-30
    alter: 2019-1-24
]]--

local _Base = require("actor.buff.base")

---@class Actor.Buff.Vanish : Actor.Buff
local _Vanish = require("core.class")(_Base)

function _Vanish:Exit()
    if (_Base.Exit(self)) then
        self._entity.battle.deadProcess = 1

        return true
    end

    return false
end

return _Vanish