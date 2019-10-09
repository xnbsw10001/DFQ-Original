--[[
	desc: Colorize, a effect about color.
	author: Musoucrow
    since: 2019-1-16
]]--

local _Color = require("graphics.drawunit.color")

---@class Actor.Component.Effect.Colorize
---@field public motions table
---@field public colorTweener Util.Gear.Tweener
---@field public index int
---@field public mode string @nil, loop
local _Colorize = require("core.class")()

function _Colorize:Ctor(data, param)
    self.motions = data.motions
    self.index = 0
    self.mode = data.mode
end

return _Colorize