--[[
	desc: Invincibility, A buff of invincibility.
	author: Musoucrow
	since: 2018-8-8
]]--

local _Stroke = require("actor.buff.stroke")

---@class Actor.Buff.Invincibility : Actor.Buff.Stroke
local _Invincibility = require("core.class")(_Stroke)

---@param entity Actor.Entity
function _Invincibility:Ctor(entity, data)
    _Stroke.Ctor(self, entity, data)

    local battle = entity.battle
    battle.banCountMap.attack = battle.banCountMap.attack + 1
end

function _Invincibility:Exit()
    if (_Stroke.Exit(self)) then
        local battle = self._entity.battle
        battle.banCountMap.attack = battle.banCountMap.attack - 1

        return true
    end

    return false
end

return _Invincibility