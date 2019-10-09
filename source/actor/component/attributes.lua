--[[
	desc: Attributes, a component of attribute set.
	author: Musoucrow
	since: 2018-6-25
	alter: 2019-8-15
]]--

local _MATH = require("lib.math")

local function _GetValue(v)
    if (not v or type(v) ~= "table") then
        return v
    end

    return _MATH.GetRandomValue(v)
end

---@class Actor.Component.Attributes
---@field hp int
---@field maxHp int
---@field hpRecovery number
---@field mp int
---@field maxMp int
---@field phyAtk int
---@field magAtk int
---@field phyDef int
---@field magDef int
---@field criticalRate number
---@field moveRate number
---@field attackRate number
---@field stunRate number
---@field coolDownRate number
---@field phyAtkRate number
---@field magAtkRate number
---@field negativeHp int
---@field recoveryRate number
---@field origin table
---@field journal table<table, boolean>
local _Attributes = require("core.class")()

function _Attributes:Ctor(data)
    self.maxHp = _GetValue(data.maxHp) or 1
    self.hp = data.hp or self.maxHp
    self.hpRecovery = _GetValue(data.hpRecovery) or 0
    self.maxMp = _GetValue(data.maxMp) or 1
    self.mp = 0
    self.phyAtk = _GetValue(data.phyAtk) or 1
    self.magAtk = _GetValue(data.magAtk) or 1
    self.phyDef = _GetValue(data.phyDef) or 0
    self.magDef = _GetValue(data.magDef) or 0
    self.criticalRate = _GetValue(data.criticalRate) or 0
    self.moveRate = _GetValue(data.moveRate) or 1
    self.attackRate = _GetValue(data.attackRate) or 1
    self.stunRate = _GetValue(data.stunRate) or 1
    self.coolDownRate = _GetValue(data.coolDownRate) or 1
    self.phyAtkRate = _GetValue(data.phyAtkRate) or 1
    self.magAtkRate = _GetValue(data.magAtkRate) or 1
    self.negativeHp = data.negativeHp or 0
    self.recoveryRate = 0.5

    self.origin = {
        maxHp = self.maxHp,
        hpRecovery = self.hpRecovery,
        maxMp = self.maxMp,
        phyAtk = self.phyAtk,
        magAtk = self.magAtk,
        phyDef = self.phyDef,
        magDef = self.magDef,
        criticalRate = self.criticalRate,
        moveRate = self.moveRate,
        attackRate = self.attackRate,
        stunRate = self.stunRate,
        coolDownRate = self.coolDownRate,
        phyAtkRate = self.phyAtkRate,
        magAtkRate = self.magAtkRate,
        negativeHp = self.negativeHp
    }

    self.journal = {}
end

return _Attributes