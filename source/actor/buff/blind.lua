--[[
	desc: Blind, A buff of Blind.
	author: Musoucrow
    since: 2019-5-4
    alter: 2019-5-11
]]--

local _CONFIG = require("config")
local _SOUND = require("lib.sound")
local _RESMGR = require("actor.resmgr")
local _ECSMGR = require("actor.ecsmgr")
local _FACTORY = require("actor.factory")

local _Effect_Colorize = require("actor.component.effect.colorize")
local _Base = require("actor.buff.base")

---@class Actor.Buff.Blind : Actor.Buff
---@field protected _effect Actor.RESMGR.InstanceData
local _Blind = require("core.class")(_Base)

local _colorize = {
    motions = {
        {
            time = 500,
            color = {
                red = 255,
                green = 255,
                blue = 255,
                alpha = 0
            }
        }
    }
}

---@param entity Actor.Entity
---@param data Actor.RESMGR.BuffData
---@return boolean
function _Blind.CanNew(entity, data)
    return _Base.CanNew(entity, data) and entity == _CONFIG.user.player
end

---@param data Actor.RESMGR.BuffData
function _Blind.HandleData(data)
    if (data.actor) then
        data.actor = _RESMGR.GetInstanceData(data.actor)
    end

    if (data.sound) then
        data.sound = _RESMGR.GetSoundData(data.sound)
    end
end

function _Blind:Ctor(entity, data)
    _Base.Ctor(self, entity, data)

    self._effect = _FACTORY.New(data.actor, {entity = self._entity})
    _SOUND.Play(data.sound)
end

function _Blind:Exit()
    if (_Base.Exit(self)) then
        _ECSMGR.AddComponent(self._effect, "effect_colorize", _Effect_Colorize.New(_colorize))

        return true
    end

    return false
end

return _Blind