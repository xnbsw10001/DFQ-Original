--[[
	desc: Effect, a component of effect.
	author: Musoucrow
	since: 2018-5-10
	alter: 2018-11-11
]]--

local _emptyTable = {}

---@class Actor.Component.Effect
---@field public lockStop boolean
---@field public lockRate boolean
---@field public lockLife boolean
---@field public lockDirection boolean
---@field public lockAlpha boolean
---@field public state Actor.State
---@field public positionType string @nil, "normal", "bottom", "top", "middle"
---@field public height int
---@field public adapt Graphics.Drawunit.Point | boolean
local _Effect = require("core.class")()

function _Effect:Ctor(data, param)
    data = data or _emptyTable

    self.lockStop = data.lockStop or false
    self.lockRate = data.lockRate or false
    self.lockDirection = data.lockDirection or false
    self.lockAlpha = data.lockAlpha or false

    if (data.lockState and param.entity and param.entity.states) then
        self.state = param.entity.states.current
    end

    if (data.lockLife ~= nil) then
        self.lockLife = data.lockLife
    else
        self.lockLife = true
    end

    self.positionType = data.positionType
    self.adapt = data.adapt
end

return _Effect


