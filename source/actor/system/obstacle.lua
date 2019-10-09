--[[
	desc: Obstacle, a system of obstacle management.
	author: Musoucrow
	since: 2018-5-18
	alter: 2019-5-1
]]--

local _MAP = require("map.init")

local _Point = require("graphics.drawunit.point")
local _Base = require("actor.system.base")

---@class Actor.System.Obstacle : Actor.System
local _Obstacle = require("core.class")(_Base)

local function _HandleObstacle(obstacle, data, nx, ny)
    local matrix = _MAP.GetMatrix()

    for n=0, data.w do
        for m=0, data.h do
            local x = nx + data.x + n
            local y = ny + data.y + m

            if (not matrix:GetNode(x, y, true)) then
                matrix:SetNode(x, y, true, true)
                table.insert(obstacle.list, _Point.New(true, x, y))
            end
        end
    end
end

function _Obstacle:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        obstacle = true
    }, "obstacle")

    _MAP.AddLoadListener(self, self.OnClean)
end

---@param entity Actor.Entity
function _Obstacle:OnEnter(entity)
    local matrix = _MAP.GetMatrix()
    local obstacle = entity.obstacle
    local data = obstacle.data
    local nx = matrix:ToNode(entity.transform.position.x, "x")
    local ny = matrix:ToNode(entity.transform.position.y, "y")

    if (#data > 0) then
        for n=1, #data do
            _HandleObstacle(obstacle, data[n], nx, ny)
        end
    else
        _HandleObstacle(obstacle, data, nx, ny)
    end

    obstacle.data = nil
end

function _Obstacle:OnClean()
    for n=1, self._list:GetLength() do
        self:OnExit(self._list:Get(n))
    end
end

---@param entity Actor.Entity
function _Obstacle:OnExit(entity)
    if (not entity.obstacle.list) then
        return
    end

    local matrix = _MAP.GetMatrix()
    
    for n=1, #entity.obstacle.list do
        local x, y = entity.obstacle.list[n]:Get()
        matrix:SetNode(x, y, false, true)
    end

    entity.obstacle.list = nil
end

return _Obstacle