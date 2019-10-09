--[[
	desc: Move, a Ai of moving.
	author: Musoucrow
	since: 2018-5-2
	alter: 2018-7-13
]]--

local _MATH = require("lib.math")
local _INPUT = require("actor.service.input")

local _Map = require("map.init")
local _Point = require("graphics.drawunit.point")
local _Base = require("actor.ai.base")

---@param self Actor.Ai.Move
local function _NextTarget(self)
    if (not self._path) then
        return
    elseif (self._index >= #self._path) then
        self._path = nil
        return
    end

    self._index = self._index + 1
    local position = self._entity.transform.position
    local x = _MATH.Clamp(self._path[self._index].x, self._later.x, position.x)
    local y = _MATH.Clamp(self._path[self._index].y, self._later.y, position.y)

    if (x == self._path[self._index].x) then
        self._directionX = 0
    else
        self._directionX = position.x < self._path[self._index].x and 1 or -1
    end

    if (y == self._path[self._index].y) then
        self._directionY = 0
    else
        self._directionY = position.y < self._path[self._index].y and 1 or -1
    end

    self._later:Set(position:Get())
end

---@class Actor.Ai.Move : Actor.Ai
---@field protected _path table<int, Graphics.Drawunit.Point>
---@field protected _index int
---@field protected _later Graphics.Drawunit.Point
---@field protected _directionX direction
---@field protected _directionY direction
local _Move = require("core.class")(_Base)

function _Move:Ctor(entity)
    _Base.Ctor(self, entity)

    self._later = _Point.New(true)
end

function _Move:Update()
    if (self._path) then
        local target = self._path[self._index]
        local position = self._entity.transform.position

        if (self._directionX ~= 0) then
            local key = self._directionX == 1 and "right" or "left"
            _INPUT.Press(self._entity.input, key)

            if ((self._directionX == 1 and position.x >= target.x) or (self._directionX == -1 and position.x <= target.x)) then
                self._directionX = 0
            end
        end

        if (self._directionY ~= 0) then
            local key = self._directionY == 1 and "down" or "up"
            _INPUT.Press(self._entity.input, key)

            if ((self._directionY == 1 and position.y >= target.y) or (self._directionY == -1 and position.y <= target.y)) then
                self._directionY = 0
            end
        end

        if (self._directionX == 0 and self._directionY == 0) then
            _NextTarget(self)
        end
    end
end

function _Move:Tick(x, y)
    if (not self:CanRun()) then
        return false
    end

    local matrix = _Map.GetMatrix()
    
    if (not matrix:GetNode(x, y)) then
        local position = self._entity.transform.position

        self._path = matrix:GetPath(position.x, position.y, x, y)
        self._entity.aspect.path = self._path
        self._index = 0
        _NextTarget(self)
    end

    return true
end

function _Move:IsRunning()
    return self._path ~= nil
end

function _Move:GetTarget()
    if (not self:IsRunning()) then
        return
    end
    
    return self._path[#self._path]:Get()
end

return _Move