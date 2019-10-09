--[[
	desc: Pathgate, a article of path gate.
	author: Musoucrow
    since: 2018-6-5
    alter: 2019-5-7
]]--

local _Point = require("graphics.drawunit.point")

---@class Actor.Component.Article.Pathgate
---@field public lightTweener Util.Gear.Tweener
---@field public doorTweener Util.Gear.Tweener
---@field public isOpened boolean
---@field public isLock boolean
---@field public doorTime milli
---@field public lightTime milli
---@field public enable boolean
---@field public isBoss boolean
---@field public crossActorDatas table<int, Actor.RESMGR.InstanceData>
---@field public portPosition Graphics.Drawunit.Point
---@field public isEntrance boolean
local _Pathgate = require("core.class")()

function _Pathgate:Ctor(data, param)
    self.isOpened = false
    self.isLock = false
    self.enable = param.pathgateEnable
    self.doorTime = data.doorTime or 500
    self.lightTime = data.lightTime or 1000
    self.isBoss = data.isBoss
    self.crossActorDatas = {}
    self.portPosition = _Point.New(true, param.portPosition.x, param.portPosition.y)
    self.isEntrance = param.isEntrance
end

return _Pathgate