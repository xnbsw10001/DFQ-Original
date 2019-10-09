--[[
	desc: Bstar, A pathfinding utility.
	author: Musoucrow
	since: 2018-11-20
	alter: 2019-3-24
]]--

local _Point = require("graphics.drawunit.point") ---@type Graphics.Drawunit.Point

local _rule = {
    {0, -1},
    {0, 1},
    {-1, 0},
    {1, 0},
    {-1, -1},
    {1, -1},
    {-1, 1},
    {1, 1}
}

---@param self Util.Bstar
---@param x1 int
---@param y1 int
---@param x2 int
---@param y2 int
---@param path table
---@param isFourAxis boolean
local function _EnumNode_Sub (self, x1, y1, x2, y2, path, isFourAxis)
    local start, endl, num

    if (isFourAxis) then
        start = 1
        endl = 4
        num = 10
    else
        start = 5
        endl = 8
        num = 14
    end

    for n=start, endl do
        local nodex = x1 + _rule[n][1]
        local nodey = y1 + _rule[n][2]

        if (self._rangeMat[nodex] and self._rangeMat[nodex][nodey] and not self._closeMat[nodex][nodey] and not self._fenceMat[nodex][nodey]) then
            local cond = true

            if (isFourAxis == false) then
                cond = self._closeMat[nodex][y1] or self._closeMat[x1][nodey]
            end

            if (cond) then
                self._closeMat[nodex][nodey] = true

                local F = (math.abs(x2 - nodex) + math.abs(y2 - nodey)) * 10 + num
                local pPath = {}

                for m=1,#path do
                    pPath[#pPath + 1] = path[m]
                end

                pPath[#pPath + 1] = _Point.New(true, nodex, nodey)

                local point = 0

                for m=1, #self._openList do
                    if (F <= self._openList[m].pathGrade) then
                        point = m
                        table.insert(self._openList, m, {x = nodex, y = nodey, pathGrade = F, savePath = pPath})

                        break
                    end
                end

                if (point == 0) then
                    self._openList[#self._openList + 1] = {x = nodex, y = nodey, pathGrade = F, savePath = pPath}
                end
            end
        end
    end
end

---@param self Util.Bstar
---@param x1 int
---@param y1 int
---@param x2 int
---@param y2 int
---@param path table
local function _EnumNode(self, x1, y1, x2, y2, path)
    _EnumNode_Sub (self, x1, y1, x2, y2, path, true)
    _EnumNode_Sub (self, x1, y1, x2, y2, path, false)
end

---@class Util.Bstar
---@field protected _fenceMat table<table<number, boolean>>
---@field protected _rangeMat table<table<number, boolean>>
---@field protected _closeMat table<table<number, boolean>>
---@field protected _openList table<number, table>
---@field protected _width int
---@field protected _height int
local _Bstar = require("core.class")()

function _Bstar:Ctor()
    self._fenceMat = {}
    self._rangeMat = {}
    self._closeMat = {}
    self._openList = {}
end

---@param w int
---@param h int
function _Bstar:Reset(w, h)
    self._fenceMat = {}
    self._rangeMat = {}
    self._closeMat = {}

    self._width = w
    self._height = h

    for n=0, w do
        self._fenceMat[n] = {}
        self._rangeMat[n] = {}
        self._closeMat[n] = {}

        for m=0, h do
            self._rangeMat[n][m] = true
        end
    end
end

---@param x int
---@param y int
---@param isObs boolean
function _Bstar:SetNode(x, y, isObs)
    if (self._fenceMat[x]) then
        self._fenceMat[x][y] = isObs or nil
    end
end

---@param x int
---@param y int
---@return boolean @isObs
function _Bstar:GetNode(x, y)
    if (not self:InScope(x, y)) then
        return true
    end

    if (self._fenceMat[x]) then
        return self._fenceMat[x][y] or false
    end

    return true
end

---@param x int
---@param y int
---@return int, int @open node position
function _Bstar:GetOpenNode(x, y)
    if (not self:InScope(x, y)) then
        return
    end

    local add = 1

    while true do
        for n=1,8 do
            local nodex = x + _rule[n][1] * add
            local nodey = y + _rule[n][2] * add
            if (self._rangeMat[nodex] and self._rangeMat[nodex][nodey] and not self._fenceMat[nodex][nodey] and nodex ~= x and nodey ~= y) then
                return nodex, nodey
            end
        end

        add = add + 1
    end
end

---@param x1 int
---@param y1 int
---@param x2 int
---@param y2 int
---@return table<int, Graphics.Drawunit.Point> @path
function _Bstar:GetPath(x1, y1, x2, y2)
    if (not self:InScope(x1, y1) or not self:InScope(x2, y2)) then
        return
    end

    self._openList = {}

    for n=0, #self._closeMat do
        self._closeMat[n] = {}
    end

    self._closeMat[x1][y1] = true
    _EnumNode(self, x1, y1, x2, y2, {})

    while (#self._openList > 0) do
        local max = nil

        for n=1, 2 do
            local data = self._openList[1]

            if (data == nil) then
                return
            end

            local x = data.x
            local y = data.y

            if (max == nil) then
                max = data.saveGrade
            elseif (data == nil or max > data.saveGrade) then
                break
            end

            if (x == x2 and y == y2) then
                return data.savePath
            end

            table.remove(self._openList, 1)
            _EnumNode(self, x, y, x2, y2, data.savePath)
        end
    end
end

---@return int
function _Bstar:GetWidth()
    return self._width
end

---@return int
function _Bstar:GetHeight()
    return self._height
end

---@return boolean
function _Bstar:InScope(x, y)
    if (x < 0 or x > self._width or y < 0 or y > self._height) then
        return false
    end

    return true
end

return _Bstar