--[[
	desc: Obstacle, a component with obstacle.
	author: Musoucrow
	since: 2018-5-18
	alter: 2018-6-4
]]--

---@class Actor.Component.Obstacle
---@field public list table<number, Graphics.Drawunit.Point>
local _Obstacle = require("core.class")()

function _Obstacle:Ctor(data)
    self.list = {}
    self.data = data
end

return _Obstacle



