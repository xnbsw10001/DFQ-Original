--[[
	desc: Combo, A module of combo buff.
	author: Musoucrow
	since: 2019-1-15
]]--

local _Base = require("actor.buff.base")

---@class Actor.Buff.Combo : Actor.Buff
---@field protected _skill Actor.Skill
local _Combo = require("core.class")(_Base)

function _Combo:Ctor(entity, data)
    _Base.Ctor(self, entity, data)

    self._skill = data.skill
    self._skill:Reset()
end

function _Combo:Exit()
    if (_Base.Exit(self)) then
        self._skill:CoolDown()
    end
end

return _Combo