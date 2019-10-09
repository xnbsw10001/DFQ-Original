--[[
	desc: Stroke, a gear for stroke motion business.
	author: Musoucrow
	since: 2018-8-8
]]--

local _Tweener = require("util.gear.tweener")
local _Gear = require("core.gear")

---@class Actor.Gear.Stroke:Core.Gear
---@field colorA Graphics.Drawunit.Color
---@field colorB Graphics.Drawunit.Color
---@field colorTime milli
---@field scale number
---@field scaleTime milli
---@field isA boolean
---@field pixel int
---@field protected _aspect Actor.Component.Aspect
---@field protected _colorTweener Util.Gear.Tweener
---@field protected _scaleTweener Util.Gear.Tweener
local _Stroke = require("core.class")(_Gear)

---@param aspect Actor.Component.Aspect
---@param colorA Graphics.Drawunit.Color
---@param colorB Graphics.Drawunit.Color
---@param colorTime milli
---@param scale number
---@param scaleTime milli
---@param pixel int
function _Stroke:Ctor(aspect, colorA, colorB, colorTime, scale, scaleTime, pixel)
    _Gear.Ctor(self)

    self._aspect = aspect
    self.colorA = colorA
    self.colorB = colorB
    self.colorTime = colorTime
    self.scale = scale
    self.scaleTime = scaleTime
    self.pixel = pixel
    self.isA = true

    self._colorTweener = _Tweener.New(aspect.stroke.color)
    self._scaleTweener = _Tweener.New(aspect.stroke, {scaleRate = 1})
end

function _Stroke:Enter()
    _Gear.Enter(self)

    local stroke = self._aspect.stroke
    stroke.color:Set(self.colorA:Get())
    stroke.scaleRate = self.scale

    self._colorTweener:Enter(self.colorTime, self.colorB)
    self._scaleTweener:Enter(self.scaleTime)
end

function _Stroke:Exit()
    _Gear.Exit(self)

    self._aspect.stroke.scaleRate = 0
end

function _Stroke:Update(dt)
    if (not self.isRunning) then
        return
    end

    self._scaleTweener:Update(dt)

    if (self.colorTime > 0) then
        self._colorTweener:Update(dt)

        if (not self._colorTweener.isRunning) then
            self.isA = not self.isA
            local color = self.isA and self.colorA or self.colorB
            self._colorTweener:Enter(self.colorTime, color)
        end
    end
end

function _Stroke:LateUpdate()
    if (not self.isRunning) then
        return
    end

    local stroke = self._aspect.stroke
    stroke.pixel = self.pixel
    stroke.scaleRate = stroke.scaleRate == 0 and 1 or stroke.scaleRate
end

return _Stroke