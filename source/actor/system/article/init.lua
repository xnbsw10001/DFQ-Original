--[[
	desc: Article, a system of article's business.
	author: Musoucrow
    since: 2018-8-10
    alter: 2019-8-15
]]--

local _ECSMGR = require("actor.ecsmgr")
local _FACTORY = require("actor.factory")
local _ASPECT = require("actor.service.aspect")

local _Base = require("actor.system.base")

---@class Actor.System.Article : Actor.System
local _Article = require("core.class")(_Base)

function _Article:Ctor(upperEvent)
    _Base.Ctor(self, upperEvent, {
        article = true,
        battle = true
    }, "article")
end

function _Article:Update(dt)
    for n=1, self._list:GetLength() do
        local e = self._list:Get(n) ---@type Actor.Entity

        if (not e.identity.isPaused and e.battle.deadProcess > 0 and not e.article.isDead) then
            if (e.article.effectData) then
                local pos = e.transform.position
                local z = _ASPECT.GetPart(e.aspect):GetHeight() * 0.5
                local param = {
                    x = pos.x,
                    y = pos.y,
                    z = pos.z - z,
                    direction = -e.transform.direction,
                    entity = e
                }
                _FACTORY.New(e.article.effectData, param)
            end

            if (e.article.frameaniData) then
                _ASPECT.Play(e.aspect, e.article.frameaniData)

                if (e.obstacle and e.article.clearObstacle) then
                    _ECSMGR.DelComponent(e, "obstacle")
                end
            end

            e.article.isDead = true
        end
    end
end

return _Article