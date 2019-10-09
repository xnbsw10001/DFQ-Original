--[[
	desc: Summon, A buff of summon.
	author: Musoucrow
	since: 2018-9-6
]]--

local _ASPECT = require("actor.service.aspect")

local _Color = require("graphics.drawunit.color")
local _Base = require("actor.buff.base")

---@class Actor.Buff.Summon : Actor.Buff.Stroke
---@field protected _colorTweener Util.Gear.MockTweener
---@field protected _aiEnable boolean
local _Summon = require("core.class")(_Base)

---@param entity Actor.Entity
function _Summon:Ctor(entity, data)
    _Base.Ctor(self, entity, data)

    self._entity.aspect.color.alpha = 0
    self._entity.aspect.colorTick = true

    self._aiEnable = self._entity.ais and self._entity.ais.enable

    if (self._aiEnable) then
        self._entity.ais.enable = false
    end

    self._colorTweener = _ASPECT.NewColorTweener(self._entity.aspect)
    self._colorTweener:Enter(data.time, _Color.New())

    local battle = entity.battle
    battle.banCountMap.attack = battle.banCountMap.attack + 1
end

function _Summon:OnUpdate(dt)
    self._colorTweener:Update(dt)
end

function _Summon:Exit()
    if (_Base.Exit(self)) then
        local battle = self._entity.battle
        battle.banCountMap.attack = battle.banCountMap.attack - 1
        
        if (self._aiEnable) then
            self._entity.ais.enable = true
        end

        return true
    end

    return false
end

return _Summon