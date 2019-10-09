--[[
	desc: Stay, a state of Duelist.
	author: Musoucrow
	since: 2018-8-19
	alter: 2018-8-7
]]--

local _CONFIG = require("config")
local _STATE = require("actor.service.state")
local _INPUT = require("actor.service.input")

local _Base = require("actor.state.base")

---@class Actor.State.Duelist.Stay:Actor.State
local _Stay = require("core.class")(_Base)

function _Stay:NormalUpdate(dt, rate)
    for n=1, #_CONFIG.arrow do
        if (_INPUT.IsHold(self._entity.input, _CONFIG.arrow[n])) then
            _STATE.Play(self._entity.states, self._nextState)
            return
        end
    end
end

return _Stay