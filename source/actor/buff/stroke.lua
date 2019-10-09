--[[
	desc: Stroke, A basic class for stroke.
	author: Musoucrow
	since: 2018-8-8
]]--

local _Color = require("graphics.drawunit.color")
local _Gear_Stroke = require("actor.gear.stroke")
local _Base = require("actor.buff.base")

---@class Actor.Buff.Stroke : Actor.Buff
---@field protected _stroke Actor.Gear.Stroke
local _Stroke = require("core.class")(_Base)

function _Stroke.HandleData(data)
    for n=1, #data.colorRange do
        local c = data.colorRange[n]
        data.colorRange[n] = _Color.New(c.red, c.green, c.blue, c.alpha)
    end
end

---@param entity Actor.Entity
function _Stroke:Ctor(entity, data)
    _Base.Ctor(self, entity, data)

    self._stroke = _Gear_Stroke.New(entity.aspect, data.colorRange[1], data.colorRange[2], data.colorTime,
            data.scale, data.scaleTime, data.pixel)
    self._stroke:Enter()
end

function _Stroke:Exit()
    if (_Base.Exit(self)) then
        self._stroke:Exit()

        return true
    end

    return false
end

function _Stroke:OnUpdate(dt)
    self._stroke:Update(dt)
end

function _Stroke:OnLateUpdate(dt)
    self._stroke:LateUpdate(dt)
end

return _Stroke

