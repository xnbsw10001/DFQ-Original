--[[
	desc: DIRECTOR, the game manager.
	author: Musoucrow
	since: 2018-12-2
	alter: 2019-9-23
]]--

local _CONFIG = require("config")
local _MAP = require("map.init")
local _WORLD = require("actor.world")
local _FACTORY = require("actor.factory")

local _Tweener = require("util.gear.tweener")
local _Curtain = require("graphics.curtain")

local _DIRECTOR = {rate = 1} ---@class DIRECTOR
local _curtain = _Curtain.New()
local _speedTweener = _Tweener.New(_DIRECTOR, {rate = 1})

function _DIRECTOR.Init()
    _WORLD.Init()
    _MAP.Init(_WORLD.Draw)

    _DIRECTOR.StartGame()
end

function _DIRECTOR.Update(dt)
    _MAP.LoadTick()
    
    _speedTweener:Update(dt)

    _curtain:Update(dt)

    dt = dt * _DIRECTOR.rate
    _WORLD.Update(dt, _DIRECTOR.rate)
    _MAP.Update(dt)
end

function _DIRECTOR.Draw()
    _MAP.Draw()
    _curtain:Draw()
end

function _DIRECTOR.Curtain(...)
    _curtain:Enter(...)
end

---@return boolean
function _DIRECTOR.InCurtain()
    return _curtain.isRunning
end

---@param rate number
---@param time milli
---@param easing string
function _DIRECTOR.SetRate(rate, time, easing)
    _speedTweener:GetTarget().rate = rate
    _speedTweener:Enter(time, _, easing)
end

---@return boolean
function _DIRECTOR.IsTweening()
    return _speedTweener.isRunning
end

function _DIRECTOR.StartGame()
    local player = _FACTORY.New("duelist/swordman", {
        x = 700,
        y = 500,
        direction = 1,
        camp = 1
    })

    _CONFIG.user:SetPlayer(player)
    _DIRECTOR.Update(0) -- Flush player.

    _MAP.Load(_MAP.Make("lorien"))
end

return _DIRECTOR