--[[
	desc: Boss, A buff for boss.
	author: Musoucrow
    since: 2019-9-4
]]--

local _ATTRIBUTE = require("actor.service.attribute")

local _Base = require("actor.buff.base")

---@class Actor.Buff.Boss : Actor.Buff
---@field protected _marks table
---@field public def int
---@field public rate number
local _Boss = require("core.class")(_Base)

function _Boss:Ctor(entity, data)
    _Base.Ctor(self, entity, data)

    self.def = data.def
    self.rate = data.rate

    self._marks = {}
    self._entity.battle.beatenCaller:AddListener(self, self.Adjust)
    self:Adjust()
end

function _Boss:Exit()
    if (_Base.Exit(self)) then
        for n=1, #self._marks do
            _ATTRIBUTE.Del(self._entity.attributes, self._marks[n])
        end

        self._entity.battle.beatenCaller:DelListener(self, self.Adjust)
    end
end

function _Boss:Adjust()
    local attributes = self._entity.attributes

    for n=1, #self._marks do
        _ATTRIBUTE.Del(attributes, self._marks[n])
    end
    
    local rate = (1 - attributes.hp / attributes.maxHp)
    local def = math.floor(self.def * rate)
    local speedRate = self.rate * rate

    self._marks[1] = _ATTRIBUTE.Add(attributes, "+", "phyDef", def)
    self._marks[2] = _ATTRIBUTE.Add(attributes, "+", "magDef", def)
    self._marks[3] = _ATTRIBUTE.Add(attributes, "+", "attackRate", speedRate)
    self._marks[4] = _ATTRIBUTE.Add(attributes, "+", "moveRate", speedRate)
end

return _Boss