--[[
	desc: BATTLE, a service of battle.
	author: Musoucrow
	since: 2018-3-29
	alter: 2019-8-9
]]--

local _STATE = require("actor.service.state")

local _Color = require("graphics.drawunit.color")

local _emptyflagMap = {}
local _emptyFunc = function() end
local _targetColor = _Color.New() ---@type Graphics.Drawunit.Color

---@class Actor.Service.BATTLE
local _BATTLE = {}

---@param attacker Actor.Component.Attacker
---@param identity Actor.Component.Identity
---@param time milli
---@param disableAttack boolean
function _BATTLE.Hitstop(attacker, identity, time, disableAttack)
    identity.isPaused = time > 0 and true or false
    attacker.hitstopTimer:Enter(time)
    
    if (disableAttack) then
        attacker.enable = not disableAttack
    else
        attacker.enable = true
    end
end

---@param battle Actor.Component.Battle
---@param time milli
---@param x1 int
---@param x2 int
---@param y1 int
---@param y2 int
function _BATTLE.Shake(battle, time, x1, x2, y1, y2)
    battle.shaker:Enter(time)
    battle.shaker.config.x[1] = x1 or 0
    battle.shaker.config.x[2] = x2 or 0
    battle.shaker.config.y[1] = y1 or 0
    battle.shaker.config.y[2] = y2 or 0
end

---@param battle Actor.Component.Battle
---@param color Graphics.Drawunit.Color
---@param time milli @default=175
function _BATTLE.Flash(battle, red, green, blue)
    if (battle.banCountMap.pure > 0) then
        return
    end

    local subject = battle.pureColorTweener:GetSubject() ---@type Graphics.Drawunit.Color
    subject:Set(red, green, blue, 255)
    _targetColor:Set(red, green, blue, 0)

    battle.pureColorTweener:Enter(175, _targetColor)
end

---@param battle Actor.Component.Battle
---@param states Actor.Component.States
---@param time number
---@param power milli
---@param speed milli
---@param direction direction
---@param flagMap table<string, boolean> @can null
---@param Func function @can null
---@return boolean
function _BATTLE.Stun(battle, states, time, power, speed, direction, flagMap, Func)
    if (battle.banCountMap.stun > 0 or _STATE.HasTag(states, "fall") or _STATE.HasTag(states, "overturn") or _STATE.HasTag(states, "jump")) then
        return false
    end

    power = power or 0
    speed = speed or 0
    direction = direction or 1
    flagMap = flagMap or _emptyflagMap
    Func = Func or _emptyFunc

    return _STATE.Play(states, "stun", false, time, power, speed, direction, flagMap, Func)
end

---@param battle Actor.Component.Battle
---@param states Actor.Component.States
---@param power_z number
---@param speed_up number
---@param speed_down number
---@param power_x number
---@param speed_x number
---@param direction direction
---@param flagMap table<string, boolean> @can null
---@param Func function @can null
---@return boolean
function _BATTLE.Flight(battle, states, power_z, speed_up, speed_down, power_x, speed_x, direction, flagMap, Func)
    flagMap = flagMap or _emptyflagMap
    
    if (battle.banCountMap.flight > 0 and not flagMap.force) then
        return false
    end

    power_z = power_z or 0
    speed_up = speed_up or 0.417
    speed_down = speed_down or 0.501
    power_x = power_x or 0
    speed_x = speed_x or 0
    direction = direction or 1
    Func = Func or _emptyFunc

    return _STATE.Play(states, "flight", false, power_z, speed_up, speed_down, power_x, speed_x, direction, flagMap, Func)
end

---@param battle Actor.Component.Battle
---@param states Actor.Component.States
---@param x int
---@param y int
---@param z int
---@param movingTime milli
---@param delayTime milli @default=0
---@param easing string @default=inOutQuadFixed
---@param flightParam table @can null
---@param flagMap table<string, boolean> @can null
---@param Func function @can null
function _BATTLE.Overturn(battle, states, x, y, z, movingTime, delayTime, easing, flightParam, flagMap, Func)
    if (battle.banCountMap.overturn > 0) then
        return false
    end

    delayTime = delayTime or 0
    easing = easing or "inOutQuadFixed"
    flightParam = flightParam or _emptyflagMap
    flagMap = flagMap or _emptyflagMap
    Func = Func or _emptyFunc

    return _STATE.Play(states, "overturn", false, x, y, z, movingTime, delayTime, easing, flightParam, flagMap, Func)
end

---@param transform Actor.Component.Transform
---@param battle Actor.Component.Battle
---@param x int
---@param direction direction
---@return boolean
function _BATTLE.Turn(transform, battle, x, direction)
    if (direction == 0 or battle.banCountMap.turn > 0) then
        return false
    end

    local origin = transform.direction

    if (x and direction == nil) then
        local px = transform.position.x

        if (x > px) then
            transform.direction = 1
        elseif (x < px) then
            transform.direction = -1
        end
    elseif (direction) then
        transform.direction = direction
    end

    if (origin ~= transform.direction) then
        transform.scaleTick = true

        return true
    end

    return false    
end

---@param a int @camp
---@param b int @camp
---@param type int @camp type
---@return boolean
function _BATTLE.CondCamp(a, b, type)
    if (type == "enemy") then
        return a ~= b and b > 0
    elseif (type == "same") then
        return a == b
    elseif (type == "else") then
        return a ~= b
    end

    return true
end

---@param battle Actor.Component.Battle
---@param attributes Actor.Component.Attributes
---@param transform Actor.Component.Transform
---@param attacker Actor.Component.Attacker
---@param identity Actor.Component.Identity
---@param overKill boolean
function _BATTLE.DieTick(battle, attributes, transform, attacker, identity, overKill)
    if (battle.deadProcess > 0) then
        return
    end

    battle.deadProcess = attributes.hp <= 0 and battle.banCountMap.die == 0 and (transform.position.z == 0 or battle.banCountMap.flight > 0) and 1 or 0

    if (battle.deadProcess > 0) then
        battle.overKill = overKill or false
        _BATTLE.Flash(battle, 255, 255, 255)
        _BATTLE.Hitstop(attacker, identity, 200)
        _BATTLE.Shake(battle, 200, -2, 2, 0, 0)
    end
end

return _BATTLE