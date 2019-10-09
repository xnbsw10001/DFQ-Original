--[[
	desc: Input, a system of input.
	author: Musoucrow
	since: 2018-3-29
	alter: 2019-8-29
]]--

local _LIB_INPUT = require("lib.input")
local _KEYBOARD = require("lib.keyboard")
local _INPUT = require("actor.service.input")
local _CONFIG = require("config")

local _Base = require("actor.system.base")

---@class Actor.System.Input : Actor.System
local _Input = require("core.class")(_Base)

local function _OnPressed(key)
    local player = _CONFIG.user.player

    if (player and not player.ais.enable and player.identity.rate > 0) then
        local code = _CONFIG.anticode[key]

        if (code) then
            _INPUT.Press(player.input, code)
        end
    end
end

local function _OnReleased(key)
    local player = _CONFIG.user.player

    if (player and not player.ais.enable) then
        local code = _CONFIG.anticode[key]

        if (code) then
            _INPUT.Release(player.input, code)
        end
    end
end

function _Input:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        input = true
    }, "input")

    _KEYBOARD.AddListener("onPressed", _, _OnPressed)
    _KEYBOARD.AddListener("onReleased", _, _OnReleased)
end

function _Input:LateUpdate()
    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity

        _LIB_INPUT.Update(e.input.map)

        if (e.ais and e.ais.enable) then
            for k, v in pairs(e.input.map) do
                if (v == _LIB_INPUT.enum.hold) then
                    e.input.map[k] = _LIB_INPUT.enum.released
                end
            end
        end
    end
end

return _Input