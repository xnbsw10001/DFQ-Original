--[[
	desc: Move, a state of Swordman.
	author: Musoucrow
    since: 2019-6-11
    alter: 2019-9-19
]]--

local _MATH = require("lib.math")
local _SOUND = require("lib.sound")
local _WORLD = require("actor.world")
local _FACTORY = require("actor.factory")
local _BUFF = require("actor.service.buff")
local _ATTRIBUTE = require("actor.service.attribute")

local _Base = require("actor.state.duelist.move")

---@class Actor.State.Duelist.Swordman.Move:Actor.State.Duelist.Move
---@field protected _mpRecovery int
---@field protected _rateRange table
local _Move = require("core.class")(_Base)

function _Move:Ctor(data, ...)
    _Base.Ctor(self, data, ...)

    self._mpRecovery = data.mpRecovery
    self._rateRange = data.rateRange
    self._hasFull = false
end

function _Move:NormalUpdate(dt, rate)
    _ATTRIBUTE.AddMp(self._entity.attributes, self._mpRecovery * self._entity.attributes.moveRate)
    
    local rate2 = _MATH.Lerp(self._rateRange[1], self._rateRange[2], self._entity.attributes.mp / self._entity.attributes.maxMp)
    
    if (not self._hasFull and rate2 == self._rateRange[2]) then
        _SOUND.Play(self._soundDataSet[2])
        _BUFF.AddBuff(self._entity, self._buffDatas)
        self._hasFull = true
    end
    
    _Base.NormalUpdate(self, dt, rate * rate2)
end

function _Move:Exit()
    _Base.Exit(self)

    self._entity.attributes.mp = 0
    self._hasFull = false
end

return _Move