--[[
	desc: DigitTip, a digit tips on map.
	author: Musoucrow
    since: 2018-6-8
    alter: 2019-3-27
]]--

local _GRAPHICS = require("lib.graphics")

local _Point = require("graphics.drawunit.point")
local _Color = require("graphics.drawunit.color")
local _Tweener = require("util.gear.tweener")
local _Gear = require("core.gear")
local _Label = require("graphics.drawable.label")

---@class Actor.DigitTip:Graphics.Drawable.Label
---@field protected _scaleTweener Util.Gear.Tweener
---@field protected _positionTweener Util.Gear.Tweener
---@field protected _colorTweener Util.Gear.Tweener
---@field protected _flashTweener Util.Gear.Tweener
local _DigitTip = require("core.class")(_Label, _Gear)

---@param content string
---@param data Lib.RESOURCE.FontData
---@param x int
---@param y int
---@param scale number
function _DigitTip:Ctor()
    _Label.Ctor(self)
    _Gear.Ctor(self)

    self._scaleTweener = _GRAPHICS.NewDrawableAttriTweener(self, _Point.New(false), "scale")
    self._positionTweener = _GRAPHICS.NewDrawableAttriTweener(self, _Point.New(true), "position")
    self._colorTweener = _GRAPHICS.NewDrawableAttriTweener(self, _Color.New(), "color")
    self._flashTweener = _Tweener.New(_Color.New())

    self._scaleTweener:SetTarget(_Point.New(false, 1, 1))
    self._positionTweener:SetTarget(_Point.New(true))
    self._colorTweener:SetTarget(_Color.New(255, 255, 255, 0))
    self._flashTweener:SetTarget(_Color.New(255, 255, 255, 0))
end

function _DigitTip:Enter(content, data, x, y, scale, scaleTime, moveTime, colorTime, flashTime, shift)
    _Gear.Enter(self)

    self:SetData(data)
    self:SetContent(content)
    self:SetAttri("position", x, y)
    self:SetAttri("origin", math.floor(self._width * 0.5), math.floor(self._height * 0.5))

    self._scaleTweener:GetSubject():Set(scale, scale)
    self._scaleTweener:Enter(scaleTime)

    self._positionTweener:GetSubject():Set(x, y)
    self._positionTweener:GetTarget():Set(x, y + shift)
    self._positionTweener:Enter(moveTime, _, "outQuad")

    self._colorTweener:GetSubject():Set(255, 255, 255, 255)
    self._colorTweener:Enter(colorTime)

    if (flashTime > 0) then
        self._flashTweener:GetSubject():Set(255, 255, 255, 255)
        self._flashTweener:Enter(flashTime)
    else
        self._flashTweener:Exit()
    end
end

function _DigitTip:Update(dt)
    if (not self.isRunning) then
        return
    end

    if (self._scaleTweener.isRunning) then
        self._scaleTweener:Update(dt)
    else
        self._positionTweener:Update(dt)
        self._colorTweener:Update(dt)

        if (not self._colorTweener.isRunning) then
            self:Exit()
        end
    end

    self._flashTweener:Update(dt)
end

function _DigitTip:Draw()
    if (not self.isRunning) then
        return
    end

    _Label.Draw(self)
end

function _DigitTip:DrawFlash()
    if (not self.isRunning or not self._flashTweener.isRunning) then
        return
    end

    self._renderer:DrawObj(self._drawableObj)
end

return _DigitTip