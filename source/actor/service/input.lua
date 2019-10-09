--[[
	desc: INPUT, a service of input.
	author: Musoucrow
	since: 2018-3-29
	alter: 2018-5-5
]]--

local _LIB_INPUT = require("lib.input")

---@class Actor.Service.INPUT
local _INPUT = {}

---@param input Actor.Component.Input
---@param key string
---@param nextTime boolean
function _INPUT.Press(input, key)
    _LIB_INPUT.OnPressed(input.map, key)
end

---@param input Actor.Component.Input
---@param key string
function _INPUT.Release(input, key)
    _LIB_INPUT.OnReleased(input.map, key)
end

---@param input Actor.Component.Input
---@param key string
---@return bool
function _INPUT.IsPressed(input, key)
    return _LIB_INPUT.IsPressed(input.map, key)
end

---@param input Actor.Component.Input
---@param key string
---@return bool
function _INPUT.IsHold(input, key)
    return _LIB_INPUT.IsHold(input.map, key)
end

---@param input Actor.Component.Input
---@param key string
---@return bool
function _INPUT.IsReleased(input, key)
    return _LIB_INPUT.IsReleased(input.map, key)
end

---@param direction direction
---@return string, string
function _INPUT.GetKeyWithDirection(direction)
    local front, back

    if (direction > 0) then
        front = "right"
        back = "left"
    else
        front = "left"
        back = "right"
    end

    return front, back
end

---@param input Actor.Component.Input
---@param direction direction
---@return direction @-1: back, 0: null, 1: front
function _INPUT.GetArrowDirection(input, direction)
    local front, back = _INPUT.GetKeyWithDirection(direction)

    if (_INPUT.IsHold(input, back)) then
        return -1
    elseif (_INPUT.IsHold(input, front)) then
        return 1
    end

    return 0
end

return _INPUT