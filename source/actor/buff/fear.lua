--[[
	desc: fear, A module of fear buff.
	author: SkyFvcker
    since: 2018-11-8
    alter: 2019-5-11
]]--

local _SOUND = require("lib.sound")
local _RESMGR = require("actor.resmgr")
local _FACTORY = require("actor.factory")
local _ATTRIBUTE = require("actor.service.attribute")

local _Range = require("graphics.drawunit.range")
local _Base = require("actor.buff.base")

---@class Actor.Buff.Fear : Actor.Buff
---@field protected _effect Actor.Entity
---@field protected _searchRange Graphics.Drawunit.Range
---@field protected _aiEnable boolean
local _Fear = require("core.class")(_Base)

---@param entity Actor.Entity
---@param data Actor.RESMGR.BuffData
---@return boolean
function _Fear.CanNew(entity, data)
    return _Base.CanNew(entity, data) and entity.ais and entity.ais.container:Get("useSkill")
end

function _Fear.HandleData(data)
    if (data.actor) then
        data.actor = _RESMGR.GetInstanceData(data.actor)
    end

    if (data.sound) then
        data.sound = _RESMGR.GetSoundData(data.sound)
    end
end

function _Fear:Ctor(entity, data)
    _Base.Ctor(self, entity, data)

    if (data.actor) then
        self._effect = _FACTORY.New(data.actor, {entity = entity})
    end

    if (data.sound) then
        _SOUND.Play(data.sound)
    end

    self._aiEnable = entity.ais.enable
    entity.ais.enable = true
    entity.ais.container:Get("useSkill").enable = false
    
    local searchMove = entity.ais.container:Get("searchMove") ---@type Actor.Ai.SearchMove
    self._searchRange = _Range.New(searchMove.searchRange:Get())
    searchMove.searchRange:Set(0, 0, 0, 0)
end

function _Fear:Exit()
    if (_Base.Exit(self)) then
        self._entity.ais.enable = self._aiEnable
        self._entity.ais.container:Get("useSkill").enable = true
        self._entity.ais.container:Get("searchMove").searchRange:Set(self._searchRange:Get())

        if (self._effect) then
            self._effect.identity.destroyProcess = 1
        end
    end
end

return _Fear