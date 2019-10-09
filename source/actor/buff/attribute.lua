--[[
	desc: Attribute, A module of attribute buff.
	author: Musoucrow
    since: 2018-9-19
    alter: 2019-6-17
]]--

local _SOUND = require("lib.sound")
local _RESMGR = require("actor.resmgr")
local _FACTORY = require("actor.factory")
local _ATTRIBUTE = require("actor.service.attribute")

local _Base = require("actor.buff.base")

---@class Actor.Buff.Attribute : Actor.Buff
---@field protected _mark table
---@field protected _effect Actor.Entity
local _Attribute = require("core.class")(_Base)

function _Attribute.HandleData(data)
    if (data.actor) then
        data.actor = _RESMGR.GetInstanceData(data.actor)
    end

    if (data.sound) then
        data.sound = _RESMGR.GetSoundData(data.sound)
    end
end

function _Attribute:Ctor(entity, data)
    _Base.Ctor(self, entity, data)

    if (data.attribute) then
        local operation = data.operation or "+"
        self._mark = _ATTRIBUTE.Add(entity.attributes, operation, data.attribute, data.value)
    end

    if (data.actor) then
        self._effect = _FACTORY.New(data.actor, {entity = entity})
    end

    if (data.sound) then
        _SOUND.Play(data.sound)
    end
end

function _Attribute:Exit()
    if (_Base.Exit(self)) then
        if (self._mark) then
            _ATTRIBUTE.Del(self._entity.attributes, self._mark)
        end

        if (self._effect) then
            self._effect.identity.destroyProcess = 1
        end
    end
end

return _Attribute