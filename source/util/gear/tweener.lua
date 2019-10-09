--[[
	desc: Tweener, a wrapper of tween.
	author: Musoucrow
	since: 2018-3-22
	alter: 2018-12-24
]]--

local _MATH = require("lib.math")

local _Tween = require("3rd.tween")
local _Gear = require("core.gear")

local _easing = {}
local _emptyFunc = function() end

for k, v in pairs(_Tween.easing) do
    _easing[k] = v
    _easing[k .. "Fixed"] = function(...)
        return _MATH.GetFixedDecimal(v(...))
    end
    _easing[k .. "Int"] = function(...)
        return math.floor(v(...))
    end
end

local function _GetEasing(easing)
    if (type(easing) == "string") then
        return _easing[easing]
    end

    return easing
end

---@class Util.Gear.Tweener : Core.Gear
---@field protected _tween table
---@field public Callback function
local _Tweener = require("core.class")(_Gear)

---@param subject table
---@param target table
---@param easing string
---@param Callback function
function _Tweener:Ctor(subject, target, easing, Callback)
    _Gear.Ctor(self)

    if (not easing) then
        easing = "linearFixed"
    end

    self._tween = _Tween.new(_, subject, target, _GetEasing(easing))
    self.Callback = Callback
end

---@param dt milli
function _Tweener:Update(dt)
    if (not self.isRunning) then
        return
    end

    --If end
    if (self._tween:update(dt)) then
        self:Exit()
    end

    self:Callback()
end

---@param time milli
---@param target table
---@param easing string
---@param subject table
---@param Callback function
function _Tweener:Enter(time, target, easing, subject, Callback)
    _Gear.Enter(self)

    self._tween.duration = time or self._tween.duration
    self._tween.subject = subject or self._tween.subject
    self._tween.target = target or self._tween.target
    self._tween.easing = _GetEasing(easing) or self._tween.easing
    self.Callback = Callback or self.Callback or _emptyFunc
    self._tween.initial = nil
    self._tween:reset()
    self:Callback()
end

function _Tweener:SetEasing(easing)
    self._tween.easing = _GetEasing(easing)
end

function _Tweener:SetTime(time)
    self._tween.duration = time
end

function _Tweener:GetSubject()
    return self._tween.subject
end

function _Tweener:SetTarget(target)
    self._tween.target = target
end

function _Tweener:GetTarget()
    return self._tween.target
end

function _Tweener:GetTime()
    return self._tween.duration
end

function _Tweener:GetProcess()
    return _MATH.GetFixedDecimal(self._tween.clock / self._tween.duration)
end

function _Tweener:Reset()
    self.isRunning = true
    self._tween:reset()
end

return _Tweener