--[[
	desc: Article, a basic article.
	author: Musoucrow
    since: 2018-8-10
    alter: 2019-8-15
]]--

local _RESOURCE = require("lib.resource")
local _RESMGR = require("actor.resmgr")

---@class Actor.Component.Article
---@field public frameaniData Lib.RESOURCE.FrameaniData
---@field public effectData Actor.RESMGR.InstanceData
---@field public dropItemData Actor.RESMGR.DropItemData
---@field public fairyDatas table<int, Actor.RESMGR.InstanceData>
---@field public isDead boolean
---@field public clearObstacle boolean
local _Article = require("core.class")()

function _Article.HandleData(data)
    if (data.frameani) then
        data.frameani = _RESOURCE.Recur(_RESMGR.GetFrameaniData, data.frameani, "list")
    end

    if (data.effect) then
        data.effect = _RESMGR.GetInstanceData(data.effect)
    end
end

function _Article:Ctor(data)
    self.frameaniData = data.frameani
    self.effectData = data.effect
    self.clearObstacle = data.clearObstacle or false
    self.isDead = false
end

return _Article