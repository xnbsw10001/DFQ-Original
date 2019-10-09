--[[
	desc: PATHGATE, a service for pathgate.
	author: Musoucrow
	since: 2018-12-16
	alter: 2019-8-4
]]--

local _ECSMGR = require("actor.ecsmgr")

local _list = _ECSMGR.NewComboList({article_pathgate = true})

---@class Actor.Service.PATHGATE
local _PATHGATE = {}

function _PATHGATE.GetList()
    return _list
end

---@return Actor.Entity
function _PATHGATE.GetEntrance()
    for n=1, _list:GetLength() do
        local e = _list:Get(n) ---@type Actor.Entity
        
        if (e.article_pathgate.isEntrance) then
            return e
        end
    end
end

---@param isLock boolean
function _PATHGATE.LockGate(isLock)
    for n=1, _list:GetLength() do
        local e = _list:Get(n) ---@type Actor.Entity
        local pathgate = e.article_pathgate ---@type Actor.Component.Article.Pathgate
        pathgate.isLock = isLock
    end
end

---@param isForce boolean
function _PATHGATE.OpenGate(isForce)
    for n=1, _list:GetLength() do
        local e = _list:Get(n) ---@type Actor.Entity
        local pathgate = e.article_pathgate ---@type Actor.Component.Article.Pathgate
        
        if ((pathgate.enable or isForce) and not pathgate.isLock and not pathgate.isEntrance) then
            local doorTarget = pathgate.doorTweener:GetTarget() ---@type Graphics.Drawunit.Color
            doorTarget.alpha = 0

            local lightTarget = pathgate.lightTweener:GetTarget() ---@type Graphics.Drawunit.Color
            lightTarget.alpha = 255

            pathgate.doorTweener:Enter()
            pathgate.lightTweener:Enter()
            pathgate.isOpened = true
            e.transport.enable = true
        end
    end
end

function _PATHGATE.CloseGate()
    for n=1, _list:GetLength() do
        local e = _list:Get(n) ---@type Actor.Entity
        local pathgate = e.article_pathgate ---@type Actor.Component.Article.Pathgate
        
        if (pathgate.isOpened and not pathgate.isLock) then
            local doorTarget = pathgate.doorTweener:GetTarget() ---@type Graphics.Drawunit.Color
            doorTarget.alpha = 255
    
            local lightTarget = pathgate.lightTweener:GetTarget() ---@type Graphics.Drawunit.Color
            lightTarget.alpha = 0
    
            pathgate.doorTweener:Enter()
            pathgate.lightTweener:Enter()
            pathgate.isOpened = false
            e.transport.enable = false
        end
    end
end

---@param pathgate Actor.Component.Article.Pathgate
---@param transport Actor.Component.Transport
---@return int, int, direction
function _PATHGATE.GetPositionAndDirection(pathgate, transport)
    local direction

    if (transport.direction == "left") then
        direction = 1
    elseif (transport.direction == "right") then
        direction = -1
    else
        direction = math.random() < 0.5 and 1 or -1
    end

    return pathgate.portPosition.x, pathgate.portPosition.y, direction
end

---@param direction string
---@return string
function _PATHGATE.GetRelative(direction)
    if (direction == "left") then
        return "right"
    elseif (direction == "right") then
        return "left" 
    elseif (direction == "up") then
        return "down"
    elseif (direction == "down") then
        return "up"
    end
end

return _PATHGATE