--[[
	desc: MOTION, a service for transform.
	author: Musoucrow
	since: 2018-3-28
	alter: 2019-5-25
]]--

local _MATH = require("lib.math")
local _INPUT = require("actor.service.input")

local _Map = require("map.init")
local _Tweener = require("util.gear.tweener")
local _MockTweener = require("util.gear.mockTweener")
local _Shaker = require("util.gear.shaker")

local _pointKeys = {"x", "y", "z"}

---@class Actor.Service.MOTION
local _MOTION = {}

---@param transform Actor.Component.Transform
---@param aspect Actor.Component.Aspect
---@param type string x, y or z
---@param value number
function _MOTION.Move(transform, aspect, type, value)
    value = _MATH.GetFixedDecimal(value)
    local matrix = _Map.GetMatrix()

    if (type == "z") then
        transform.position.z = transform.position.z + value
    else
        local nx = matrix:ToNode(transform.position.x, "x")
        local ny = matrix:ToNode(transform.position.y, "y")
        local isCross = false
        local isX = type == "x"
        local direction = _MATH.GetDirection(value)
        local newPos = transform.position[type] + value
        local target = matrix:ToNode(newPos, type)
        local current = isX and nx or ny
        local range = math.abs(current - target)

        for n=1, range do
            local isObs

            if (isX) then
                isObs = matrix:GetNode(nx + direction * n, ny, true)
            else
                isObs = matrix:GetNode(nx, ny + direction * n, true)
            end

            if (isObs) then
                if (direction > 0) then
                    transform.position[type] = matrix:ToPosition(current + n, type) - 1
                else
                    transform.position[type] = matrix:ToPosition(current - n + 1, type)
                end

                isCross = true
                break
            end
        end

        if (not isCross) then
            transform.position[type] = newPos
        else
            transform.obstructCaller:Call()
        end
    end

    transform.positionTick = true
end

---@param transform Actor.Component.Transform
---@param aspect Actor.Component.Aspect
---@param vector Graphics.Drawunit.Point3
function _MOTION.MoveWithVector(transform, aspect, vector)
    if (vector.x ~= 0) then
        _MOTION.Move(transform, aspect, "x", vector.x)
    end

    if (vector.y ~= 0) then
        _MOTION.Move(transform, aspect, "y", vector.y)
    end

    if (vector.z ~= 0) then
        _MOTION.Move(transform, aspect, "z", vector.z)
    end
end

---@param transform Actor.Component.Transform
---@param aspect Actor.Component.Aspect
---@return Util.Gear.MockTweener
function _MOTION.NewMoveTweener(transform, aspect)
    ---@param tweener Util.Gear.MockTweener
    return _MockTweener.New(_pointKeys, _, function(tweener)
        local subject = tweener._tween.subject
        local x = subject.x - tweener.later.x
        local y = subject.y - tweener.later.y
        local z = subject.z - tweener.later.z

        if (x ~= 0) then
            _MOTION.Move(transform, aspect, "x", x)
        end

        if (y ~= 0) then
            _MOTION.Move(transform, aspect, "y", y)
        end

        if (z ~= 0) then
            _MOTION.Move(transform, aspect, "z", z)
        end
    end)
end

---@param transform Actor.Component.Transform
---@param aspect Actor.Component.Aspect
function _MOTION.NewScaleTweener(transform)
    return _Tweener.New(transform.scale, _, _, function ()
        transform.scaleTick = true
    end)
end

---@param transform Actor.Component.Transform
---@param aspect Actor.Component.Aspect
function _MOTION.NewShaker(transform)
    return _Shaker.New(transform.shake, {x = {0, 0, 0}, y = {0, 0, 0}}, function()
        transform.positionTick = true
    end)
end

function _MOTION.AdjustCollider(transform, collider, x, y, z, radian, sx, sy)
    if (transform.positionTick or transform.scaleTick or transform.radianTick) then
        x = x or 0
        y = y or 0
        z = z or 0
        radian = radian or 0
        sx = sx or 1
        sy = sy or 1

        local position = transform.position
        local scale = transform.scale

        collider:Set(position.x + x, position.y + y, position.z + z,
                scale.x * transform.direction * sx, scale.y * sy, transform.radian.value * radian)
    end
end

---@param a Actor.Component.Transform
---@param b Actor.Component.Transform
-- A aims to B.
function _MOTION.AimDirection(a, b)
    local direction = a.position.x < b.position.x and 1 or -1

    if (a.direction ~= direction) then
        a.direction = direction
        a.scaleTick = true
    end
end

---@param transform Actor.Component.Transform
---@param input Actor.Component.Input
---@return boolean @has turned
function _MOTION.TurnDirection(transform, input)
    local arrowDirection = _INPUT.GetArrowDirection(input, transform.direction)

    if (arrowDirection == -1) then
        transform.direction = -transform.direction
        transform.scaleTick = true

        return true
    end

    return false
end

return _MOTION