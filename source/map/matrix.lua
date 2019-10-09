--[[
	desc: Matrix has functions of pathfinding and obstacle.
	author: Musoucrow
	since: 2018-11-22
	alter: 2019-6-1
]]--

local _MATH = require("lib.math")
local _TABLE = require("lib.table")
local _GRAPHICS = require("lib.graphics")

local _Bstar = require("util.bstar")
local _Rect = require("graphics.drawunit.rect")
local _Point = require("graphics.drawunit.point")
local _Sprite = require("graphics.drawable.sprite")

---@class Map.Matrix
---@field protected _gridSize int
---@field protected _bstar Util.Bstar
---@field protected _rect Graphics.Drawunit.Rect
---@field protected _sprite Graphics.Drawable.Sprite
---@field protected _openNodes table<int, int>
local _Matrix = require("core.class")()

function _Matrix:Ctor(gridSize, x, y, w, h)
    self._gridSize = gridSize or 16
    self._bstar = _Bstar.New()
    self._rect = _Rect.New()
    self._sprite = _Sprite.New()

    if (x and y and w and w) then
        self:Reset(x, y, w, h)
    end
end

---@param x int
---@param y int
---@param w int
---@param h int
---@param initOpenNodes boolean
function _Matrix:Reset(x, y, w, h, initOpenNodes)
    self._rect:Set(x, y, w, h)
    self._bstar:Reset(self:ToNode(w) - 1, self:ToNode(h) - 1)
    self._sprite:SetAttri("position", self._rect:Get("x"), self._rect:Get("y"))

    if (initOpenNodes) then
        self:InitOpenNodes()
    end
end

function _Matrix:MakeSprite()
    local canvas = _GRAPHICS.NewCanvas(self._rect:Get("w"), self._rect:Get("h"))
    _GRAPHICS.SetCanvas(canvas)
    _GRAPHICS.SetColor(255, 0, 0, 127)

    for n=0, self._bstar:GetWidth() do
        for m=0, self._bstar:GetHeight() do
            if (self._bstar:GetNode(n, m)) then
                _GRAPHICS.DrawRect(n * self._gridSize, m * self._gridSize, self._gridSize, self._gridSize, "fill")
            end
        end
    end

    _GRAPHICS.SetColor(255, 255, 255, 255)

    for n=0, self._bstar:GetWidth() do
        for m=0, self._bstar:GetHeight() do
            _GRAPHICS.DrawRect(n * self._gridSize, m * self._gridSize, self._gridSize, self._gridSize)
        end
    end

    _GRAPHICS.SetCanvas()
    self._sprite:SetImage(canvas)
end

function _Matrix:Draw()
    self._sprite:Draw()
end

---@param x int
---@param y int
---@param isObs boolean
---@param isOrigin boolean
function _Matrix:SetNode(x, y, isObs, isOrigin)
    if (not isOrigin) then
        x = self:ToNode(x, "x")
        y = self:ToNode(y, "y")
    end

    if (self:GetNode(x, y, true) == isObs) then
        return
    end

    local pos = _MATH.Binrary(self._openNodes[y], x)

    if (isObs) then
        table.remove(self._openNodes[y], pos)
    else
        table.insert(self._openNodes[y], pos, x)
    end

    self._bstar:SetNode(x, y, isObs)
end

---@param rect Graphics.Drawunit.Rect
---@param isObs boolean
function _Matrix:SetNodeWithRect(rect, isObs)
    local x = self:ToNode(rect:Get("x"), "x")
    local y = self:ToNode(rect:Get("y"), "y")
    local xw = self:ToNode(rect:Get("xw"), "x")
    local yh = self:ToNode(rect:Get("yh"), "y")

    for n=x, xw do
        for m=y, yh do
            self._bstar:SetNode(n, m, isObs)
        end
    end
end

---@param x int
---@param y int
---@param isOrigin boolean
---@return boolean
function _Matrix:GetNode(x, y, isOrigin)
    if (not isOrigin) then
        x = self:ToNode(x, "x")
        y = self:ToNode(y, "y")
    end

    return self._bstar:GetNode(x, y)
end

