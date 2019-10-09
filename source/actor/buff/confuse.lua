--[[
	desc: Confuse, A buff of confuse.
	author: Musoucrow
    since: 2019-2-10
    alter: 2019-5-11
]]--

local _CONFIG = require("config")
local _LIB_INPUT = require("lib.input")
local _SOUND = require("lib.sound")
local _TABLE = require("lib.table")
local _RESMGR = require("actor.resmgr")
local _FACTORY = require("actor.factory")
local _INPUT = require("actor.service.input")

local _Base = require("actor.buff.base")

---@class Actor.Buff.Confuse : Actor.Buff
---@field protected _effect Actor.Entity
---@field protected _camp int
---@field protected _keyMap table
local _Confuse = require("core.class")(_Base)

local function _Release()
    local input = _CONFIG.user.player.input
    _INPUT.Release(input, "up")
    _INPUT.Release(input, "down")
    _INPUT.Release(input, "left")
    _INPUT.Release(input, "right")
end

local function _DefaultArrow()
    _Release()

    _LIB_INPUT.SetKey("up", "up")
    _LIB_INPUT.SetKey("down", "down")
    _LIB_INPUT.SetKey("left", "left")
    _LIB_INPUT.SetKey("right", "right")

    _CONFIG.user.setPlayerCaller:DelListener(_, _DefaultArrow)
end

---@param data Actor.RESMGR.BuffData
function _Confuse.HandleData(data)
    data.effect = _RESMGR.GetInstanceData(data.effect)
    data.sound = _RESMGR.GetSoundData(data.sound)
end

function _Confuse:Ctor(entity, data)
    _Base.Ctor(self, entity, data)

    self._effect = _FACTORY.New(data.effect, {entity = self._entity})
    --self._camp = self._entity.battle.camp
    --self._entity.battle.camp = 0

    _SOUND.Play(data.sound)

    if (self._entity == _CONFIG.user.player) then
        _Release()

        _LIB_INPUT.SetKey("up", "down")
        _LIB_INPUT.SetKey("down", "up")
        _LIB_INPUT.SetKey("left", "right")
        _LIB_INPUT.SetKey("right", "left")

        _CONFIG.user.setPlayerCaller:AddListener(_, _DefaultArrow)
    end
end

function _Confuse:Exit()
    if (_Base.Exit(self)) then
        self._effect.identity.destroyProcess = 1
        --self._entity.battle.camp = self._camp

        if (self._entity == _CONFIG.user.player) then
            _DefaultArrow()
        end
    end
end

return _Confuse