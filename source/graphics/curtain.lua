--[[
	desc: Curtain, a screen effect.
	author: Musoucrow
	since: 2018-6-7
]]--

local _GRAPHICS = require("lib.graphics")
local _SYSTEM = require("lib.system")

local _Tweener = require("util.gear.tweener")
local _Color = require("graphics.drawunit.color")
local _Timer = require("util.gear.timer")

---@class Graphics.Curtain
---@field protected _color Graphics.Drawunit.Color
---@field protected _targetColor Graphics.Drawunit.Color
---@field protected _tweener Util.Gear.Tweener
---@field protected _timer Util.Gear.Timer
---@field protected _isUp boolean
---@field protected _OnFull function
---@field protected _OnDown function
---@field protected _OnEnd function
---@field public isRunning boolean
---@field public downTime milli
---@field public width int
---@field public height int
local _Curtain = require("core.class")()

local _emptyFunc = function() end

---@param motionTime milli
function _Curtain:Ctor()
    self._color = _Color.New()
    self._targetColor = _Color.New()
    self._tweener = _Tweener.New(self._color, self._targetColor)
    self._timer = _Timer.New()
    self._isUp = false
    self.width, self.height = _SYSTEM.GetScreenDimensions()
end

function _Curtain:Update(dt)
    if (not self.isRunning) then
        return
    end

    if (not self._isUp and self._timer.isRunning) then
        self._timer:Update(dt)

        if (not self._timer.isRunning and self._OnDown) then
            self._OnDown()
        end
    elseif (self._tweener.isRunning) then
        self._tweener:Update(dt)

        if (not self._tweener.isRunning) then
            if (self._isUp) then
                self._OnFull()
                self._isUp = false
                self._targetColor.alpha = 0
                self._tweener:Enter(self.downTime)
            else
                self.isRunning = false
                self._OnEnd()
            end
        end
    end
end

function _Curtain:Draw()
    if (not self.isRunning) then
        return
    end

    _GRAPHICS.SetColor(self._color:Get())
    _GRAPHICS.DrawRect(0, 0, self.width, self.height, "fill")
    _GRAPHICS.ResetColor()
end

---@param color Graphics.Drawunit.Color
---@param upTime milli
---@param downTime milli
---@param wattingTime milli
---@param OnFull function
---@param OnDown function
---@param OnEnd function
function _Curtain:Enter(color, upTime, downTime, wattingTime, OnFull, OnDown, OnEnd)
    self._color:Set(color.red, color.green, color.blue, upTime == 0 and 255 or 0)
    self._targetColor:Set(color.red, color.green, color.blue, color.alpha)
    self._timer:Enter(wattingTime)
    self._tweener:Enter(upTime)
    self._isUp = true
    self.downTime = downTime
    self._OnFull = OnFull or _emptyFunc
    self._OnDown = OnDown or _emptyFunc
    self._OnEnd = OnEnd or _emptyFunc
    self.isRunning = true
end

return _Curtain