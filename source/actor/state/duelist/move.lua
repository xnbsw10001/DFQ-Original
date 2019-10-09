--[[
	desc: Move, a state of Duelist.
	author: Musoucrow
	since: 2018-8-19
	alter: 2019-6-12
]]--

local _SOUND = require("lib.sound")
local _CONFIG = require("config")
local _STATE = require("actor.service.state")
local _ASPECT = require("actor.service.aspect")

local _ControlMove = require("actor.controlMove")
local _Point = require("graphics.drawunit.point")
local _Base = require("actor.state.base")

---@class Actor.State.Duelist.Move:Actor.State
---@field protected _controlMove Actor.ControlMove
---@field protected _soundFrameMap table
local _Move = require("core.class")(_Base)

function _Move:Ctor(data, ...)
    _Base.Ctor(self, data, ...)

    self._soundFrameMap = data.soundFrameMap
end

---@param entity Actor.Entity
function _Move:Init(entity)
    _Base.Init(self, entity)

    self._controlMove = _ControlMove.New(self._entity.aspect, self._entity.transform, self._entity.input, _Point.New(), true, function ()
        _STATE.Play(self._entity.states, self._nextState)
    end)
end

function _Move:NormalUpdate(dt, rate)
    local speed = self._entity.duelist.moveSpeed
    rate = self._entity.attributes.moveRate * rate

    self._entity.aspect.rate = rate
    self._controlMove.speed:Set(speed * rate, speed * rate * 0.6)

    if (_CONFIG.user.player == self._entity and self._soundFrameMap and self._soundDataSet) then
        local main = _ASPECT.GetPart(self._entity.aspect) ---@type Graphics.Drawable.Frameani

        if (self._soundFrameMap[main:GetTick()]) then
            local data = #self._soundDataSet == 0 and self._soundDataSet or self._soundDataSet[1]
            _SOUND.Play(data)
        end
    end

    self._controlMove:Update()
end

function _Move:Exit()
    _Base.Exit(self)

    self._entity.aspect.rate = 1
end

return _Move
