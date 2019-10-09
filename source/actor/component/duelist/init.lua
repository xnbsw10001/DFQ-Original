--[[
	desc: Duelist, a component of duelist.
	author: Musoucrow
	since: 2018-5-2
	alter: 2018-12-14
]]--

local _Point = require("graphics.drawunit.point")

---@class Actor.Component.Duelist
---@field moveSpeed number
---@field weight number
---@field isEnemy boolean
---@field rank int @0=normal, 1=named, 2=boss
---@field icon Lib.RESOURCE.SpriteData
---@field iconShift Graphics.Drawunit.Point
---@field playerIcon Lib.RESOURCE.SpriteData
---@field playerIconShift Graphics.Drawunit.Point
---@field category string
---@field aura Actor.Entity
local _Duelist = require("core.class")()

function _Duelist:Ctor(data, param)
    self.moveSpeed = data.moveSpeed or 2
    self.weight = data.weight or 0
    self.weight = self.weight + 1
    self.rank = data.rank or 0
    self.category = data.category or "human"
    self.iconShift = _Point.New(true)

    if (data.iconShift) then
        self.iconShift:Set(data.iconShift.x, data.iconShift.y)
    end

    self.playerIconShift = _Point.New(true)

    if (data.playerIconShift) then
        self.playerIconShift:Set(data.playerIconShift.x, data.playerIconShift.y)
    else
        self.playerIconShift:Set(self.iconShift:Get())
    end

    self.isEnemy = data.isEnemy or param.isEnemy or false
end

return _Duelist


