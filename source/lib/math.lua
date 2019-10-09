--[[
	desc: MATH, a lib that encapsulate math function.
	author: Musoucrow
	since: 2018-3-13
	alter: 2019-5-5
]]--

local _MATH = {} ---@class Lib.MATH

---@param angle number
---@return number
function _MATH.AngleToRadian(angle)
    return math.pi / 180 * angle
end

---@param radian number
---@return number
function _MATH.RadianToAngle(radian)
    return 180 / math.pi * radian
end

---@param px number
---@param py number
---@param ox number
---@param oy number
---@param radian number
---@return number
function _MATH.RotatePoint(px, py, ox, oy, radian)
    local x = (px - ox)
    local y = (py - oy)
    local cos = math.cos(radian)
    local sin = math.sin(radian)

    return x * cos - y * sin + ox, x * sin + y * cos + oy
end

---@param value number
---@param min number
---@param max number
---@return number
function _MATH.Clamp(value, min, max)
    return value < min and min or (value > max and max or value)
end

---@param ax number
---@param ax number
---@param bx number
---@param by number
---@return number
function _MATH.GetPointsRadian(ax, ay, bx, by)
    local a = math.atan2(by - ay, bx - ax)
    a = -a

    while a < 0 do
        a = a + math.pi * 2
    end

    while a >= math.pi * 2 do
        a = a - math.pi * 2
    end

    return a
end

---@param ax number
---@param ax number
---@param bx number
---@param by number
---@return number
function _MATH.GetPointsDistance(ax, ay, bx, by)
    return math.sqrt( math.abs(bx - ax) ^ 2 + math.abs(by - ay) ^ 2)
end

---@param value number
---@return direction
function _MATH.GetDirection(value)
    return value >= 0 and 1 or -1
end

---@param decimal number
function _MATH.GetFixedDecimal(decimal)
    return math.floor(math.abs(decimal * 1000)) * 0.001 * _MATH.GetDirection(decimal)
end

---@param fixed int
function _MATH.FixedToNumber(fixed)
    return math.floor(math.abs(fixed)) * 0.001 * _MATH.GetDirection(fixed)
end

---@param from number
---@param to number
---@param process number @0-1
---@return number
function _MATH.Lerp(from, to, process)
    if (process <= 0) then
        return from
    elseif (process >= 1) then
        return to
    end

    return process * to + (1 - process) * from
end

---@param num number
function _MATH.Round(num)
    return math.floor(num + 0.5)
end

---@param range table | number
---@return number
function _MATH.GetRandomValue(range)
    if (type(range) == "table") then
        return math.random(range[1], range[2])
    end

    return range
end

function _MATH.GetRadianWithFan(ox, oy, tx, ty, ra, rb)
    local radian = _MATH.GetPointsRadian(ox, oy, tx, ty)
    local over = false
    
    if (ra > rb) then
        local tmp = ra
        ra = rb
        rb = tmp
    end

    if (rb - ra > math.pi) then
        if (radian > ra and radian < rb) then
            over = true

            if (math.abs(radian - ra) < math.abs(radian - rb)) then
                radian = ra
            else
                radian = rb
            end
        end
    else
        if (radian < ra) then
            over = true
            radian = ra
        elseif (radian > rb) then
            over = true
            radian = rb
        end
    end

    return over, radian
end

function _MATH.GetRadianWithFan2(ox, oy, tx, ty, r)
    local direction = tx >= ox and 1 or -1
    local ra = direction == 1 and r or r + math.pi
    local rb = math.pi * 2 - ra

    return _MATH.GetRadianWithFan(ox, oy, tx, ty, ra, rb)
end

---@return boolean
function _MATH.IsFront(ox, tx, direction)
    return (direction == 1 and ox <= tx) or (direction == -1 and ox >= tx)
end

---@param list table
---@param left int @default=1
---@param right int @default=#list
---@param Compare function
---@param Set function
function _MATH.QuickSort(list, left, right, Compare, Set)
    if (left >= right) then
        return
    end

    local i = left
    local j = right
    local x = list[i]

    while (i < j) do
        while (i < j and not Compare(list[j], x)) do
            j = j - 1
        end

        if (i < j) then
            list[i] = list[j]
            Set(list, i)
            i = i + 1
        end

        while (i < j and Compare(list[i], x)) do
            i = i + 1
        end

        if (i < j) then
            list[j] = list[i]
            Set(list, j)
            j = j - 1
        end
    end

    list[i] = x
    Set(list, i)
    _MATH.QuickSort(list, left, i - 1, Compare, Set)
    _MATH.QuickSort(list, i + 1, right, Compare, Set)
end

---@param list table
---@param v number
---@return int @pos
function _MATH.Binrary(list, v, a, b)
    if (not a and not b) then
        if (v <= list[1]) then
            return 1
        elseif (v >= list[#list]) then
            return #list
        elseif (v > list[#list]) then
            return #list + 1
        end
    end

    a = a or 1
    b = b or #list

    if (a == b or b - a == 1) then
        return b
    end

    local c = a + math.floor((b - a) * 0.5)

    if (list[c] == v) then
        return c
    elseif (list[c] > v) then
        return _MATH.Binrary(list, v, a, c)
    elseif (list[c] < v) then
        return _MATH.Binrary(list, v, c, b)
    end
end

return _MATH