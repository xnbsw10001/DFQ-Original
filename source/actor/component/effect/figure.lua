--[[
	desc: Figure, a effect of figure.
	author: Musoucrow
	since: 2018-5-29
]]--

local _Color = require("graphics.drawunit.color")

---@class Actor.Component.Effect.Figure
---@field public time milli
---@field public spriteData Lib.RESOURCE.SpriteData
---@field public colorTweener Util.Gear.Tweener
---@field public noPure boolean
---@field public blendmode string
local _Figure = require("core.class")()

function _Figure:Ctor(data, param)
    self.time = data.time
    self.spriteData = param.spriteData
    self.noPure = param.noPure or false
    self.blendmode = param.blendmode or "add"
end

return _Figure