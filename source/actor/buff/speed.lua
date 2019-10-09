--[[
	desc: Speed, A module of speed buff.
	author: Musoucrow
    since: 2018-10-4
    alter: 2019-5-11
]]--

local _SOUND = require("lib.sound")
local _RESMGR = require("actor.resmgr")
local _FACTORY = require("actor.factory")
local _ATTRIBUTE = require("actor.service.attribute")

local _Base = require("actor.buff.base")

---@class Actor.Buff.Speed : Actor.Buff
---@field protected _marks table
---@field protected _effect Actor.Entity
local _Speed = require("core.class")(_Base)

function _Speed.HandleData(data)
    if (data.actor) then
        data.actor = _RESMGR.GetInstanceData(data.actor)
    end

    if (data.sound) then
        data.sound = _RESMGR.GetSoundData(data.sound)
    end
end

function _Speed:Ctor(entity, data)
    _Base.Ctor(self, entity, data)

    self._marks = {
        _ATTRIBUTE.Add(entity.attributes, "+", "moveRate", data.value),
        _ATTRIBUTE.Add(entity.attributes, "+", "attackRate", data.value),
    }

    if (data.actor) then
        self._effect = _FACTORY.New(data.actor, {entity = entity})
    end

    if (data.sound) then
        _SOUND.Play(data.sound)
    end
end

function _Speed:Exit()
    if (_Base.Exit(self)) then
        for n=1, #self._marks do
            _ATTRIBUTE.Del(self._entity.attributes, self._marks[n])
        end

        if (self._effect) then
            self._effect.identity.destroyProcess = 1
        end
    end
end

return _Speed