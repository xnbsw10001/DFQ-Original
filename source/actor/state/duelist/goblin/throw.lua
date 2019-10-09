--[[
	desc: Throw, a state of Goblin.
	author: Musoucrow
	since: 2018-5-31
	alter: 2019-5-11
]]--

local _FACTORY = require("actor.factory")
--local _EFFECT = require("actor.service.effect")
--local _DUELIST = require("actor.service.duelist")

local _Range = require("graphics.drawunit.range")
local _Base = require("actor.state.duelist.goblin.attackAction")

---@class Actor.State.Duelist.Goblin.Throw:Actor.State.Duelist.Goblin.AttackAction
---@field protected _bulletPos Graphics.Drawunit.Point3
---@field protected _dangerArea Actor.Component.Effect.DangerArea
---@field protected _range Graphics.Drawunit.Range
local _Throw = require("core.class")(_Base)

function _Throw:Ctor(data, ...)
    _Base.Ctor(self, data, ...)

    self._bulletPos = data.bulletPos
    self._range = _Range.New()
end

function _Throw:OnKeyTick()
    local t = self._entity.transform
    local param = {
        x = t.position.x + self._bulletPos.x * t.scale.x * t.direction,
        y = t.position.y + self._bulletPos.y,
        z = t.position.z + self._bulletPos.z * t.scale.y,
        direction = t.direction,
        entity = self._entity,
        attackValue = self._skill.attackValues[1]
    }

    _FACTORY.New(self._actorDataSet, param)
    --_EFFECT.ExitDangerArea(self._dangerArea)
end
--[[
function _Throw:Enter(...)
    _Base.Enter(self, ...)

    local collider = self._skill:GetCollider()
    _DUELIST.StuffRangeWithCollider(self._range, collider)
    self._dangerArea = _EFFECT.NewDangerArea(self._entity.transform, self._range).effect_dangerArea
end
]]--
function _Throw:Exit()
    _Base.Exit(self)
    --_EFFECT.ExitDangerArea(self._dangerArea)
end

return _Throw