--[[
	desc: Heal, a buff of Heal.
	author: Musoucrow
	since: 2019-5-30
]]--

local _ATTRIBUTE = require("actor.service.attribute")
local _DUELIST = require("actor.service.duelist")

local _Base = require("actor.buff.base")

---@class Actor.Buff.Heal : Actor.Buff
---@field value int
local _Heal = require("core.class")(_Base)

function _Heal:Ctor(entity, data)
	_Base.Ctor(self, entity, data)
	
	self.value = data.value
end

function _Heal:Exit()
	if (_Base.Exit(self)) then
		local list = _DUELIST.GetList()
		
		for n=1, list:GetLength() do
			local e = list:Get(n) ---@type Actor.Entity
			
			if (e ~= self._entity and e.battle.camp == self._entity.battle.camp) then
				_ATTRIBUTE.AddHpWithEffect(e, self.value)
			end
		end

        return true
    end

    return false
end

return _Heal