---@param x int
---@param y int
---@param isOrigin boolean
---@param toPosition boolean
---@return int, int
function _Matrix:GetOpenNode(x, y, isOrigin, toPosition)
    if (not isOrigin) then
        x = self:ToNode(x, "x")
        y = self:ToNode(y, "y")
    end

    local n, m = self._bstar:GetOpenNode(x, y)

    if (n and m and toPosition) then
        n = self:ToPosition(n, "x", true)
        m = self:ToPosition(m, "y", true)
    end

    return n, m
end

---@param x1 int
---@param y1 int
---@param x2 int
---@param y2 int
---@return table<int, Graphics.Drawunit.Point> @path
function _Matrix:GetPath(x1, y1, x2, y2)
    x1 = self:ToNode(x1, "x")
    y1 = self:ToNode(y1, "y")
    x2 = self:ToNode(x2, "x")
    y2 = self:ToNode(y2, "y")
    local path = self._bstar:GetPath(x1, y1, x2, y2)

    if (not path) then
        return
    end

    local shift = self._gridSize * 0.5
    local x, y = path[#path].x, path[#path].y
    local type

    for n=#path - 1, 1, -1 do
        if (type) then
            if ((type == "x" and x ~= path[n].x) or (type == "y" and y ~= path[n].y)) then
                type = nil
            elseif (x == path[n].x or y == path[n].y) then
                table.remove(path, n)
            end
        end

        if (not type) then
            if (x == path[n].x) then
                type = "x"
            elseif (y == path[n].y) then
                type = "y"
            end
        end
    end

    for n=1, #path do
        path[n].x = self:ToPosition(path[n].x, "x") + shift
        path[n].y = self:ToPosition(path[n].y, "y") + shift
    end

    return path
end

---@param x int
---@param y int
---@return int, int
function _Matrix:CorrectPosition(x, y)
    if (x < self._rect:Get("x")) then
        x = self._rect:Get("x")
    elseif (x > self._rect:Get("xw")) then
        x = self._rect:Get("xw")
    end

    if (y < self._rect:Get("y")) then
        y = self._rect:Get("y")
    elseif (y > self._rect:Get("yh")) then
        y = self._rect:Get("yh")
    end

    return x, y
end

---@param value int
---@param type string
---@param correct boolean
---@return int
function _Matrix:ToNode(value, type, correct)
    if (type) then
        value = value - self._rect:Get(type)
    end

    local v = math.floor(value / self._gridSize)

    if (type and correct) then
        if (v < 0) then
            v = 0
        else
            local vv = type == "x" and self:GetWidth() or self:GetHeight()
            v = v > vv and vv or v
        end
    end

    return v
end

---@param value int
---@param type string
---@return int
function _Matrix:ToPosition(value, type, isCenter)
    value = value * self._gridSize

    if (type) then
        value = value + self._rect:Get(type)
    end

    if (isCenter) then
        value = value + self._gridSize * 0.5
    end

    return value
end

---@param isOrigin boolean
---@return int
function _Matrix:GetWidth(isOrigin)
    local width = self._bstar:GetWidth()
    width = isOrigin and width * self._gridSize or width

    return width
end

---@param isOrigin boolean
---@return int
function _Matrix:GetHeight(isOrigin)
    local height = self._bstar:GetHeight()
    height = isOrigin and height * self._gridSize or height

    return height
end

function _Matrix:InitOpenNodes()
    self._openNodes = {}
    
    for n=0, self:GetHeight() do
        self._openNodes[n] = {}

        for m=0, self:GetWidth() do
            if (not self:GetNode(m, n, true)) then
                table.insert(self._openNodes[n], m)
            end
        end
    end
end

---@param Add function
---@param count int
---@param isFree boolean
function _Matrix:Assign(Add, count, isFree)
    local i = 1

    while (i <= count) do
        local n = math.random(0, #self._openNodes)

        if (#self._openNodes[n] > 0) then
            local m = self._openNodes[n][math.random(1, #self._openNodes[n])]
            local x = self:ToPosition(m, "x", true)
            local y = self:ToPosition(n, "y", true)

            Add(x, y, i)

            if (not isFree) then
                self:SetNode(m, n, true, true)
            end

            i = i + 1
        else
            break
        end
    end
end

---@return int
function _Matrix:GetGridSize()
    return self._gridSize
end

return _Matrix