--[[
	desc: Undebuff, A buff.
	author: Musoucrow
    since: 2019-7-10
]]--

local _RESMGR = require("actor.resmgr")
local _FACTORY = require("actor.factory")

local _Base = require("actor.buff.base")

---@class Actor.Buff.UnDebuff : Actor.Buff
---@field protected _effect Actor.Entity
local _Undebuff = require("core.class")(_Base)

function _Undebuff.HandleData(data)
    if (data.actor) then
        data.actor = _RESMGR.GetInstanceData(data.actor)
    end
end

function _Undebuff:Ctor(entity, data)
    _Base.Ctor(self, entity, data)

    self._effect = _FACTORY.New(data.actor, {entity = entity})
    self._entity.buffs.undebuffCount = self._entity.buffs.undebuffCount + 1
end

function _Undebuff:Exit()
    if (_Base.Exit(self)) then
        self._entity.buffs.undebuffCount = self._entity.buffs.undebuffCount - 1

        if (self._effect) then
            self._effect.identity.destroyProcess = 1
        end
    end
end

return _Undebuff