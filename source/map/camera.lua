--[[
	desc: MAP's Camera.
	author: Musoucrow
	since: 2018-11-13
	alter: 2019-10-1
]]--

local _SYSTEM = require("lib.system")
local _GRAPHICS = require("lib.graphics")

local _Point3 = require("graphics.drawunit.point3")
local _Point = require("graphics.drawunit.point")
local _Tweener = require("util.gear.tweener")
local _GCamera = require("graphics.camera")
local _Shaker = require("util.gear.shaker")

---@class Map.Camera:Graphics.Camera
---@field protected _current Graphics.Drawunit.Point3
---@field protected _position Graphics.Drawunit.Point3
---@field protected _target Graphics.Drawunit.Point3
---@field protected _stdScale Graphics.Drawunit.Point
---@field protected _time milli
---@field protected _moveTweener Util.Gear.Tweener
---@field protected _shaker Util.Gear.Shaker
---@field protected _isNavigation boolean
---@field protected _scaleTweener Util.Gear.Tweener
local _Camera = require("core.class")(_GCamera)

---@param followTime milli
function _Camera:Ctor(followTime, sx, sy)
    _GCamera.Ctor(self)

    self._current = _Point3.New()
    self._position = _Point3.New()
    self._stdScale = _Point.New(false, sx, sy)
    self._time = followTime
    self._isNavigation = false

    self._moveTweener = _Tweener.New(self._current, _, "linear", function()
        self:SetPosition(self._current.x, self._current.y + self._current.z)
    end)

    self._shaker = _Shaker.New(_Point.New(true), {x = {}, y = {}}, function (subject)
        self._position.x = self._position.x + subject.x
        self._position.y = self._position.y + subject.y
    end)

    self._scaleTweener = _Tweener.New(self._scale, _Point.New(false))
    self:SetScale(1, 1)
end

---@param dt milli
function _Camera:Update(dt)
    if (not self._target) then
        return
    end

    if (not self._isNavigation) then
        self._moveTweener:Reset()
    end

    self._moveTweener:Update(dt)
    self._scaleTweener:Update(dt)

    self._shaker:Update(dt)
end

---@param target Graphics.Drawunit.Point3
---@param time milli
---@param easing string
function _Camera:SetTarget(target, time, easing)
    self._isNavigation = time ~= nil
    time = time or self._time
    easing = easing or "linear"

    self._target = target
    self._moveTweener:Enter(time, self._target, easing)

    if (not self._isNavigation) then
        self._moveTweener._tween.initial = self._current
    end
end

function _Camera:SetPosition(x, y, adjust)
    _GCamera.SetPosition(self, x, y)

    if (adjust) then
        self._current:Set(x, y, 0)
        self._moveTweener:Reset()
    end
end

---@param time milli
---@param xa int
---@param xb int
---@param ya int
---@param yb int
function _Camera:Shake(time, xa, xb, ya, yb)
    self._shaker.config.x[1] = xa or 0
    self._shaker.config.x[2] = xb or 0
    self._shaker.config.y[1] = ya or 0
    self._shaker.config.y[2] = yb or 0

    self._shaker:Enter(time)
end

---@return boolean
function _Camera:IsMoving()
    return self._moveTweener.isRunning
end

---@return boolean
function _Camera:IsScaling()
    return self._scaleTweener.isRunning
end

---@param x number
---@param y number
---@param time milli
---@param easing string
function _Camera:SetScale(x, y, time, easing)
    x = x * self._stdScale.x
    y = y * self._stdScale.y

    if (time) then
        self._scaleTweener:GetTarget():Set(x, y)
        self._scaleTweener:Enter(time, _, easing)
    else
        _GCamera.SetScale(self, x, y)
    end
end

return _Camera