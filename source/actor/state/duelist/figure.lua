--[[
	desc: Figure, a state of Duelist.
	author: Musoucrow
	since: 2019-7-9
]]--

local _SOUND = require("lib.sound")
local _EFFECT = require("actor.service.effect")

local _Base = require("actor.state.base")

---@class Actor.State.Duelist.Figure : Actor.State
local _Figure = require("core.class")(_Base)

function _Figure:Tick(lateState, Func)
    local data = self._frameaniDataSets.body.list[1].spriteData ---@type Lib.RESOURCE.SpriteData
    _EFFECT.NewFigure(self._entity.transform, self._entity.aspect, data)

    Func(self)

    if (self._soundDataSet) then
        _SOUND.Play(self._soundDataSet)
    end

    return true
end

return _Figure