--[[
	desc: Transparency, a component with transparency.
	author: Musoucrow
	since: 2018-5-18
	alter: 2018-6-4
]]--

---@class Actor.Component.Transparency
---@field public y int
---@field public rate number
---@field public isTransparent boolean
---@field public motionTime milli
---@field public collider Actor.Collider
---@field public colorTweener Util.Gear.Tweener
local _Transparency = require("core.class")()

function _Transparency:Ctor(data)
    if (data) then
        self.y = data.y
        self.rate = data.rate
        self.motionTime = data.motionTime
    end

    self.y = self.y or 0
    self.rate = self.rate or 0.2
    self.motionTime = self.motionTime or 500
    self.isTransparent = false
end

return _Transparency
